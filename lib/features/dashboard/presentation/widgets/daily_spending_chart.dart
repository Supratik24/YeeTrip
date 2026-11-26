import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/money.dart';
import '../../../expenses/domain/expense_model.dart';
import '../../../trips/domain/trip_model.dart';

/// Data point for a single day in a trip's spending timeline.
class DailySpendPoint {
  final int dayNumber;
  final DateTime date;
  final int amountPaise;
  final bool isPeak;
  final bool isOverTarget;

  const DailySpendPoint({
    required this.dayNumber,
    required this.date,
    required this.amountPaise,
    required this.isPeak,
    required this.isOverTarget,
  });

  String get shortLabel => 'D$dayNumber';
}

/// Aggregated daily spending breakdown for a trip.
class DailySpendSummary {
  final List<DailySpendPoint> points;
  final int? peakDayNumber;
  final int peakAmountPaise;
  final int totalSpentPaise;
  final int averageDailyPaise;
  final int targetDailyPaise;

  const DailySpendSummary({
    required this.points,
    required this.peakDayNumber,
    required this.peakAmountPaise,
    required this.totalSpentPaise,
    required this.averageDailyPaise,
    required this.targetDailyPaise,
  });

  /// Computes per-day spending for [trip] across `Day 1..trip.days`.
  ///
  /// Confirmed non-settlement expenses before trip start clamp to Day 1, and
  /// expenses after Day N clamp to Day N so totals remain exact and complete.
  static DailySpendSummary analyze({
    required TripWithDetails trip,
    required List<ExpenseWithSplits> expenses,
  }) {
    final totalDays = max(1, trip.days);
    final rawAnchor = trip.startDate ?? trip.createdAt;
    final anchorDate = DateTime(rawAnchor.year, rawAnchor.month, rawAnchor.day);
    final targetPerDay = trip.budgetPerDayPaise;

    final bucketPaise = List<int>.filled(totalDays, 0);
    var totalSpent = 0;

    for (final exp in expenses) {
      if (!exp.confirmed || exp.source == 'settlement') continue;
      final expDate = DateTime(
        exp.createdAt.year,
        exp.createdAt.month,
        exp.createdAt.day,
      );
      final dayIndexZeroBased =
          expDate.difference(anchorDate).inDays.clamp(0, totalDays - 1);
      bucketPaise[dayIndexZeroBased] += exp.amountPaise;
      totalSpent += exp.amountPaise;
    }

    var peakAmount = 0;
    int? peakDay;
    for (int i = 0; i < totalDays; i++) {
      if (bucketPaise[i] > peakAmount) {
        peakAmount = bucketPaise[i];
        peakDay = i + 1;
      }
    }

    final points = <DailySpendPoint>[
      for (int i = 0; i < totalDays; i++)
        DailySpendPoint(
          dayNumber: i + 1,
          date: anchorDate.add(Duration(days: i)),
          amountPaise: bucketPaise[i],
          isPeak: peakDay == i + 1 && peakAmount > 0,
          isOverTarget: targetPerDay > 0 && bucketPaise[i] > targetPerDay,
        ),
    ];

    return DailySpendSummary(
      points: points,
      peakDayNumber: peakDay,
      peakAmountPaise: peakAmount,
      totalSpentPaise: totalSpent,
      averageDailyPaise: totalSpent ~/ totalDays,
      targetDailyPaise: targetPerDay,
    );
  }
}

/// Interactive bar/line chart displaying daily trip spend vs daily target.
class DailySpendingChart extends StatefulWidget {
  final TripWithDetails trip;
  final List<ExpenseWithSplits> expenses;

  const DailySpendingChart({
    super.key,
    required this.trip,
    required this.expenses,
  });

  @override
  State<DailySpendingChart> createState() => _DailySpendingChartState();
}

class _DailySpendingChartState extends State<DailySpendingChart> {
  bool _showLineChart = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summary = DailySpendSummary.analyze(
      trip: widget.trip,
      expenses: widget.expenses,
    );

    final maxPointPaise = summary.points
        .map((p) => p.amountPaise)
        .fold<int>(0, max);
    final ceilingPaise = max(
      100,
      ((max(maxPointPaise, summary.targetDailyPaise)) * 1.2).ceil(),
    );
    final ceilingMajor = ceilingPaise / 100.0;
    final targetMajor = summary.targetDailyPaise / 100.0;

