import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../features/expenses/domain/expense_comment_model.dart';
import '../../features/expenses/domain/expense_model.dart';
import '../local/app_database.dart';

/// Clean interface for Expense data operations.
/// UI never talks to drift directly; it accesses data through this interface.
abstract class ExpenseRepository {
  Future<List<ExpenseWithSplits>> getExpenses(String tripId);
  Stream<List<ExpenseWithSplits>> watchExpenses(String tripId);
  Future<String> addExpense({
    required String tripId,
    required String description,
    required int amountPaise,
    required String category,
    required String paidBy,
    String source = 'manual',
    String? upiTxnId,
    bool confirmed = true,
    required DateTime createdAt,
    required List<ExpenseSplitModel> splits,
    String? receiptImagePath,
    String? notes,
    List<String> tags = const [],
    String? originalCurrency,
    int? originalAmountPaise,
    double? exchangeRate,
  });
  Future<void> updateExpense({
    required String expenseId,
    required String description,
    required int amountPaise,
    required String category,
    required String paidBy,
    required DateTime createdAt,
    required List<ExpenseSplitModel> splits,
    String? receiptImagePath,
    bool clearReceiptImage = false,
    String? notes,
    bool clearNotes = false,
    List<String>? tags,
    String? originalCurrency,
    int? originalAmountPaise,
    double? exchangeRate,
    bool clearOriginalCurrency = false,
  });
  Future<void> deleteExpense(String expenseId);
}

/// Drift implementation of [ExpenseRepository].
class DriftExpenseRepository implements ExpenseRepository {
  final AppDatabase _db;
  final Uuid _uuid;

  DriftExpenseRepository(this._db, [Uuid? uuid]) : _uuid = uuid ?? const Uuid();

  static List<String> normalizeTags(Iterable<String> rawTags) {
    final seen = <String>{};
    final result = <String>[];
    for (final raw in rawTags) {
      var clean = raw.trim();
      while (clean.startsWith('#')) {
        clean = clean.substring(1).trim();
      }
      if (clean.isEmpty) continue;
      final key = clean.toLowerCase();
      if (seen.add(key)) {
        result.add(clean);
      }
    }
    return result;
  }

  static String encodeTags(Iterable<String> tags) {
    return jsonEncode(normalizeTags(tags));
  }

