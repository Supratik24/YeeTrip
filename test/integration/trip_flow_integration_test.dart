import 'package:drift/native.dart';
import 'package:yeetrip/core/constants/categories.dart';
import 'package:yeetrip/core/money.dart';
import 'package:yeetrip/data/local/app_database.dart';
import 'package:yeetrip/data/repositories/expense_repository.dart';
import 'package:yeetrip/data/repositories/trip_repository.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/expenses/domain/split_calculator.dart';
import 'package:yeetrip/features/settings/services/csv_generator.dart';
import 'package:yeetrip/features/settle/domain/settle_calculator.dart';
import '../test_helper.dart';

void main() async {
  group('Trip Flow Integration Test', () {
    test('Full lifecycle: create trip -> allocate budget -> log expenses -> settle up -> export CSV', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final tripRepo = DriftTripRepository(db);
      final expenseRepo = DriftExpenseRepository(db);

      try {
        // 1. Create Trip "Goa Roadtrip 2026"
        final tripId = await tripRepo.createTrip(
          name: 'Goa Roadtrip 2026',
          totalBudgetPaise: 15000000, // ₹1,50,000
          days: 5,
          travelerNames: ['Aarav', 'Rohan', 'Priya'],
        );

        final trip = await tripRepo.getTripById(tripId);
        expect(trip != null, true);
        expect(trip!.name, 'Goa Roadtrip 2026');
        expect(trip.travelers.length, 3);
        expect(trip.categoryAllocations.length, 6);

        // Verify default category allocations total 100%
        final totalPercent =
            trip.categoryAllocations.values.fold<int>(0, (sum, p) => sum + p);
        expect(totalPercent, 100);

        final aarav = trip.travelers.firstWhere((t) => t.name == 'Aarav');
        final rohan = trip.travelers.firstWhere((t) => t.name == 'Rohan');
        final priya = trip.travelers.firstWhere((t) => t.name == 'Priya');

        // 2. Add Expense 1: Aarav pays ₹15,000 for Stay, split equally among all 3
        final splitMap1 = SplitCalculator.calculateEqualSplit(
          totalPaise: 1500000,
          travelerIds: [aarav.id, rohan.id, priya.id],
        );
        final splits1 = splitMap1.entries
            .map((e) => ExpenseSplitModel(
                  expenseId: '',
                  travelerId: e.key,
                  sharePaise: e.value,
                ))
            .toList();
        expect(splits1.fold<int>(0, (sum, s) => sum + s.sharePaise), 1500000);

        await expenseRepo.addExpense(
          tripId: tripId,
          description: 'Beach Resort Stay',
          amountPaise: 1500000,
          category: TripCategory.stay.key,
          paidBy: aarav.id,
          createdAt: DateTime(2026, 10, 20, 14, 0),
          splits: splits1,
        );

        // 3. Add Expense 2: Rohan pays ₹4,500 for Food, split equally among all 3
        final splitMap2 = SplitCalculator.calculateEqualSplit(
          totalPaise: 450000,
          travelerIds: [aarav.id, rohan.id, priya.id],
        );
        final splits2 = splitMap2.entries
            .map((e) => ExpenseSplitModel(
                  expenseId: '',
                  travelerId: e.key,
                  sharePaise: e.value,
                ))
            .toList();
        expect(splits2.fold<int>(0, (sum, s) => sum + s.sharePaise), 450000);

        await expenseRepo.addExpense(
          tripId: tripId,
          description: 'Seafood Shack Dinner',
          amountPaise: 450000,
          category: TripCategory.food.key,
          paidBy: rohan.id,
          createdAt: DateTime(2026, 10, 20, 20, 30),
          splits: splits2,
        );

        // 4. Add Expense 3: Priya pays ₹100 for Toll, split equally among all 3
        // Demonstrates largest-remainder rounding: 3334, 3333, 3333 paise distributed
        // to travelers in deterministic sorted ID order.
        final sortedTravelerIds = [aarav.id, rohan.id, priya.id]..sort();
        final firstId = sortedTravelerIds.first;

        final splitMap3 = SplitCalculator.calculateEqualSplit(
          totalPaise: 10000,
          travelerIds: [aarav.id, rohan.id, priya.id],
        );
        expect(splitMap3[firstId], 3334);
        expect(splitMap3[sortedTravelerIds[1]], 3333);
        expect(splitMap3[sortedTravelerIds[2]], 3333);

        final splits3 = splitMap3.entries
            .map((e) => ExpenseSplitModel(
                  expenseId: '',
                  travelerId: e.key,
                  sharePaise: e.value,
                ))
            .toList();
        expect(splits3.fold<int>(0, (sum, s) => sum + s.sharePaise), 10000);

        await expenseRepo.addExpense(
          tripId: tripId,
          description: 'Mandovi Bridge Toll',
          amountPaise: 10000,
          category: TripCategory.transport.key,
          paidBy: priya.id,
          createdAt: DateTime(2026, 10, 21, 10, 15),
          splits: splits3,
        );

        // 5. Verify expenses from repository
        final expenses = await expenseRepo.getExpenses(tripId);
        expect(expenses.length, 3);

        final totalSpentPaise =
            expenses.fold<int>(0, (sum, e) => sum + e.amountPaise);
        expect(totalSpentPaise, 1960000); // ₹19,600
        expect(Money.formatRupees(totalSpentPaise), '₹19,600');

        // 6. Settle-Up Engine verification
        final travelerBalances = SettleCalculator.calculateBalances(
          travelers: trip.travelers,
          expenses: expenses,
        );

        expect(travelerBalances.length, 3);

        // Verify individual balances
        for (final bal in travelerBalances) {
          final isFirst = bal.travelerId == firstId;
          final expectedShare = 500000 + 150000 + (isFirst ? 3334 : 3333);
          expect(bal.sharePaise, expectedShare);
          expect(bal.netBalancePaise, bal.paidPaise - expectedShare);
        }

        // Net balances must sum to exactly 0 paise
        final netSum =
            travelerBalances.fold<int>(0, (sum, b) => sum + b.netBalancePaise);
        expect(netSum, 0);

        final aaravBal =
            travelerBalances.firstWhere((b) => b.travelerId == aarav.id);
        expect(aaravBal.paidPaise, 1500000);
        expect(aaravBal.netBalancePaise > 0, true); // Aarav is creditor

        // Compute greedy settlements
        final settlements =
            SettleCalculator.calculateSettlements(balances: travelerBalances);

        // Number of settlements must be <= n - 1 (3 - 1 = 2)
        expect(settlements.length <= 2, true);
        expect(settlements.length, 2);

        // Total payments received by Aarav must equal his net positive balance
        final totalReceivedByAarav = settlements
            .where((s) => s.toTravelerId == aarav.id)
            .fold<int>(0, (sum, s) => sum + s.amountPaise);
        expect(totalReceivedByAarav, aaravBal.netBalancePaise);

        // 7. Verify CSV Export
        final csv = CsvGenerator.generateCsv(trip: trip, expenses: expenses);
        expect(
          csv.contains(
            'date,description,category,paid_by,amount_inr,split_among',
          ),
          true,
        );
        expect(csv.contains('Beach Resort Stay'), true);
        expect(csv.contains('Seafood Shack Dinner'), true);
        expect(csv.contains('Mandovi Bridge Toll'), true);
        expect(csv.contains('15000.00'), true);
        expect(csv.contains('4500.00'), true);
        expect(csv.contains('100.00'), true);
      } finally {
        await db.close();
      }
    });
  });

  final ok = await runSuite('Trip Flow Integration Test');
  if (!ok) throw Exception('Integration test failed');
}
