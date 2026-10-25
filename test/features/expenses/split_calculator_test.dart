import 'dart:math';

import 'package:yeetrip/features/expenses/domain/split_calculator.dart';
import '../../test_helper.dart';

void main() async {
  group('SplitCalculator.calculateEqualSplit', () {
    test('exact prompt example: ₹100 (10,000 paise) among 3', () {
      final travelers = ['trav_c', 'trav_a', 'trav_b'];
      final splits = SplitCalculator.calculateEqualSplit(
        totalPaise: 10000,
        travelerIds: travelers,
      );

      // In fixed sorted order: trav_a, trav_b, trav_c
      // 10000 ~/ 3 = 3333, remainder 1 goes to trav_a
      expect(splits['trav_a'], 3334);
      expect(splits['trav_b'], 3333);
      expect(splits['trav_c'], 3333);
      expect(splits.values.fold<int>(0, (s, v) => s + v), 10000);
    });

    test('single traveler gets entire amount', () {
      final splits = SplitCalculator.calculateEqualSplit(
        totalPaise: 54321,
        travelerIds: ['t1'],
      );
      expect(splits['t1'], 54321);
    });

    test('property test: 1,000 random equal splits always sum exactly to total', () {
      final random = Random(123);
      for (int i = 0; i < 1000; i++) {
        final totalPaise = random.nextInt(1000000) + 1; // 1 to 10,000 rupees
        final count = random.nextInt(15) + 1; // 1 to 15 people
        final ids = List.generate(count, (index) => 'user_$index');

        final splits = SplitCalculator.calculateEqualSplit(
          totalPaise: totalPaise,
          travelerIds: ids,
        );

        final sum = splits.values.fold<int>(0, (s, v) => s + v);
        expect(sum, totalPaise, reason: 'Iteration $i: sum mismatch');
        expect(splits.length, count);
        expect(splits.values.every((v) => v >= 0), true);
      }
    });
  });

  group('SplitCalculator.calculatePercentageSplit', () {
    test('standard percentage split with largest remainder', () {
      // ₹100 split 33.3%, 33.3%, 33.4%
      final splits = SplitCalculator.calculatePercentageSplit(
        totalPaise: 10000,
        percentages: {'p1': 33.3, 'p2': 33.3, 'p3': 33.4},
      );
      final sum = splits.values.fold<int>(0, (s, v) => s + v);
      expect(sum, 10000);
    });

    test('property test: 1,000 random percentage splits always sum exactly to total', () {
      final random = Random(456);
      for (int i = 0; i < 1000; i++) {
        final totalPaise = random.nextInt(500000) + 1;
        // Generate random integers summing to 100
        final r1 = random.nextInt(30) + 5;
        final r2 = random.nextInt(30) + 5;
        final r3 = random.nextInt(20) + 5;
        final r4 = 100 - (r1 + r2 + r3);

        final splits = SplitCalculator.calculatePercentageSplit(
          totalPaise: totalPaise,
          percentages: {
            't1': r1,
            't2': r2,
            't3': r3,
            't4': r4,
          },
        );

        final sum = splits.values.fold<int>(0, (s, v) => s + v);
        expect(sum, totalPaise, reason: 'Iteration $i: sum mismatch');
        expect(splits.values.every((v) => v >= 0), true);
      }
    });
  });

  group('SplitCalculator.calculateSharesSplit', () {
    test('standard weights split', () {
      // 1 share, 2 shares, 3 shares of ₹600 (60000 paise) -> total 6 shares
      // 10000, 20000, 30000 paise
      final splits = SplitCalculator.calculateSharesSplit(
        totalPaise: 60000,
        weights: {'w1': 1, 'w2': 2, 'w3': 3},
      );
      expect(splits['w1'], 10000);
      expect(splits['w2'], 20000);
      expect(splits['w3'], 30000);
      expect(splits.values.fold<int>(0, (s, v) => s + v), 60000);
    });

    test('property test: 1,000 random shares splits always sum exactly to total', () {
      final random = Random(789);
      for (int i = 0; i < 1000; i++) {
        final totalPaise = random.nextInt(1000000) + 1;
        final count = random.nextInt(8) + 1;
        final weights = <String, int>{
          for (int c = 0; c < count; c++) 't$c': random.nextInt(10) + 1,
        };

        final splits = SplitCalculator.calculateSharesSplit(
          totalPaise: totalPaise,
          weights: weights,
        );

        final sum = splits.values.fold<int>(0, (s, v) => s + v);
        expect(sum, totalPaise, reason: 'Iteration $i: shares sum mismatch');
        expect(splits.values.every((v) => v >= 0), true);
      }
    });
  });

  group('SplitCalculator.validateExactSplit', () {
    test('returns null when exact shares sum precisely to total', () {
      final result = SplitCalculator.validateExactSplit(
        totalPaise: 50000,
        exactSharesPaise: {'t1': 20000, 't2': 30000},
      );
      expect(result, null);
    });

    test('returns clear message when shares are short of total', () {
      final result = SplitCalculator.validateExactSplit(
        totalPaise: 50000,
        exactSharesPaise: {'t1': 20000, 't2': 20000},
      );
      expect(result != null, true);
      expect(result!.contains('short of'), true);
      expect(result.contains('₹100'), true); // 10000 paise short
    });

    test('returns clear message when shares exceed total', () {
      final result = SplitCalculator.validateExactSplit(
        totalPaise: 50000,
        exactSharesPaise: {'t1': 30000, 't2': 30000},
      );
      expect(result != null, true);
      expect(result!.contains('more than'), true);
    });

    test('rejects negative shares', () {
      final result = SplitCalculator.validateExactSplit(
        totalPaise: 50000,
        exactSharesPaise: {'t1': 60000, 't2': -10000},
      );
      expect(result, 'Individual shares cannot be negative');
    });
  });

  final ok = await runSuite('Split Calculator Tests');
  if (!ok) throw Exception('Split calculator tests failed');
}