  static List<String> decodeTags(String? rawJson) {
    if (rawJson == null || rawJson.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is List) {
        return normalizeTags(decoded.map((e) => e.toString()));
      }
    } catch (_) {}
    return const [];
  }

  @override
  Future<List<ExpenseWithSplits>> getExpenses(String tripId) async {
    final expenseRows = await (_db.select(_db.expenses)
          ..where((e) => e.tripId.equals(tripId))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .get();

    final commentStats = await _loadCommentStatsForTrip(tripId);

    final List<ExpenseWithSplits> result = [];
    for (final row in expenseRows) {
      final splits = await _loadSplits(row.id);
      result.add(_rowToExpenseWithSplits(row, splits, commentStats[row.id]));
    }
    return result;
  }

  @override
  Stream<List<ExpenseWithSplits>> watchExpenses(String tripId) {
    return (_db.select(_db.expenses)
          ..where((e) => e.tripId.equals(tripId))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .watch()
        .asyncMap((rows) async {
      final commentStats = await _loadCommentStatsForTrip(tripId);
      final List<ExpenseWithSplits> result = [];
      for (final row in rows) {
        final splits = await _loadSplits(row.id);
        result.add(_rowToExpenseWithSplits(row, splits, commentStats[row.id]));
      }
      return result;
    });
  }

  @override
  Future<String> addExpense({
    required String tripId,
    required String description,
    required int amountPaise,
    required String category,
    required String paidBy,
    String source = 'manual',
    String? upiTxnId,
    bool confirmed = true,
    required DateTime createdAt,
    required List<ExpenseSplitModel> splits,
    String? receiptImagePath,
    String? notes,
    List<String> tags = const [],
    String? originalCurrency,
    int? originalAmountPaise,
    double? exchangeRate,
  }) async {
    // Non-negotiable rule 3: splits must sum EXACTLY to the expense amount in paise.
    final totalSplitPaise =
        splits.fold<int>(0, (sum, s) => sum + s.sharePaise);
    if (totalSplitPaise != amountPaise) {
      throw ArgumentError(
        'Splits sum ($totalSplitPaise paise) does not equal amount ($amountPaise paise)',
      );
    }

    final expenseId = _uuid.v4();
    final trimmedNotes = notes?.trim();

    await _db.transaction(() async {
      await _db.into(_db.expenses).insert(
            ExpensesCompanion.insert(
              id: expenseId,
              tripId: tripId,
              description: description.trim(),
              amountPaise: amountPaise,
              category: category,
              paidBy: paidBy,
              source: Value(source),
              upiTxnId: Value(upiTxnId),
              confirmed: Value(confirmed),
              createdAt: createdAt,
              receiptImagePath: Value(receiptImagePath),
              notes: Value(
                trimmedNotes != null && trimmedNotes.isNotEmpty
                    ? trimmedNotes
                    : null,
              ),
              tagsJson: Value(encodeTags(tags)),
              originalCurrency: Value(originalCurrency),
              originalAmountPaise: Value(originalAmountPaise),
              exchangeRate: Value(exchangeRate),
            ),
          );

      for (final split in splits) {
        await _db.into(_db.expenseSplits).insert(
              ExpenseSplitsCompanion.insert(
                expenseId: expenseId,
                travelerId: split.travelerId,
                sharePaise: split.sharePaise,
              ),
            );
      }
    });

    return expenseId;
  }

  @override
  Future<void> updateExpense({
    required String expenseId,
    required String description,
    required int amountPaise,
    required String category,
    required String paidBy,
    required DateTime createdAt,
    required List<ExpenseSplitModel> splits,
    String? receiptImagePath,
    bool clearReceiptImage = false,
    String? notes,
    bool clearNotes = false,
    List<String>? tags,
    String? originalCurrency,
    int? originalAmountPaise,
    double? exchangeRate,
    bool clearOriginalCurrency = false,
  }) async {
    final totalSplitPaise =
        splits.fold<int>(0, (sum, s) => sum + s.sharePaise);
    if (totalSplitPaise != amountPaise) {
      throw ArgumentError(
        'Splits sum ($totalSplitPaise paise) does not equal amount ($amountPaise paise)',
      );
    }

    final trimmedNotes = notes?.trim();

    await _db.transaction(() async {
      await (_db.update(_db.expenses)..where((e) => e.id.equals(expenseId)))
          .write(
        ExpensesCompanion(
          description: Value(description.trim()),
          amountPaise: Value(amountPaise),
          category: Value(category),
          paidBy: Value(paidBy),
          createdAt: Value(createdAt),
          receiptImagePath: clearReceiptImage
              ? const Value(null)
              : (receiptImagePath != null
                  ? Value(receiptImagePath)
                  : const Value.absent()),
          notes: clearNotes
              ? const Value(null)
              : (trimmedNotes != null
                  ? Value(trimmedNotes.isNotEmpty ? trimmedNotes : null)
                  : const Value.absent()),
          tagsJson:
              tags != null ? Value(encodeTags(tags)) : const Value.absent(),
          originalCurrency: clearOriginalCurrency
              ? const Value(null)
              : (originalCurrency != null
                  ? Value(originalCurrency)
                  : const Value.absent()),
          originalAmountPaise: clearOriginalCurrency
              ? const Value(null)
              : (originalAmountPaise != null
                  ? Value(originalAmountPaise)
                  : const Value.absent()),
          exchangeRate: clearOriginalCurrency
              ? const Value(null)
              : (exchangeRate != null
                  ? Value(exchangeRate)
                  : const Value.absent()),
        ),
      );

      // Re-insert splits
      await (_db.delete(_db.expenseSplits)
            ..where((s) => s.expenseId.equals(expenseId)))
          .go();

      for (final split in splits) {
        await _db.into(_db.expenseSplits).insert(
              ExpenseSplitsCompanion.insert(
                expenseId: expenseId,
                travelerId: split.travelerId,
                sharePaise: split.sharePaise,
              ),
            );
      }
    });
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    // Foreign key cascade deletes splits & comments automatically
    await (_db.delete(_db.expenses)..where((e) => e.id.equals(expenseId))).go();
  }

  Future<List<ExpenseSplitModel>> _loadSplits(String expenseId) async {
    final splitRows = await (_db.select(_db.expenseSplits)
          ..where((s) => s.expenseId.equals(expenseId)))
        .get();

    return splitRows
        .map((s) => ExpenseSplitModel(
              expenseId: s.expenseId,
              travelerId: s.travelerId,
              sharePaise: s.sharePaise,
            ))
        .toList();
  }

  Future<Map<String, ExpenseCommentStats>> _loadCommentStatsForTrip(
    String tripId,
  ) async {
    final rows = await (_db.select(_db.expenseComments)
          ..where((c) => c.tripId.equals(tripId)))
        .get();

    final map = <String, ExpenseCommentStats>{};
    for (final row in rows) {
      final prev = map[row.expenseId] ?? const ExpenseCommentStats();
      map[row.expenseId] = ExpenseCommentStats(
        totalCount: prev.totalCount + 1,
        openDisputeCount:
            prev.openDisputeCount + (row.isDispute && !row.isResolved ? 1 : 0),
      );
    }
    return map;
  }

  ExpenseWithSplits _rowToExpenseWithSplits(
    Expense row,
    List<ExpenseSplitModel> splits,
    ExpenseCommentStats? commentStats,
  ) {
    return ExpenseWithSplits(
      id: row.id,
      tripId: row.tripId,
      description: row.description,
      amountPaise: row.amountPaise,
      category: row.category,
      paidBy: row.paidBy,
      source: row.source,
      upiTxnId: row.upiTxnId,
      confirmed: row.confirmed,
      createdAt: row.createdAt,
      splits: splits,
      receiptImagePath: row.receiptImagePath,
      notes: row.notes,
      tags: decodeTags(row.tagsJson),
      originalCurrency: row.originalCurrency,
      originalAmountPaise: row.originalAmountPaise,
      exchangeRate: row.exchangeRate,
      commentCount: commentStats?.totalCount ?? 0,
      openDisputeCount: commentStats?.openDisputeCount ?? 0,
    );
  }
}
