import 'package:flutter/material.dart';

import '../../../../core/money.dart';

enum CookedStatus {
  chill,
  careful,
  slightlyCooked,
  fullyCooked,
}

/// "Cooked meter" displaying spent / total budget status.
class CookedMeterWidget extends StatelessWidget {
  final int totalSpentPaise;
  final int totalBudgetPaise;

  const CookedMeterWidget({
    super.key,
    required this.totalSpentPaise,
    required this.totalBudgetPaise,
  });

  CookedStatus get status {
    if (totalBudgetPaise <= 0) return CookedStatus.chill;
    final ratio = totalSpentPaise / totalBudgetPaise;
    if (ratio < 0.50) return CookedStatus.chill;
    if (ratio <= 0.80) return CookedStatus.careful;
    if (ratio <= 1.00) return CookedStatus.slightlyCooked;
    return CookedStatus.fullyCooked;
  }

  String get label {
    switch (status) {
      case CookedStatus.chill:
        return 'Chill';
      case CookedStatus.careful:
        return 'Careful';
      case CookedStatus.slightlyCooked:
        return 'Slightly cooked';
      case CookedStatus.fullyCooked:
        return 'Fully cooked';
    }
  }

  String get description {
    switch (status) {
      case CookedStatus.chill:
        return 'Spending is comfortably under control.';
      case CookedStatus.careful:
        return 'Over halfway through budget. Watch discretionary expenses.';
      case CookedStatus.slightlyCooked:
        return 'Nearing the budget limit. Spend cautiously.';
      case CookedStatus.fullyCooked:
        return 'Budget limit exceeded! Time to cut back.';
    }
  }

  Color get color {
    switch (status) {
      case CookedStatus.chill:
        return const Color(0xFF10B981); // Emerald / Green
      case CookedStatus.careful:
        return const Color(0xFFF59E0B); // Amber / Yellow
      case CookedStatus.slightlyCooked:
        return const Color(0xFFF97316); // Orange
      case CookedStatus.fullyCooked:
        return const Color(0xFFEF4444); // Red
    }
  }

  IconData get icon {
    switch (status) {
      case CookedStatus.chill:
        return Icons.spa_outlined;
      case CookedStatus.careful:
        return Icons.warning_amber_rounded;
      case CookedStatus.slightlyCooked:
        return Icons.local_fire_department_outlined;
      case CookedStatus.fullyCooked:
        return Icons.whatshot_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = totalBudgetPaise > 0
        ? totalSpentPaise / totalBudgetPaise
        : 0.0;
    final percentInt = (ratio * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Cooked meter',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$percentInt% spent',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${Money.formatRupees(totalSpentPaise)} of ${Money.formatRupees(totalBudgetPaise)}',
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
