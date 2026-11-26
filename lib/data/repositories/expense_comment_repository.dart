import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../features/expenses/domain/expense_comment_model.dart';
import '../local/app_database.dart';

/// Clean interface for per-expense group comments and dispute tracking.
abstract class ExpenseCommentRepository {
  Future<List<ExpenseCommentModel>> getCommentsForExpense(String expenseId);
  Stream<List<ExpenseCommentModel>> watchCommentsForExpense(String expenseId);
  Future<String> addComment({
    required String expenseId,
    required String tripId,
    String? authorTravelerId,
    required String authorName,
    required String body,
    bool isDispute = false,
  });
  Future<void> setDisputeResolved(String commentId, bool resolved);
  Future<void> deleteComment(String commentId);
}

/// Drift implementation of [ExpenseCommentRepository].
class DriftExpenseCommentRepository implements ExpenseCommentRepository {
  final AppDatabase _db;
  final Uuid _uuid;

  DriftExpenseCommentRepository(this._db, [Uuid? uuid])
      : _uuid = uuid ?? const Uuid();

  void _notifyExpensesUpdated() {
    _db.notifyUpdates(
      {TableUpdate.onTable(_db.expenses, kind: UpdateKind.update)},
    );
  }

  @override
  Future<List<ExpenseCommentModel>> getCommentsForExpense(
    String expenseId,
  ) async {
    final rows = await (_db.select(_db.expenseComments)
          ..where((c) => c.expenseId.equals(expenseId))
          ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
        .get();
    return rows.map(_mapRow).toList();
  }

  @override
  Stream<List<ExpenseCommentModel>> watchCommentsForExpense(
    String expenseId,
  ) {
    return (_db.select(_db.expenseComments)
          ..where((c) => c.expenseId.equals(expenseId))
          ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
        .watch()
        .map((rows) => rows.map(_mapRow).toList());
  }

  @override
  Future<String> addComment({
    required String expenseId,
    required String tripId,
    String? authorTravelerId,
    required String authorName,
    required String body,
    bool isDispute = false,
  }) async {
    final cleanBody = body.trim();
    if (cleanBody.isEmpty) {
      throw ArgumentError('Comment cannot be empty');
    }

    final id = _uuid.v4();
    await _db.into(_db.expenseComments).insert(
          ExpenseCommentsCompanion.insert(
            id: id,
            expenseId: expenseId,
            tripId: tripId,
            authorTravelerId: Value(authorTravelerId),
            authorName: authorName.trim().isNotEmpty ? authorName.trim() : 'Traveler',
            body: cleanBody,
            isDispute: Value(isDispute),
            isResolved: const Value(false),
            createdAt: DateTime.now(),
          ),
        );
    _notifyExpensesUpdated();
    return id;
  }

  @override
  Future<void> setDisputeResolved(String commentId, bool resolved) async {
    await (_db.update(_db.expenseComments)..where((c) => c.id.equals(commentId)))
        .write(
      ExpenseCommentsCompanion(isResolved: Value(resolved)),
    );
    _notifyExpensesUpdated();
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await (_db.delete(_db.expenseComments)..where((c) => c.id.equals(commentId)))
        .go();
    _notifyExpensesUpdated();
  }

  ExpenseCommentModel _mapRow(ExpenseComment row) {
    return ExpenseCommentModel(
      id: row.id,
      expenseId: row.expenseId,
      tripId: row.tripId,
      authorTravelerId: row.authorTravelerId,
      authorName: row.authorName,
      body: row.body,
      isDispute: row.isDispute,
      isResolved: row.isResolved,
      createdAt: row.createdAt,
    );
  }
}
