import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ml/ml_providers.dart';
import '../../../../core/ml/spending_velocity_predictor.dart';
import '../../../../core/money.dart';
import '../../../expenses/domain/expense_model.dart';
import '../../../trips/domain/trip_model.dart';

/// Card showing spending velocity, daily burn rate, and forward-looking budget forecasts.
class SpendingVelocityCard extends ConsumerWidget {
  final TripWithDetails trip;
  final List<ExpenseWithSplits> expenses;

  const SpendingVelocityCard({
    super.key,
    required this.trip,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictor = ref.watch(spendingVelocityPredictorProvider);
    final theme = Theme.of(context);

    // Compute elapsed days from trip creation date
    final now = DateTime.now();
    final start = trip.createdAt;
    final diffDays = now.difference(start).inDays + 1;
    final elapsedDays = diffDays.clamp(1, trip.days);

    // Map allocated category budgets in paise
    final categoryBudgetsPaise = <String, int>{};
    for (final entry in trip.categoryAllocations.entries) {
      categoryBudgetsPaise[entry.key] =
          (trip.totalBudgetPaise * entry.value) ~/ 100;
    }

    // Map confirmed manual category spending
    final categorySpentPaise = <String, int>{};
    for (final exp in expenses.where((e) => e.confirmed && e.source == 'manual')) {
      categorySpentPaise[exp.category] =
          (categorySpentPaise[exp.category] ?? 0) + exp.amountPaise;
    }

    final report = predictor.calculate(
      totalBudgetPaise: trip.totalBudgetPaise,
      totalSpentPaise: trip.totalSpentPaise,
      totalTripDays: trip.days,
      elapsedDays: elapsedDays,
      categoryBudgetsPaise: categoryBudgetsPaise,
      categorySpentPaise: categorySpentPaise,
    );

    final (badgeColor, badgeTextColor, riskLabel) = switch (report.riskLevel) {
      VelocityRiskLevel.safe => (
          Colors.green.shade100,
          Colors.green.shade800,
          'Safe Pace'
        ),
      VelocityRiskLevel.moderate => (
          Colors.amber.shade100,
          Colors.amber.shade900,
          'On Target'
        ),
      VelocityRiskLevel.high => (
          Colors.orange.shade100,
          Colors.orange.shade900,
          'High Velocity'
        ),
      VelocityRiskLevel.critical => (
          Colors.red.shade100,
          Colors.red.shade900,
          'Critical Burn'
        ),
    };

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with Title & Risk Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_graph,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Spending Velocity',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    riskLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Daily Burn Rate & Projected Total Metrics
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Daily Burn Rate',
                    value: '${Money.formatRupees(report.dailyBurnRatePaise)}/day',
                    subtext: 'Day ${report.elapsedDays} of ${report.totalTripDays}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: 'Projected Total',
                    value: Money.formatRupees(report.projectedTotalSpendPaise),
                    subtext: report.isDeficitProjected
                        ? '${Money.formatRupees(report.projectedVariancePaise.abs())} Deficit'
                        : '${Money.formatRupees(report.projectedVariancePaise.abs())} Savings',
                    isWarning: report.isDeficitProjected,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Summary Message Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      report.summaryMessage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category Depletion Alerts (if any)
            if (report.categoryWarnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...report.categoryWarnings.map((warning) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: Colors.orange.shade800,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${warning.categoryKey}: At ${Money.formatRupees(warning.dailyBurnRatePaise)}/day, budget will exhaust in ${warning.daysUntilExhausted.toStringAsFixed(1)} days (Overrun: ${Money.formatRupees(warning.projectedOverrunPaise)})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final bool isWarning;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.subtext,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isWarning
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isWarning
                  ? theme.colorScheme.error
                  : Colors.green.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
