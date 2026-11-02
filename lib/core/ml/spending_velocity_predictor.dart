import '../money.dart';

/// Pacing and risk level determined by spending velocity versus total budget.
enum VelocityRiskLevel {
  /// Projected total spend is comfortably under 90% of budget.
  safe,

  /// Projected spend is between 90% and 105% of budget.
  moderate,

  /// Projected spend is between 105% and 125% of budget.
  high,

  /// Projected spend exceeds 125% of budget.
  critical,
}

/// Early-warning alert when a specific category's burn rate projects depletion before the trip ends.
class CategoryDepletionWarning {
  final String categoryKey;
  final int allocatedBudgetPaise;
  final int spentPaise;
  final int dailyBurnRatePaise;
  final double daysUntilExhausted;
  final int projectedOverrunPaise;

  const CategoryDepletionWarning({
    required this.categoryKey,
    required this.allocatedBudgetPaise,
    required this.spentPaise,
    required this.dailyBurnRatePaise,
    required this.daysUntilExhausted,
    required this.projectedOverrunPaise,
  });

  @override
  String toString() {
    return 'CategoryDepletionWarning($categoryKey exhausts in ${daysUntilExhausted.toStringAsFixed(1)} days, overrun: ${Money.formatRupees(projectedOverrunPaise)})';
  }
}

/// Comprehensive spending velocity and forward-looking financial forecast report.
class SpendingVelocityReport {
  final int elapsedDays;
  final int totalTripDays;
  final int remainingDays;

  /// Average spending pace per day in integer paise.
  final int dailyBurnRatePaise;

  /// Projected total expenditure by trip end in integer paise.
  final int projectedTotalSpendPaise;

  /// Projected surplus (positive) or deficit (negative) at trip end.
  final int projectedVariancePaise;

  /// Ratio of projected total spend to total budget (e.g. 1.15 = 15% overrun).
  final double burnRateVsBudgetRatio;

  /// Qualitative risk category.
  final VelocityRiskLevel riskLevel;

  /// Per-category early depletion alerts.
  final List<CategoryDepletionWarning> categoryWarnings;

  /// Plain-English status message for display.
  final String summaryMessage;

  const SpendingVelocityReport({
    required this.elapsedDays,
    required this.totalTripDays,
    required this.remainingDays,
    required this.dailyBurnRatePaise,
    required this.projectedTotalSpendPaise,
    required this.projectedVariancePaise,
    required this.burnRateVsBudgetRatio,
    required this.riskLevel,
    required this.categoryWarnings,
    required this.summaryMessage,
  });

  bool get isDeficitProjected => projectedVariancePaise < 0;

  @override
  String toString() {
    return 'SpendingVelocityReport(burn: ${Money.formatRupees(dailyBurnRatePaise)}/day, projected: ${Money.formatRupees(projectedTotalSpendPaise)}, risk: $riskLevel)';
  }
}

/// Pure Dart predictive engine that computes group spending velocity and forecast metrics.
class SpendingVelocityPredictor {
  const SpendingVelocityPredictor();

  /// Calculates spending velocity and forecasts for a trip.
  SpendingVelocityReport calculate({
    required int totalBudgetPaise,
    required int totalSpentPaise,
    required int totalTripDays,
    required int elapsedDays,
    Map<String, int> categoryBudgetsPaise = const {},
    Map<String, int> categorySpentPaise = const {},
  }) {
    // Sanitize days bounds
    final safeTotalDays = totalTripDays < 1 ? 1 : totalTripDays;
    final safeElapsedDays = elapsedDays < 1
        ? 1
        : (elapsedDays > safeTotalDays ? safeTotalDays : elapsedDays);
    final remainingDays = (safeTotalDays - safeElapsedDays).clamp(0, safeTotalDays);

    // Compute daily burn rate in paise (floor division)
    final dailyBurnRatePaise = totalSpentPaise > 0
        ? totalSpentPaise ~/ safeElapsedDays
        : 0;

    // Projected spend: spent so far + (daily rate * remaining days)
    final projectedTotalSpendPaise = totalSpentPaise + (dailyBurnRatePaise * remainingDays);
    final projectedVariancePaise = totalBudgetPaise - projectedTotalSpendPaise;

    // Ratio
    final double ratio = totalBudgetPaise > 0
        ? projectedTotalSpendPaise / totalBudgetPaise
        : (totalSpentPaise > 0 ? 2.0 : 0.0);

    // Risk Level
    final VelocityRiskLevel risk;
    if (ratio <= 0.90) {
      risk = VelocityRiskLevel.safe;
    } else if (ratio <= 1.05) {
      risk = VelocityRiskLevel.moderate;
    } else if (ratio <= 1.25) {
      risk = VelocityRiskLevel.high;
    } else {
      risk = VelocityRiskLevel.critical;
    }

    // Category Depletions
    final warnings = <CategoryDepletionWarning>[];
    for (final entry in categoryBudgetsPaise.entries) {
      final cat = entry.key;
      final catBudget = entry.value;
      if (catBudget <= 0) continue;

      final catSpent = categorySpentPaise[cat] ?? 0;
      if (catSpent <= 0) continue;

      final catBurnPaise = catSpent ~/ safeElapsedDays;
      if (catBurnPaise > 0) {
        final catRemainingBudget = catBudget - catSpent;
        final double daysLeftUntilExhausted = catRemainingBudget / catBurnPaise;

        // If projected to exhaust before remaining trip days
        if (daysLeftUntilExhausted < remainingDays) {
          final catProjectedTotal = catSpent + (catBurnPaise * remainingDays);
          final catOverrun = catProjectedTotal - catBudget;
          warnings.add(
            CategoryDepletionWarning(
              categoryKey: cat,
              allocatedBudgetPaise: catBudget,
              spentPaise: catSpent,
              dailyBurnRatePaise: catBurnPaise,
              daysUntilExhausted: daysLeftUntilExhausted < 0 ? 0.0 : daysLeftUntilExhausted,
              projectedOverrunPaise: catOverrun > 0 ? catOverrun : 0,
            ),
          );
        }
      }
    }

    // Friendly message
    final String summary;
    if (totalSpentPaise == 0) {
      summary = 'Trip just started. No spending recorded yet.';
    } else if (risk == VelocityRiskLevel.safe) {
      summary = 'Healthy pace! Projected savings of ${Money.formatRupees(projectedVariancePaise.abs())} by Day $safeTotalDays.';
    } else if (risk == VelocityRiskLevel.moderate) {
      summary = 'On target. Keep monitoring daily expenses to stay within budget.';
    } else if (risk == VelocityRiskLevel.high) {
      summary = 'High velocity alert! Projected overrun of ${Money.formatRupees(projectedVariancePaise.abs())}. Consider trimming non-essentials.';
    } else {
      summary = 'Critical burn rate! Trip budget projected to exceed by ${Money.formatRupees(projectedVariancePaise.abs())}. Urgent rebalancing recommended!';
    }

    return SpendingVelocityReport(
      elapsedDays: safeElapsedDays,
      totalTripDays: safeTotalDays,
      remainingDays: remainingDays,
      dailyBurnRatePaise: dailyBurnRatePaise,
      projectedTotalSpendPaise: projectedTotalSpendPaise,
      projectedVariancePaise: projectedVariancePaise,
      burnRateVsBudgetRatio: ratio,
      riskLevel: risk,
      categoryWarnings: warnings,
      summaryMessage: summary,
    );
  }
}
