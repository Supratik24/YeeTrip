import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/data/local/app_database.dart' hide Traveler;
import 'package:yeetrip/data/repositories/trip_repository.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';
import 'package:yeetrip/features/trips/services/trip_backup_service.dart';

void main() {
  late AppDatabase db;
  late DriftTripRepository tripRepo;
  late TripBackupService backupService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tripRepo = DriftTripRepository(db);
    backupService = TripBackupService(db);
  });

  tearDown(() async {
    await db.close();
  });

  final testTrip = TripWithDetails(
    id: 'original-trip-id',
    name: 'Jaipur Heritage Tour 🏰',
    totalBudgetPaise: 8000000, // ₹80,000
    days: 4,
    currency: 'INR',
    createdAt: DateTime.utc(2026, 10, 15, 10, 30),
    travelers: const [
      Traveler(id: 't-1', tripId: 'original-trip-id', name: 'Aarav', upiVpa: 'aarav@okhdfc'),
      Traveler(id: 't-2', tripId: 'original-trip-id', name: 'Diya', upiVpa: 'diya@icici'),
    ],
    categoryAllocations: const {
      'Stay': 40,
      'Food': 25,
      'Transport': 15,
      'Activities': 10,
      'Shopping': 5,
      'Buffer': 5,
    },
    totalSpentPaise: 2500000,
  );

  final testExpenses = [
    ExpenseWithSplits(
      id: 'e-1',
      tripId: 'original-trip-id',
      description: 'Heritage Haveli Hotel',
      amountPaise: 2000000,
      category: 'Stay',
      paidBy: 't-1',
      source: 'manual',
      confirmed: true,
      createdAt: DateTime.utc(2026, 10, 15, 12, 0),
      splits: const [
        ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-1', sharePaise: 1000000),
        ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-2', sharePaise: 1000000),
      ],
    ),
    ExpenseWithSplits(
      id: 'e-2',
      tripId: 'original-trip-id',
      description: 'Amer Fort Guide',
      amountPaise: 500000,
      category: 'Activities',
      paidBy: 't-2',
      source: 'manual',
      confirmed: true,
      createdAt: DateTime.utc(2026, 10, 16, 9, 30),
      splits: const [
        ExpenseSplitModel(expenseId: 'e-2', travelerId: 't-1', sharePaise: 250000),
        ExpenseSplitModel(expenseId: 'e-2', travelerId: 't-2', sharePaise: 250000),
      ],
    ),
  ];

  group('TripBackupService Export Tests', () {
    test('exportTripToJson generates schema-compliant formatted JSON', () {
      final jsonStr = TripBackupService.exportTripToJson(
        trip: testTrip,
        expenses: testExpenses,
      );

      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(decoded['version'], equals(1));
      expect(decoded['app'], equals('YeeTrip'));
      expect(decoded['trip']['name'], equals('Jaipur Heritage Tour 🏰'));
      expect(decoded['trip']['totalBudgetPaise'], equals(8000000));
      expect(decoded['trip']['days'], equals(4));

      final travelers = decoded['trip']['travelers'] as List;
      expect(travelers.length, equals(2));
      expect(travelers[0]['name'], equals('Aarav'));
      expect(travelers[0]['upiVpa'], equals('aarav@okhdfc'));

      final allocations = decoded['trip']['categoryAllocations'] as Map<String, dynamic>;
      expect(allocations['Stay'], equals(40));

      final expenses = decoded['expenses'] as List;
      expect(expenses.length, equals(2));
      expect(expenses[0]['description'], equals('Heritage Haveli Hotel'));
      expect(expenses[0]['amountPaise'], equals(2000000));
      expect(expenses[0]['splits'].length, equals(2));
    });
  });

  group('TripBackupService Restore Tests', () {
    test('successfully restores full trip with travelers, allocations, and expenses into database',
        () async {
      final jsonStr = TripBackupService.exportTripToJson(
        trip: testTrip,
        expenses: testExpenses,
      );

      final newTripId = await backupService.restoreTripFromJson(jsonStr);
      expect(newTripId, isNotEmpty);
      expect(newTripId, isNot(equals('original-trip-id'))); // Remapped to unique UUID

      // Verify loaded from DB via TripRepository
      final loaded = await tripRepo.getTripById(newTripId);
      expect(loaded, isNotNull);
      expect(loaded!.name, equals('Jaipur Heritage Tour 🏰'));
      expect(loaded.totalBudgetPaise, equals(8000000));
      expect(loaded.days, equals(4));
      expect(loaded.travelers.length, equals(2));

      final travelerNames = loaded.travelers.map((t) => t.name).toList();
      expect(travelerNames, containsAll(['Aarav', 'Diya']));

      final aarav = loaded.travelers.firstWhere((t) => t.name == 'Aarav');
      expect(aarav.upiVpa, equals('aarav@okhdfc'));

      // Check category allocations
      expect(loaded.categoryAllocations['Stay'], equals(40));
      expect(loaded.categoryAllocations['Food'], equals(25));

      // Check total spent calculated correctly from imported expenses
      expect(loaded.totalSpentPaise, equals(2500000));
    });

    test('rejects invalid JSON syntax', () async {
      expect(
        () => backupService.restoreTripFromJson('not a valid json {{{{'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects unsupported backup version', () async {
      final invalid = {
        'version': 99,
        'app': 'YeeTrip',
        'trip': {
          'name': 'Test',
          'totalBudgetPaise': 500000,
          'days': 2,
          'travelers': [{'id': 't1', 'name': 'Bob'}],
        },
      };

      expect(
        () => backupService.restoreTripFromJson(jsonEncode(invalid)),
        throwsA(
          predicate<FormatException>((e) => e.message.contains('Unsupported backup version')),
        ),
      );
    });

    test('rejects allocations that do not sum to 100%', () async {
      final invalid = {
        'version': 1,
        'trip': {
          'name': 'Test',
          'totalBudgetPaise': 500000,
          'days': 2,
          'categoryAllocations': {
            'Stay': 40,
            'Food': 40, // Sum = 80%, not 100%
          },
          'travelers': [{'id': 't1', 'name': 'Bob'}],
        },
      };

      expect(
        () => backupService.restoreTripFromJson(jsonEncode(invalid)),
        throwsA(
          predicate<FormatException>(
            (e) => e.message.contains('Category allocations must sum to 100%'),
          ),
        ),
      );
    });

    test('rejects expenses where split shares do not match expense amount', () async {
      final invalid = {
        'version': 1,
        'trip': {
          'name': 'Test',
          'totalBudgetPaise': 500000,
          'days': 2,
          'travelers': [{'id': 't1', 'name': 'Bob'}],
        },
        'expenses': [
          {
            'description': 'Snacks',
            'amountPaise': 10000,
            'category': 'Food',
            'paidBy': 't1',
            'splits': [
              {'travelerId': 't1', 'sharePaise': 9000}, // Sum = 9000, expected 10000
            ],
          }
        ],
      };

      expect(
        () => backupService.restoreTripFromJson(jsonEncode(invalid)),
        throwsA(
          predicate<FormatException>((e) => e.message.contains('splits sum')),
        ),
      );
    });
  });
}
