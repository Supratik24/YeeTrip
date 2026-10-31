import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/categories.dart';
import '../../../data/local/app_database.dart' hide Traveler;
import '../../expenses/domain/expense_model.dart';
import '../domain/trip_model.dart';

/// Service to handle JSON export, sharing, validation, and restoration for YeeTrip.
class TripBackupService {
  final AppDatabase _db;
  final Uuid _uuid;

  TripBackupService(this._db, [Uuid? uuid]) : _uuid = uuid ?? const Uuid();

  /// Serializes a [trip] and its [expenses] to an offline portable JSON string.
  static String exportTripToJson({
    required TripWithDetails trip,
    required List<ExpenseWithSplits> expenses,
  }) {
    final Map<String, dynamic> backupMap = {
      'version': 1,
      'app': 'YeeTrip',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'trip': {
        'id': trip.id,
        'name': trip.name,
        'totalBudgetPaise': trip.totalBudgetPaise,
        'days': trip.days,
        'currency': trip.currency,
        'createdAt': trip.createdAt.toUtc().toIso8601String(),
        'categoryAllocations': trip.categoryAllocations,
        'travelers': trip.travelers
            .map((t) => {
                  'id': t.id,
                  'name': t.name,
                  if (t.upiVpa != null && t.upiVpa!.isNotEmpty)
                    'upiVpa': t.upiVpa,
                })
            .toList(),
      },
      'expenses': expenses
          .map((e) => {
                'id': e.id,
                'description': e.description,
                'amountPaise': e.amountPaise,
                'category': e.category,
                'paidBy': e.paidBy,
                'source': e.source,
                'confirmed': e.confirmed,
                if (e.upiTxnId != null) 'upiTxnId': e.upiTxnId,
                'createdAt': e.createdAt.toUtc().toIso8601String(),
                'splits': e.splits
                    .map((s) => {
                          'travelerId': s.travelerId,
                          'sharePaise': s.sharePaise,
                        })
                    .toList(),
              })
          .toList(),
    };

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(backupMap);
  }

