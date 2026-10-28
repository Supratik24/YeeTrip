import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/money.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../data/providers.dart';
import '../../../trips/domain/trip_model.dart';
import '../../services/csv_exporter.dart';

/// Settings screen for YeeTrip: exports trip expenses to CSV and provides app information.
class SettingsScreen extends ConsumerStatefulWidget {
  final TripWithDetails trip;

  const SettingsScreen({
    super.key,
    required this.trip,
  });

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isExporting = false;

  Future<void> _handleExport() async {
    final expensesAsync = ref.read(tripExpensesProvider(widget.trip.id));
    final expenses = expensesAsync.value ?? [];

    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No expenses logged yet to export.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isExporting = true);
    try {
      await CsvExporter.exportAndShare(
        trip: widget.trip,
        expenses: expenses,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export CSV: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final expensesAsync = ref.watch(tripExpensesProvider(widget.trip.id));
    final expenseCount = expensesAsync.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          // Trip Summary Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flight_takeoff, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.trip.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Total budget',
                    Money.formatRupees(widget.trip.totalBudgetPaise),
                  ),
                  const SizedBox(height: 6),
                  _buildDetailRow(
                    context,
                    'Duration',
                    '${widget.trip.days} ${widget.trip.days == 1 ? "day" : "days"}',
                  ),
                  const SizedBox(height: 6),
                  _buildDetailRow(
                    context,
                    'Travelers',
                    '${widget.trip.travelers.length} (${widget.trip.travelers.map((t) => t.name).join(", ")})',
                  ),
                  const SizedBox(height: 6),
                  _buildDetailRow(
                    context,
                    'Logged expenses',
                    '$expenseCount recorded',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Data Export Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.file_download_outlined, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Data export',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Export all logged expenses for "${widget.trip.name}" as an RFC 4180 compliant CSV file. '
                    'Includes date, description, category, payer, amount in ₹, and split breakdown.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: _isExporting ? null : _handleExport,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.share_outlined),
                      label: Text(
                        _isExporting ? 'Exporting...' : 'Export & share CSV',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // About YeeTrip Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'About YeeTrip',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'YeeTrip is an offline-first group trip budget and expense-splitting app crafted specifically for Indian travelers.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildFeaturePoint(
                    context,
                    Icons.offline_pin_outlined,
                    '100% Offline & Private',
                    'All trip data and expenses remain strictly on this phone. No accounts or internet required.',
                  ),
                  const SizedBox(height: 8),
                  _buildFeaturePoint(
                    context,
                    Icons.currency_rupee,
                    'Exact Integer Paise Precision',
                    'Calculated in exact integer paise to prevent floating-point rounding errors. Formatted in standard Indian numbering (₹1,00,000).',
                  ),
                  const SizedBox(height: 8),
                  _buildFeaturePoint(
                    context,
                    Icons.handshake_outlined,
                    'Greedy Settle-Up Engine',
                    'Computes optimal debt resolution in at most n-1 transactions with zero balance remainder.',
                  ),
                  const SizedBox(height: 16),
                  Divider(color: colorScheme.outlineVariant),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'YeeTrip Core v1.0.0 • Offline Edition',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturePoint(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
