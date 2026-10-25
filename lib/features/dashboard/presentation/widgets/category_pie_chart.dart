import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/categories.dart';
import '../../../../core/money.dart';
import '../../../trips/domain/trip_model.dart';

/// Pie chart visualizing the planned budget allocation across categories.
class CategoryPieChart extends StatelessWidget {
  final TripWithDetails trip;

  const CategoryPieChart({
    super.key,
    required this.trip,
  });

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
    final allocations = trip.categoryAllocations.isNotEmpty
        ? trip.categoryAllocations
        : TripCategory.defaultPercentages;

    final sections = TripCategory.all
        .where((cat) => (allocations[cat.key] ?? 0) > 0)
        .map((cat) {
      final percent = allocations[cat.key] ?? 0;
      final color = _categoryColor(cat.key);

      return PieChartSectionData(
        color: color,
        value: percent.toDouble(),
        title: '$percent%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planned budget split',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: sections.isEmpty
                  ? const Center(child: Text('No allocations defined'))
                  : PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: TripCategory.all.map((cat) {
                final percent = allocations[cat.key] ?? 0;
                final catPaise = (trip.totalBudgetPaise * percent) ~/ 100;
                final color = _categoryColor(cat.key);

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${cat.displayName} ($percent% • ${Money.formatRupees(catPaise)})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