  /// Exports the trip to JSON and opens the native system share sheet.
  static Future<void> exportAndShareBackup({
    required TripWithDetails trip,
    required List<ExpenseWithSplits> expenses,
  }) async {
    final jsonContent = exportTripToJson(trip: trip, expenses: expenses);
    final sanitizedName = trip.name.replaceAll(RegExp(r'[^\w\s]+'), '_').trim();
    final fileName = 'yeetrip_${sanitizedName}_backup.json';
    final bytes = Uint8List.fromList(utf8.encode(jsonContent));

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes,
            mimeType: 'application/json',
            name: fileName,
          ),
        ],
        subject: 'YeeTrip Backup: ${trip.name}',
        text: 'Offline trip backup for ${trip.name} generated with YeeTrip',
      ),
    );
  }

  /// Restores a trip and all its expenses from a JSON string into the SQLite database.
  ///
  /// Returns the newly assigned unique [tripId].
  Future<String> restoreTripFromJson(String jsonString) async {
    final trimmed = jsonString.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Backup JSON cannot be empty');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(trimmed);
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected JSON object at root of backup');
    }

    // 1. Validate version and app signature
    final version = decoded['version'];
    if (version != 1) {
      throw FormatException('Unsupported backup version: $version (expected 1)');
    }

    final tripData = decoded['trip'];
    if (tripData is! Map<String, dynamic>) {
      throw const FormatException('Backup is missing "trip" details object');
    }

    final tripName = (tripData['name'] as String?)?.trim();
    if (tripName == null || tripName.isEmpty) {
      throw const FormatException('Trip name is required in backup');
    }

    final totalBudgetPaise = tripData['totalBudgetPaise'];
    if (totalBudgetPaise is! int || totalBudgetPaise <= 0) {
      throw const FormatException('Valid totalBudgetPaise (> 0) is required');
    }

    final days = tripData['days'];
    if (days is! int || days < 1) {
      throw const FormatException('Valid days (>= 1) is required');
    }

    // 2. Validate travelers
    final rawTravelers = tripData['travelers'];
    if (rawTravelers is! List || rawTravelers.isEmpty) {
      throw const FormatException('At least one traveler is required in backup');
    }

    // Map old traveler ID -> new traveler ID and name
    final Map<String, String> oldToNewTravelerId = {};
    final List<Traveler> parsedTravelers = [];

    for (final raw in rawTravelers) {
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Invalid traveler object in backup');
      }
      final oldId = raw['id'] as String?;
      final name = (raw['name'] as String?)?.trim();
      final upiVpa = (raw['upiVpa'] as String?)?.trim();

      if (name == null || name.isEmpty) {
        throw const FormatException('Traveler name cannot be blank');
      }

      final newTravelerId = _uuid.v4();
      if (oldId != null) {
        oldToNewTravelerId[oldId] = newTravelerId;
      }

      parsedTravelers.add(
        Traveler(
          id: newTravelerId,
          tripId: '', // Will be set to newTripId
          name: name,
          upiVpa: (upiVpa != null && upiVpa.isNotEmpty) ? upiVpa : null,
        ),
      );
    }

    // 3. Validate category allocations
    final rawAllocations = tripData['categoryAllocations'];
    final Map<String, int> allocations = {};
    if (rawAllocations is Map) {
      for (final entry in rawAllocations.entries) {
        final cat = entry.key.toString();
        final pct = entry.value;
        if (pct is int) {
          allocations[cat] = pct;
        }
      }
    }

    if (allocations.isEmpty) {
      allocations.addAll(TripCategory.defaultPercentages);
    } else {
      final totalPercent = allocations.values.fold<int>(0, (sum, p) => sum + p);
      if (totalPercent != 100) {
        throw FormatException(
          'Category allocations must sum to 100% (got $totalPercent%)',
        );
      }
    }

    // 4. Validate expenses
    final rawExpenses = decoded['expenses'];
    final List<Map<String, dynamic>> parsedExpenses = [];

    if (rawExpenses is List) {
      for (final raw in rawExpenses) {
        if (raw is! Map<String, dynamic>) continue;

        final desc = (raw['description'] as String?)?.trim() ?? 'Expense';
        final amountPaise = raw['amountPaise'];
        if (amountPaise is! int || amountPaise <= 0) {
          throw const FormatException('Expense amount must be a positive integer in paise');
        }

        final category = (raw['category'] as String?) ?? 'Buffer';
        final oldPayer = raw['paidBy'] as String?;
        final newPayer = oldToNewTravelerId[oldPayer];
        if (newPayer == null) {
          throw FormatException('Expense "$desc" references unknown payer ID: $oldPayer');
        }

        final rawSplits = raw['splits'];
        if (rawSplits is! List || rawSplits.isEmpty) {
          throw FormatException('Expense "$desc" must have at least one split share');
        }

        final List<ExpenseSplitModel> splits = [];
        int splitSum = 0;
        final newExpenseId = _uuid.v4();

        for (final s in rawSplits) {
          if (s is! Map<String, dynamic>) continue;
          final oldTravId = s['travelerId'] as String?;
          final sharePaise = s['sharePaise'];
          final newTravId = oldToNewTravelerId[oldTravId];

          if (newTravId == null) {
            throw FormatException('Split share references unknown traveler ID: $oldTravId');
          }
          if (sharePaise is! int || sharePaise < 0) {
            throw const FormatException('Split share paise must be non-negative');
          }

          splits.add(
            ExpenseSplitModel(
              expenseId: newExpenseId,
              travelerId: newTravId,
              sharePaise: sharePaise,
            ),
          );
          splitSum += sharePaise;
        }

        // Strict integer paise invariant check
        if (splitSum != amountPaise) {
          throw FormatException(
            'Expense "$desc" splits sum ($splitSum paise) does not equal total amount ($amountPaise paise)',
          );
        }

        final createdAtStr = raw['createdAt'] as String?;
        final createdAt = (createdAtStr != null)
            ? DateTime.tryParse(createdAtStr)?.toLocal() ?? DateTime.now()
            : DateTime.now();

        parsedExpenses.add({
          'id': newExpenseId,
          'description': desc,
          'amountPaise': amountPaise,
          'category': category,
          'paidBy': newPayer,
          'source': (raw['source'] as String?) ?? 'backup',
          'confirmed': (raw['confirmed'] as bool?) ?? true,
          'upiTxnId': raw['upiTxnId'] as String?,
          'createdAt': createdAt,
          'splits': splits,
        });
      }
    }

    // 5. Atomic SQLite Transaction
    final newTripId = _uuid.v4();
    final now = DateTime.now();

    await _db.transaction(() async {
      // 5.1 Insert Trip
      await _db.into(_db.trips).insert(
            TripsCompanion.insert(
              id: newTripId,
              name: tripName,
              totalBudgetPaise: totalBudgetPaise,
              days: days,
              createdAt: now,
            ),
          );

      // 5.2 Insert Travelers
      for (final t in parsedTravelers) {
        await _db.into(_db.travelers).insert(
              TravelersCompanion.insert(
                id: t.id,
                tripId: newTripId,
                name: t.name,
                upiVpa: Value(t.upiVpa),
              ),
            );
      }

      // 5.3 Insert Category Allocations
      for (final entry in allocations.entries) {
        await _db.into(_db.categoryAllocations).insert(
              CategoryAllocationsCompanion.insert(
                tripId: newTripId,
                category: entry.key,
                percent: entry.value,
              ),
            );
      }

      // 5.4 Insert Expenses & Splits
      for (final exp in parsedExpenses) {
        final expenseId = exp['id'] as String;
        await _db.into(_db.expenses).insert(
              ExpensesCompanion.insert(
                id: expenseId,
                tripId: newTripId,
                description: exp['description'] as String,
                amountPaise: exp['amountPaise'] as int,
                category: exp['category'] as String,
                paidBy: exp['paidBy'] as String,
                source: Value(exp['source'] as String),
                confirmed: Value(exp['confirmed'] as bool),
                upiTxnId: Value(exp['upiTxnId'] as String?),
                createdAt: exp['createdAt'] as DateTime,
              ),
            );

        final splits = exp['splits'] as List<ExpenseSplitModel>;
        for (final s in splits) {
          await _db.into(_db.expenseSplits).insert(
                ExpenseSplitsCompanion.insert(
                  expenseId: expenseId,
                  travelerId: s.travelerId,
                  sharePaise: s.sharePaise,
                ),
              );
        }
      }
    });

    return newTripId;
  }
}
