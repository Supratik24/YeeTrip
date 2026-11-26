import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/data/local/app_database.dart' hide Traveler;
import 'package:yeetrip/data/repositories/expense_comment_repository.dart';
import 'package:yeetrip/data/repositories/expense_repository.dart';
import 'package:yeetrip/data/repositories/itinerary_repository.dart';
import 'package:yeetrip/data/repositories/trip_repository.dart';

void main() {
  test('AppDatabase upgrades cleanly from schema v1 to v4 preserving existing rows',
      () async {
    final db = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (rawDb) {
          rawDb.execute('PRAGMA user_version = 1;');
          rawDb.execute('''
            CREATE TABLE trips (
              id TEXT NOT NULL PRIMARY KEY,
              name TEXT NOT NULL,
              total_budget_paise INTEGER NOT NULL,
              days INTEGER NOT NULL,
              currency TEXT NOT NULL DEFAULT 'INR',
              created_at INTEGER NOT NULL
            );
          ''');
          rawDb.execute('''
            CREATE TABLE travelers (
              id TEXT NOT NULL PRIMARY KEY,
              trip_id TEXT NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
              name TEXT NOT NULL,
              upi_vpa TEXT
            );
          ''');
          rawDb.execute('''
            CREATE TABLE category_allocations (
              trip_id TEXT NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
              category TEXT NOT NULL,
              percent INTEGER NOT NULL,
              PRIMARY KEY (trip_id, category)
            );
          ''');
          rawDb.execute('''
            CREATE TABLE expenses (
              id TEXT NOT NULL PRIMARY KEY,
              trip_id TEXT NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
              description TEXT NOT NULL,
              amount_paise INTEGER NOT NULL,
              category TEXT NOT NULL,
              paid_by TEXT NOT NULL REFERENCES travelers(id) ON DELETE CASCADE,
              source TEXT NOT NULL DEFAULT 'manual',
              upi_txn_id TEXT,
              confirmed INTEGER NOT NULL DEFAULT 1,
              created_at INTEGER NOT NULL
            );
          ''');
          rawDb.execute('''
            CREATE TABLE expense_splits (
              expense_id TEXT NOT NULL REFERENCES expenses(id) ON DELETE CASCADE,
              traveler_id TEXT NOT NULL REFERENCES travelers(id) ON DELETE CASCADE,
              share_paise INTEGER NOT NULL,
              PRIMARY KEY (expense_id, traveler_id)
            );
          ''');
          rawDb.execute(
            "INSERT INTO trips (id, name, total_budget_paise, days, currency, created_at) "
            "VALUES ('old-trip', 'Legacy Goa', 4000000, 4, 'INR', 1760000000);",
          );
          rawDb.execute(
            "INSERT INTO travelers (id, trip_id, name) VALUES ('old-trav', 'old-trip', 'Aarav');",
          );
          rawDb.execute(
            "INSERT INTO expenses (id, trip_id, description, amount_paise, category, paid_by, created_at) "
            "VALUES ('old-exp', 'old-trip', 'Old Dinner', 120000, 'Food', 'old-trav', 1760000100);",
          );
          rawDb.execute(
            "INSERT INTO expense_splits (expense_id, traveler_id, share_paise) "
            "VALUES ('old-exp', 'old-trav', 120000);",
          );
        },
      ),
    );

    final tripRepo = DriftTripRepository(db);
    final expenseRepo = DriftExpenseRepository(db);
    final itineraryRepo = DriftItineraryRepository(db);
    final commentRepo = DriftExpenseCommentRepository(db);

    final legacyTrip = await tripRepo.getTripById('old-trip');
    expect(legacyTrip, isNotNull);
    expect(legacyTrip!.name, equals('Legacy Goa'));

    final legacyExpenses = await expenseRepo.getExpenses('old-trip');
    expect(legacyExpenses.length, equals(1));
    expect(legacyExpenses.first.tags, isEmpty);

    // Ensure v4 tables work on the upgraded database
    await itineraryRepo.addItem(
      tripId: 'old-trip',
      dayNumber: 1,
      title: 'Upgraded Activity',
    );
    await commentRepo.addComment(
      expenseId: 'old-exp',
      tripId: 'old-trip',
      authorName: 'Aarav',
      body: 'Upgraded Comment',
    );

    final updatedTrip = await tripRepo.getTripById('old-trip');
    final updatedExpenses = await expenseRepo.getExpenses('old-trip');
    expect(updatedTrip!.itineraryTotalCount, equals(1));
    expect(updatedExpenses.first.commentCount, equals(1));

    await db.close();
  });
}
