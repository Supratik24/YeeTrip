import 'package:flutter/material.dart';

import '../../../../core/constants/categories.dart';
import '../../../../core/money.dart';
import '../../../expenses/domain/expense_model.dart';
import '../../../trips/domain/trip_model.dart';

/// Displays planned vs actual spending per category.
/// The progress bar turns to the theme error color when over plan.
class PlannedVsActualBars extends StatelessWidget {
  final TripWithDetails trip;
  final List<ExpenseWithSplits> expenses;

  const PlannedVsActualBars({
    super.key,
    required this.trip,
    required this.expenses,
  });

  Map<String, int> _calculateSpentPerCategory() {
    final map = <String, int>{};
    for (final exp in expenses) {
      if (exp.confirmed) {
        map[exp.category] = (map[exp.category] ?? 0) + exp.amountPaise;
      }
    }
    return map;
  }

  Color _categoryColor(String key) {
    switch (key.toLowerCase()) {
      case 'stay':
        return Colors.blue.shade600;
      case 'food':
        return Colors.orange.shade600;
      case 'transport':
        return Colors.green.shade600;
      case 'activities':
        return Colors.purple.shade600;
      case 'shopping':
        return Colors.pink.shade500;
      case 'buffer':
      default:
        return Colors.teal.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spentMap = _calculateSpentPerCategory();
    final allocations = trip.categoryAllocations.isNotEmpty
        ? trip.categoryAllocations
        : TripCategory.defaultPercentages;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planned vs actual spending',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...TripCategory.all.map((cat) {
              final percent = allocations[cat.key] ?? 0;
              final plannedPaise = (trip.totalBudgetPaise * percent) ~/ 100;
              final actualPaise = spentMap[cat.key] ?? 0;

              final isOverPlan =
                  plannedPaise > 0 ? actualPaise > plannedPaise : actualPaise > 0;

              final ratio = plannedPaise > 0
                  ? actualPaise / plannedPaise
                  : (actualPaise > 0 ? 1.0 : 0.0);

              // Non-negotiable requirement: "bar turns to the error color when over plan"
              final barColor = isOverPlan
                  ? theme.colorScheme.error
                  : _categoryColor(cat.key);

              final diffPaise = (plannedPaise - actualPaise).abs();

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cat.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          isOverPlan
                              ? 'Over by ${Money.formatRupees(diffPaise)}'
                              : '${Money.formatRupees(diffPaise)} left',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isOverPlan
                                ? theme.colorScheme.error
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Spent: ${Money.formatRupees(actualPaise)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Planned: ${Money.formatRupees(plannedPaise)} ($percent%)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
