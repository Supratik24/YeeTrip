import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

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
  });
  Future<void> updateExpense({
    required String expenseId,
    required String description,
    required int amountPaise,
    required String category,
    required String paidBy,
    required DateTime createdAt,
    required List<ExpenseSplitModel> splits,
  });
  Future<void> deleteExpense(String expenseId);
}

/// Drift implementation of [ExpenseRepository].
class DriftExpenseRepository implements ExpenseRepository {
  final AppDatabase _db;
  final Uuid _uuid;

  DriftExpenseRepository(this._db, [Uuid? uuid]) : _uuid = uuid ?? const Uuid();

  @override
  Future<List<ExpenseWithSplits>> getExpenses(String tripId) async {
    final expenseRows = await (_db.select(_db.expenses)
          ..where((e) => e.tripId.equals(tripId))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .get();

    final List<ExpenseWithSplits> result = [];
    for (final row in expenseRows) {
      final splits = await _loadSplits(row.id);
      result.add(_rowToExpenseWithSplits(row, splits));
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
      final List<ExpenseWithSplits> result = [];
      for (final row in rows) {
        final splits = await _loadSplits(row.id);
        result.add(_rowToExpenseWithSplits(row, splits));
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
  }) async {
    final totalSplitPaise =
        splits.fold<int>(0, (sum, s) => sum + s.sharePaise);
    if (totalSplitPaise != amountPaise) {
      throw ArgumentError(
        'Splits sum ($totalSplitPaise paise) does not equal amount ($amountPaise paise)',
      );
    }

    await _db.transaction(() async {
      await (_db.update(_db.expenses)..where((e) => e.id.equals(expenseId)))
          .write(
        ExpensesCompanion(
          description: Value(description.trim()),
          amountPaise: Value(amountPaise),
          category: Value(category),
          paidBy: Value(paidBy),
          createdAt: Value(createdAt),
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
    // Foreign key cascade deletes splits automatically
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

  ExpenseWithSplits _rowToExpenseWithSplits(
    Expense row,
    List<ExpenseSplitModel> splits,
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
    );
  }
}