    return Card(
      key: const Key('daily_spending_chart_card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_rounded,
                    size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Daily spending trend',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  key: const Key('daily_chart_bar_btn'),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Bar chart',
                  icon: Icon(
                    Icons.bar_chart_rounded,
                    color: !_showLineChart
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() => _showLineChart = false),
                ),
                IconButton(
                  key: const Key('daily_chart_line_btn'),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Line trend',
                  icon: Icon(
                    Icons.show_chart_rounded,
                    color: _showLineChart
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() => _showLineChart = true),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: summary.peakDayNumber != null
                        ? colorScheme.secondaryContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    summary.peakDayNumber != null
                        ? 'Peak: Day ${summary.peakDayNumber} (${Money.formatAmount(summary.peakAmountPaise, currencyCode: widget.trip.currency)})'
                        : 'No expenses logged yet',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: summary.peakDayNumber != null
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (summary.targetDailyPaise > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Target: ${Money.formatAmount(summary.targetDailyPaise, currencyCode: widget.trip.currency)}/day',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 185,
              child: _showLineChart
                  ? _buildLineChart(
                      theme,
                      colorScheme,
                      summary,
                      ceilingMajor,
                      targetMajor,
                    )
                  : _buildBarChart(
                      theme,
                      colorScheme,
                      summary,
                      ceilingMajor,
                      targetMajor,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowXLabel(int index, int totalCount) {
    if (totalCount <= 7) return true;
    final step = (totalCount / 6).ceil();
    return index % step == 0 || index == totalCount - 1;
  }

  Widget _buildBarChart(
    ThemeData theme,
    ColorScheme colorScheme,
    DailySpendSummary summary,
    double ceilingMajor,
    double targetMajor,
  ) {
    final totalCount = summary.points.length;
    final barWidth = totalCount <= 5
        ? 22.0
        : (totalCount <= 10 ? 14.0 : 9.0);

    return BarChart(
      BarChartData(
        maxY: ceilingMajor,
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (targetMajor > 0)
              HorizontalLine(
                y: targetMajor,
                color: colorScheme.tertiary.withValues(alpha: 0.75),
                strokeWidth: 1.5,
                dashArray: const [5, 5],
              ),
          ],
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(
                    Money.formatCompact(
                      (value * 100).round(),
                      currencyCode: widget.trip.currency,
                    ),
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.round();
                if (idx < 0 ||
                    idx >= totalCount ||
                    !_shouldShowXLabel(idx, totalCount)) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 6,
                  child: Text(
                    summary.points[idx].shortLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: summary.points[idx].isPeak
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: summary.points[idx].isPeak
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => colorScheme.inverseSurface,
            getTooltipItem: (group, _, rod, _) {
              final pt = summary.points[group.x];
              final dateStr = DateFormat('d MMM').format(pt.date);
              return BarTooltipItem(
                'Day ${pt.dayNumber} ($dateStr)\n${Money.formatAmount(pt.amountPaise, currencyCode: widget.trip.currency)}',
                TextStyle(
                  color: colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        barGroups: List.generate(totalCount, (idx) {
          final pt = summary.points[idx];
          final barColor = pt.amountPaise == 0
              ? colorScheme.surfaceContainerHighest
              : pt.isOverTarget
                  ? colorScheme.error
                  : (pt.isPeak ? colorScheme.secondary : colorScheme.primary);

          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(
                toY: pt.amountPaise / 100.0,
                width: barWidth,
                color: barColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLineChart(
    ThemeData theme,
    ColorScheme colorScheme,
    DailySpendSummary summary,
    double ceilingMajor,
    double targetMajor,
  ) {
    final totalCount = summary.points.length;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: ceilingMajor,
        minX: 0,
        maxX: max(1, totalCount - 1).toDouble(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (targetMajor > 0)
              HorizontalLine(
                y: targetMajor,
                color: colorScheme.tertiary.withValues(alpha: 0.75),
                strokeWidth: 1.5,
                dashArray: const [5, 5],
              ),
          ],
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(
                    Money.formatCompact(
                      (value * 100).round(),
                      currencyCode: widget.trip.currency,
                    ),
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.round();
                if ((value - idx).abs() > 0.01 ||
                    idx < 0 ||
                    idx >= totalCount ||
                    !_shouldShowXLabel(idx, totalCount)) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 6,
                  child: Text(
                    summary.points[idx].shortLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => colorScheme.inverseSurface,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final idx = spot.x.round().clamp(0, totalCount - 1);
                final pt = summary.points[idx];
                return LineTooltipItem(
                  'Day ${pt.dayNumber}: ${Money.formatAmount(pt.amountPaise, currencyCode: widget.trip.currency)}',
                  TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              totalCount,
              (i) => FlSpot(
                i.toDouble(),
                summary.points[i].amountPaise / 100.0,
              ),
            ),
            isCurved: true,
            preventCurveOverShooting: true,
            color: colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, _, idx) => FlDotCirclePainter(
                radius: summary.points[idx].isPeak ? 5 : 3.5,
                color: summary.points[idx].isOverTarget
                    ? colorScheme.error
                    : (summary.points[idx].isPeak
                        ? colorScheme.secondary
                        : colorScheme.primary),
                strokeWidth: 1.5,
                strokeColor: colorScheme.surface,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.primary.withValues(alpha: 0.14),
            ),
          ),
        ],
      ),
    );
  }
}
