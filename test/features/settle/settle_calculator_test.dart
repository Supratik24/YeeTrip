import 'dart:math';

import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/expenses/domain/split_calculator.dart';
import 'package:yeetrip/features/settle/domain/settle_calculator.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';
import '../../test_helper.dart';

void main() async {
  group('SettleCalculator - Deterministic Scenarios', () {
    test('3 friends simple dinner split: 2 settlements clear all debt', () {
      final travelers = [
        const Traveler(id: 't_a', tripId: 'trip_1', name: 'Aarav'),
        const Traveler(id: 't_b', tripId: 'trip_1', name: 'Bhavna'),
        const Traveler(id: 't_c', tripId: 'trip_1', name: 'Chirag'),
      ];

      // Aarav paid ₹300 (30,000 paise) for dinner split equally
      final splits = SplitCalculator.calculateEqualSplit(
        totalPaise: 30000,
        travelerIds: ['t_a', 't_b', 't_c'],
      );

      final expenses = [
        ExpenseWithSplits(
          id: 'exp_1',
          tripId: 'trip_1',
          description: 'Dinner',
          amountPaise: 30000,
          category: 'Food',
          paidBy: 't_a',
          createdAt: DateTime.now(),
          splits: splits.entries
              .map((e) => ExpenseSplitModel(
                    expenseId: 'exp_1',
                    travelerId: e.key,
                    sharePaise: e.value,
                  ))
              .toList(),
        ),
      ];

      final balances = SettleCalculator.calculateBalances(
        travelers: travelers,
        expenses: expenses,
      );

      final aarav = balances.firstWhere((b) => b.travelerId == 't_a');
      final bhavna = balances.firstWhere((b) => b.travelerId == 't_b');
      final chirag = balances.firstWhere((b) => b.travelerId == 't_c');

      expect(aarav.paidPaise, 30000);
      expect(aarav.sharePaise, 10000);
      expect(aarav.netBalancePaise, 20000); // Creditor +₹200

      expect(bhavna.paidPaise, 0);
      expect(bhavna.sharePaise, 10000);
      expect(bhavna.netBalancePaise, -10000); // Debtor -₹100

      expect(chirag.paidPaise, 0);
      expect(chirag.sharePaise, 10000);
      expect(chirag.netBalancePaise, -10000); // Debtor -₹100

      final settlements = SettleCalculator.calculateSettlements(
        balances: balances,
      );

      // Must take at most n-1 = 2 settlements
      expect(settlements.length <= 2, true);
      final totalSettled =
          settlements.fold<int>(0, (s, p) => s + p.amountPaise);
      expect(totalSettled, 20000);

      // Verify that after settlements, all balances are exactly 0
      final finalBalances = <String, int>{
        for (final b in balances) b.travelerId: b.netBalancePaise,
      };
      for (final s in settlements) {
        finalBalances[s.fromTravelerId] =
            finalBalances[s.fromTravelerId]! + s.amountPaise;
        finalBalances[s.toTravelerId] =
            finalBalances[s.toTravelerId]! - s.amountPaise;
      }
      expect(finalBalances.values.every((b) => b == 0), true);
    });

    test('already balanced trip yields 0 settlements', () {
      final travelers = [
        const Traveler(id: 't1', tripId: 'trip_1', name: 'User 1'),
        const Traveler(id: 't2', tripId: 'trip_1', name: 'User 2'),
      ];

      // Each paid ₹50 for their own expense
      final expenses = [
        ExpenseWithSplits(
          id: 'exp_1',
          tripId: 'trip_1',
          description: 'Lunch 1',
          amountPaise: 5000,
          category: 'Food',
          paidBy: 't1',
          createdAt: DateTime.now(),
          splits: const [
            ExpenseSplitModel(expenseId: 'exp_1', travelerId: 't1', sharePaise: 5000),
          ],
        ),
        ExpenseWithSplits(
          id: 'exp_2',
          tripId: 'trip_1',
          description: 'Lunch 2',
          amountPaise: 5000,
          category: 'Food',
          paidBy: 't2',
          createdAt: DateTime.now(),
          splits: const [
            ExpenseSplitModel(expenseId: 'exp_2', travelerId: 't2', sharePaise: 5000),
          ],
        ),
      ];

      final balances = SettleCalculator.calculateBalances(
        travelers: travelers,
        expenses: expenses,
      );
      final settlements = SettleCalculator.calculateSettlements(
        balances: balances,
      );
      expect(settlements.isEmpty, true);
    });
  });

  group('SettleCalculator - Property-style Tests (1,000 Random Expense Sets)', () {
    test('greedy settlement always zeroes every balance and produces <= n-1 settlements', () {
      final random = Random(999);

      for (int i = 0; i < 1000; i++) {
        final travelerCount = random.nextInt(6) + 2; // 2 to 7 people
        final travelers = List.generate(
          travelerCount,
          (idx) => Traveler(
            id: 'trav_$idx',
            tripId: 'test_trip',
            name: 'Person $idx',
          ),
        );

        final expenseCount = random.nextInt(15) + 1; // 1 to 15 expenses
        final expenses = <ExpenseWithSplits>[];

        for (int e = 0; e < expenseCount; e++) {
          final payer = travelers[random.nextInt(travelerCount)];
          final amountPaise = random.nextInt(50000) + 10; // 10 paise to ₹500

          // Pick random subset of travelers for split
          final splitTravelers = travelers
              .where((_) => random.nextBool() || true)
              .map((t) => t.id)
              .toSet()
              .toList();
          if (splitTravelers.isEmpty) {
            splitTravelers.add(payer.id);
          }

          final splitMap = SplitCalculator.calculateEqualSplit(
            totalPaise: amountPaise,
            travelerIds: splitTravelers,
          );

          expenses.add(
            ExpenseWithSplits(
              id: 'exp_$e',
              tripId: 'test_trip',
              description: 'Expense $e',
              amountPaise: amountPaise,
              category: 'Food',
              paidBy: payer.id,
              createdAt: DateTime.now(),
              splits: splitMap.entries
                  .map((entry) => ExpenseSplitModel(
                        expenseId: 'exp_$e',
                        travelerId: entry.key,
                        sharePaise: entry.value,
                      ))
                  .toList(),
            ),
          );
        }

        final balances = SettleCalculator.calculateBalances(
          travelers: travelers,
          expenses: expenses,
        );

        final settlements = SettleCalculator.calculateSettlements(
          balances: balances,
        );

        // Required property: At most n - 1 settlements
        expect(
          settlements.length <= travelerCount - 1,
          true,
          reason: 'Iteration $i: settlements (${settlements.length}) exceeded n-1 (${travelerCount - 1})',
        );

        // Required property: After applying all settlements, every balance must be exactly 0
        final finalBalances = <String, int>{
          for (final b in balances) b.travelerId: b.netBalancePaise,
        };

        for (final payment in settlements) {
          expect(payment.amountPaise > 0, true);
          finalBalances[payment.fromTravelerId] =
              finalBalances[payment.fromTravelerId]! + payment.amountPaise;
          finalBalances[payment.toTravelerId] =
              finalBalances[payment.toTravelerId]! - payment.amountPaise;
        }

        expect(
          finalBalances.values.every((bal) => bal == 0),
          true,
          reason: 'Iteration $i: final balances were not all exactly 0: $finalBalances',
        );
      }
    });
  });

  final ok = await runSuite('Settle Calculator Tests');
  if (!ok) throw Exception('Settle calculator tests failed');
}
