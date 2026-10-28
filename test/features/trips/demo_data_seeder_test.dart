import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/data/local/app_database.dart';
import 'package:yeetrip/data/repositories/expense_repository.dart';
import 'package:yeetrip/data/repositories/trip_repository.dart';
import 'package:yeetrip/features/trips/services/demo_data_seeder.dart';

void main() {
  group('DemoDataSeeder', () {
    late AppDatabase db;
    late DriftTripRepository tripRepo;
    late DriftExpenseRepository expenseRepo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      tripRepo = DriftTripRepository(db);
      expenseRepo = DriftExpenseRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('seeds complete demo trip with all categories and expenses', () async {
      final tripId = await DemoDataSeeder.seedDemoTrip(
        tripRepo: tripRepo,
        expenseRepo: expenseRepo,
      );

      final trip = await tripRepo.getTripById(tripId);
      expect(trip, isNotNull);
      expect(trip!.name, equals(DemoDataSeeder.demoTripName));
      expect(trip.totalBudgetPaise, equals(6000000));
      expect(trip.days, equals(4));
      expect(trip.travelers.length, equals(4));

      final expenses = await expenseRepo.getExpenses(tripId);
      expect(expenses.length, equals(5));

      // Check total spent
      // 16,000 + 8,400 + 5,200 + 7,200 + 1,800 = 38,600 rupees = 3,860,000 paise
      expect(trip.totalSpentPaise, equals(3860000));
      expect(trip.remainingBudgetPaise, equals(6000000 - 3860000));

      // Verify each expense splits sum exactly to total
      for (final exp in expenses) {
        final splitSum = exp.splits.fold<int>(0, (s, sp) => s + sp.sharePaise);
        expect(splitSum, equals(exp.amountPaise));
      }
    });
  });
}
