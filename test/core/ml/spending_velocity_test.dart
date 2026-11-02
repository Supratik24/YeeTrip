import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/ml/spending_velocity_predictor.dart';

void main() {
  group('SpendingVelocityPredictor Tests', () {
    const predictor = SpendingVelocityPredictor();

    test('calculates safe spending pace with projected savings on Day 1 of 5-day trip', () {
      final report = predictor.calculate(
        totalBudgetPaise: 5000000, // ₹50,000
        totalSpentPaise: 800000, // ₹8,000 spent on Day 1
        totalTripDays: 5,
        elapsedDays: 1,
      );

      expect(report.elapsedDays, equals(1));
      expect(report.totalTripDays, equals(5));
      expect(report.remainingDays, equals(4));
      expect(report.dailyBurnRatePaise, equals(800000)); // ₹8,000/day
      expect(report.projectedTotalSpendPaise, equals(4000000)); // ₹40,000
      expect(report.projectedVariancePaise, equals(1000000)); // ₹10,000 savings
      expect(report.isDeficitProjected, isFalse);
      expect(report.riskLevel, equals(VelocityRiskLevel.safe));
      expect(report.burnRateVsBudgetRatio, equals(0.80));
      expect(report.summaryMessage, contains('Healthy pace'));
      expect(report.summaryMessage, contains('Projected savings of ₹10,000'));
    });

    test('detects runaway spending and flags critical risk level on Day 2 of 5-day trip', () {
      final report = predictor.calculate(
        totalBudgetPaise: 5000000, // ₹50,000
        totalSpentPaise: 2800000, // ₹28,000 spent by Day 2 (burn rate = ₹14,000/day)
        totalTripDays: 5,
        elapsedDays: 2,
      );

      expect(report.elapsedDays, equals(2));
      expect(report.remainingDays, equals(3));
      expect(report.dailyBurnRatePaise, equals(1400000)); // ₹14,000/day
      // Projected = 28,000 + (14,000 * 3) = ₹70,000
      expect(report.projectedTotalSpendPaise, equals(7000000));
      expect(report.projectedVariancePaise, equals(-2000000)); // ₹20,000 deficit
      expect(report.isDeficitProjected, isTrue);
      expect(report.riskLevel, equals(VelocityRiskLevel.critical));
      expect(report.burnRateVsBudgetRatio, equals(1.40));
      expect(report.summaryMessage, contains('Critical burn rate'));
      expect(report.summaryMessage, contains('exceed by ₹20,000'));
    });

    test('generates CategoryDepletionWarning when a category burns faster than trip duration', () {
      final report = predictor.calculate(
        totalBudgetPaise: 5000000, // ₹50,000
        totalSpentPaise: 2000000, // ₹20,000
        totalTripDays: 5,
        elapsedDays: 2, // 3 days remaining
        categoryBudgetsPaise: {
          'Food': 1250000, // ₹12,500 allocated (25%)
          'Stay': 1500000, // ₹15,000 allocated (30%)
        },
        categorySpentPaise: {
          'Food': 900000, // ₹9,000 spent in 2 days (burn rate = ₹4,500/day, remaining = ₹3,500)
          'Stay': 600000, // ₹6,000 spent (burn rate = ₹3,000/day, remaining = ₹9,000)
        },
      );

      expect(report.categoryWarnings.length, equals(1));
      final foodWarning = report.categoryWarnings.first;
      expect(foodWarning.categoryKey, equals('Food'));
      expect(foodWarning.allocatedBudgetPaise, equals(1250000));
      expect(foodWarning.spentPaise, equals(900000));
      expect(foodWarning.dailyBurnRatePaise, equals(450000)); // ₹4,500/day
      // Remaining budget ₹3,500 / ₹4,500 per day = 0.77 days until exhausted (< 3 days remaining)
      expect(foodWarning.daysUntilExhausted, closeTo(0.77, 0.05));
      // Projected total food spend = 900000 + (450000 * 3) = 2250000 (overrun = 1000000)
      expect(foodWarning.projectedOverrunPaise, equals(1000000));
    });

    test('handles zero spending on initial day gracefully', () {
      final report = predictor.calculate(
        totalBudgetPaise: 5000000,
        totalSpentPaise: 0,
        totalTripDays: 5,
        elapsedDays: 1,
      );

      expect(report.dailyBurnRatePaise, equals(0));
      expect(report.projectedTotalSpendPaise, equals(0));
      expect(report.projectedVariancePaise, equals(5000000));
      expect(report.riskLevel, equals(VelocityRiskLevel.safe));
      expect(report.categoryWarnings, isEmpty);
      expect(report.summaryMessage, contains('No spending recorded yet'));
    });

    test('handles final day edge case when remainingDays is 0', () {
      final report = predictor.calculate(
        totalBudgetPaise: 5000000,
        totalSpentPaise: 4800000,
        totalTripDays: 5,
        elapsedDays: 5,
      );

      expect(report.remainingDays, equals(0));
      expect(report.projectedTotalSpendPaise, equals(4800000));
      expect(report.projectedVariancePaise, equals(200000)); // ₹2,000 savings
      expect(report.riskLevel, equals(VelocityRiskLevel.moderate));
      expect(report.categoryWarnings, isEmpty);
    });
  });
}
