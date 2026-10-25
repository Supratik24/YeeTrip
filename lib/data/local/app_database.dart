import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Trips,
    Travelers,
    CategoryAllocations,
    Expenses,
    ExpenseSplits,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? NativeDatabase.memory());

  /// For test instances.
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;

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
          if (from < 1) {
            await m.createAll();
          }
        },
      );
}
