import 'package:flutter/material.dart';

import '../../../../core/money.dart';
import '../../../trips/domain/trip_model.dart';

/// Top metric cards for total budget, per person, per day, and remaining/over by.
class DashboardMetricCards extends StatelessWidget {
  final TripWithDetails trip;

  const DashboardMetricCards({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverBudget = trip.remainingBudgetPaise < 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Total budget',
                value: Money.formatRupees(trip.totalBudgetPaise),
                subtitle: '${trip.travelers.length} travelers • ${trip.days} days',
                icon: Icons.account_balance_wallet_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: isOverBudget ? 'Over by' : 'Remaining',
                value: Money.formatRupees(trip.remainingBudgetPaise.abs()),
                subtitle: isOverBudget
                    ? 'Exceeded trip budget'
                    : '${((trip.remainingBudgetPaise / (trip.totalBudgetPaise > 0 ? trip.totalBudgetPaise : 1)) * 100).toStringAsFixed(0)}% available',
                icon: isOverBudget
                    ? Icons.trending_up
                    : Icons.trending_down,
                valueColor: isOverBudget
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Per person',
                value: Money.formatRupees(trip.budgetPerPersonPaise),
                subtitle: 'Target budget',
                icon: Icons.person_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Per day (group)',
                value: Money.formatRupees(trip.budgetPerDayPaise),
                subtitle: 'Target per day',
                icon: Icons.calendar_today_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color? valueColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Icon(icon, size: 16, color: Colors.grey.shade500),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
