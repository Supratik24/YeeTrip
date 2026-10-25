import 'dart:math';

import 'package:yeetrip/core/constants/categories.dart';
import 'package:yeetrip/features/budget/domain/rebalance.dart';
import '../../test_helper.dart';

void main() async {
  group('BudgetRebalancer - Edge Cases', () {
    test('works at 100: sets others to zero and sums to 100', () {
      final initial = TripCategory.defaultPercentages; // 30, 25, 20, 15, 5, 5
      final result = BudgetRebalancer.rebalance(
        currentAllocations: initial,
        changedCategory: 'Stay',
        newPercent: 100,
      );

      expect(result['Stay'], 100);
      for (final cat in TripCategory.all) {
        if (cat.key != 'Stay') {
          expect(result[cat.key], 0);
        }
      }
      final sum = result.values.fold<int>(0, (s, v) => s + v);
      expect(sum, 100);
    });

    test('works at 0: sets category to 0 and others sum to 100', () {
      final initial = TripCategory.defaultPercentages;
      final result = BudgetRebalancer.rebalance(
        currentAllocations: initial,
        changedCategory: 'Stay',
        newPercent: 0,
      );

      expect(result['Stay'], 0);
      final sum = result.values.fold<int>(0, (s, v) => s + v);
      expect(sum, 100);
      expect(result.values.every((v) => v >= 0), true);
    });

    test('works when others were all zero: spreads remainder equally without negatives', () {
      final initial = {
        'Stay': 100,
        'Food': 0,
        'Transport': 0,
        'Activities': 0,
        'Shopping': 0,
        'Buffer': 0,
      };

      final result = BudgetRebalancer.rebalance(
        currentAllocations: initial,
        changedCategory: 'Stay',
        newPercent: 50,
      );

      expect(result['Stay'], 50);
      final sum = result.values.fold<int>(0, (s, v) => s + v);
      expect(sum, 100);
      expect(result.values.every((v) => v >= 0), true);

      // Remaining 50 spread across 5 others: 50 ~/ 5 = 10 each
      expect(result['Food'], 10);
      expect(result['Transport'], 10);
      expect(result['Activities'], 10);
      expect(result['Shopping'], 10);
      expect(result['Buffer'], 10);
    });

    test('rebalances proportionally when one slider changes', () {
      final initial = {
        'Stay': 40,
        'Food': 30,
        'Transport': 10,
        'Activities': 10,
        'Shopping': 5,
        'Buffer': 5,
      };

      final result = BudgetRebalancer.rebalance(
        currentAllocations: initial,
        changedCategory: 'Food',
        newPercent: 50,
      );

      expect(result['Food'], 50);
      final sum = result.values.fold<int>(0, (s, v) => s + v);
      expect(sum, 100);
      expect(result.values.every((v) => v >= 0), true);
    });
  });

  group('BudgetRebalancer - Property Test (1,000 Random Changes)', () {
    test('1000 random adjustments always preserve sum=100 and no negatives', () {
      final random = Random(42);
      final categories = TripCategory.all.map((c) => c.key).toList();

      var current = TripCategory.defaultPercentages;

      for (int i = 0; i < 1000; i++) {
        final categoryToChange = categories[random.nextInt(categories.length)];
        final targetPercent = random.nextInt(101); // 0 to 100

        current = BudgetRebalancer.rebalance(
          currentAllocations: current,
          changedCategory: categoryToChange,
          newPercent: targetPercent,
        );

        final sum = current.values.fold<int>(0, (s, v) => s + v);
        expect(sum, 100, reason: 'Iteration $i failed sum=100');
        expect(
          current.values.every((v) => v >= 0),
          true,
          reason: 'Iteration $i produced negative value: $current',
        );
        expect(
          current[categoryToChange],
          targetPercent,
          reason: 'Iteration $i changedCategory did not match target',
        );
      }
    });
  });

  final ok = await runSuite('Budget Rebalancer Tests');
  if (!ok) throw Exception('Budget rebalancer tests failed');
}
