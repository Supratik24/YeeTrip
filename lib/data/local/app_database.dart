import 'package:drift/drift.dart';

import 'connection/connection.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Trips,
    Travelers,
    CategoryAllocations,
    Expenses,
    ExpenseSplits,
    ItineraryItems,
    ExpenseComments,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? openAppConnection());

  /// For test instances.
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          // Unique index on (trip_id, upi_txn_id) where upi_txn_id is not null
          await customStatement(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_expenses_trip_upi '
            'ON expenses (trip_id, upi_txn_id) WHERE upi_txn_id IS NOT NULL;',
          );
        },
        beforeOpen: (details) async {
          // Foreign keys must be active for cascade delete
          await customStatement('PRAGMA foreign_keys = ON;');
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(trips, trips.destination);
            await m.addColumn(trips, trips.coverPhotoPath);
            await m.addColumn(trips, trips.status);
            await m.addColumn(trips, trips.startDate);
            await m.addColumn(trips, trips.endDate);
            await m.addColumn(travelers, travelers.avatarPath);
            await m.addColumn(expenses, expenses.receiptImagePath);
          }
          if (from < 3) {
            await m.addColumn(travelers, travelers.phone);
          }
          if (from < 4) {
            await m.addColumn(expenses, expenses.notes);
            await m.addColumn(expenses, expenses.tagsJson);
            await m.addColumn(expenses, expenses.originalCurrency);
            await m.addColumn(expenses, expenses.originalAmountPaise);
            await m.addColumn(expenses, expenses.exchangeRate);
            await m.createTable(itineraryItems);
            await m.createTable(expenseComments);
          }
        },
      );
}
