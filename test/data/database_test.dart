import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:yeetrip/data/local/app_database.dart';
import '../test_helper.dart';

void main() async {
  late AppDatabase db;

  void setUpDb() {
    db = AppDatabase(NativeDatabase.memory());
  }

  void tearDownDb() async {
    await db.close();
  }

  group('AppDatabase - Foreign Keys & Cascades', () {
    test('cascades delete from trip to travelers, allocations, and expenses', () async {
      setUpDb();

      // 1. Insert Trip
      const tripId = 'trip-1';
      await db.into(db.trips).insert(
            TripsCompanion.insert(
              id: tripId,
              name: 'Goa Trip',
              totalBudgetPaise: 5000000,
              days: 4,
              createdAt: DateTime.now(),
            ),
          );

      // 2. Insert Traveler
      const travelerId = 'trav-1';
      await db.into(db.travelers).insert(
            TravelersCompanion.insert(
              id: travelerId,
              tripId: tripId,
              name: 'Aarav',
            ),
          );

      // 3. Insert Category Allocation
      await db.into(db.categoryAllocations).insert(
            CategoryAllocationsCompanion.insert(
              tripId: tripId,
              category: 'Stay',
              percent: 30,
            ),
          );

      // 4. Insert Expense
      const expenseId = 'exp-1';
      await db.into(db.expenses).insert(
            ExpensesCompanion.insert(
              id: expenseId,
              tripId: tripId,
              description: 'Villa booking',
              amountPaise: 1500000,
              category: 'Stay',
              paidBy: travelerId,
              createdAt: DateTime.now(),
            ),
          );

      // 5. Insert Expense Split
      await db.into(db.expenseSplits).insert(
            ExpenseSplitsCompanion.insert(
              expenseId: expenseId,
              travelerId: travelerId,
              sharePaise: 1500000,
            ),
          );

      // Verify everything is present
      final tripsCount = await db.select(db.trips).get();
      final travCount = await db.select(db.travelers).get();
      final allocCount = await db.select(db.categoryAllocations).get();
      final expCount = await db.select(db.expenses).get();
      final splitCount = await db.select(db.expenseSplits).get();

      expect(tripsCount.length, 1);
      expect(travCount.length, 1);
      expect(allocCount.length, 1);
      expect(expCount.length, 1);
      expect(splitCount.length, 1);

      // Delete trip
      await (db.delete(db.trips)..where((t) => t.id.equals(tripId))).go();

      // Verify cascade deleted all child records
      final travAfter = await db.select(db.travelers).get();
      final allocAfter = await db.select(db.categoryAllocations).get();
      final expAfter = await db.select(db.expenses).get();
      final splitAfter = await db.select(db.expenseSplits).get();

      expect(travAfter.isEmpty, true);
      expect(allocAfter.isEmpty, true);
      expect(expAfter.isEmpty, true);
      expect(splitAfter.isEmpty, true);

      tearDownDb();
    });
  });

  group('AppDatabase - Partial Unique Index on (trip_id, upi_txn_id)', () {
    test('allows multiple null upi_txn_id for same trip', () async {
      setUpDb();

      const tripId = 'trip-2';
      await db.into(db.trips).insert(
            TripsCompanion.insert(
              id: tripId,
              name: 'Manali Trip',
              totalBudgetPaise: 2000000,
              days: 3,
              createdAt: DateTime.now(),
            ),
          );

      const travelerId = 'trav-2';
      await db.into(db.travelers).insert(
            TravelersCompanion.insert(
              id: travelerId,
              tripId: tripId,
              name: 'Rohan',
            ),
          );

      // Insert two expenses with null upi_txn_id
      await db.into(db.expenses).insert(
            ExpensesCompanion.insert(
              id: 'exp-null-1',
              tripId: tripId,
              description: 'Cash lunch',
              amountPaise: 50000,
              category: 'Food',
              paidBy: travelerId,
              createdAt: DateTime.now(),
            ),
          );

      await db.into(db.expenses).insert(
            ExpensesCompanion.insert(
              id: 'exp-null-2',
              tripId: tripId,
              description: 'Cash dinner',
              amountPaise: 80000,
              category: 'Food',
              paidBy: travelerId,
              createdAt: DateTime.now(),
            ),
          );

      final count = await db.select(db.expenses).get();
      expect(count.length, 2);

      tearDownDb();
    });

    test('rejects duplicate non-null upi_txn_id for same trip', () async {
      setUpDb();

      const tripId = 'trip-3';
      await db.into(db.trips).insert(
            TripsCompanion.insert(
              id: tripId,
              name: 'Kerala Trip',
              totalBudgetPaise: 3000000,
              days: 5,
              createdAt: DateTime.now(),
            ),
          );

      const travelerId = 'trav-3';
      await db.into(db.travelers).insert(
            TravelersCompanion.insert(
              id: travelerId,
              tripId: tripId,
              name: 'Priya',
            ),
          );

      // First expense with upi_txn_id
      await db.into(db.expenses).insert(
            ExpensesCompanion.insert(
              id: 'exp-upi-1',
              tripId: tripId,
              description: 'UPI Cafe',
              amountPaise: 45000,
              category: 'Food',
              paidBy: travelerId,
              createdAt: DateTime.now(),
            ).copyWith(upiTxnId: const Value('UPI123456789')),
          );

      // Second expense with duplicate upi_txn_id should throw SqliteException
      bool threw = false;
      try {
        await db.into(db.expenses).insert(
              ExpensesCompanion.insert(
                id: 'exp-upi-2',
                tripId: tripId,
                description: 'UPI Cafe Duplicate',
                amountPaise: 45000,
                category: 'Food',
                paidBy: travelerId,
                createdAt: DateTime.now(),
              ).copyWith(upiTxnId: const Value('UPI123456789')),
            );
      } catch (e) {
        threw = true;
      }
      expect(threw, true);

      tearDownDb();
    });
  });

  final ok = await runSuite('Database & Schema Tests');
  if (!ok) throw Exception('Database tests failed');
}
