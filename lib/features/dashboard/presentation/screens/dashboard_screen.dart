import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/responsive_center.dart';
import '../../../../data/providers.dart';
import '../../../sync/presentation/widgets/cloud_sync_sheet.dart';
import '../../../trips/domain/trip_model.dart';
import '../../../trips/presentation/widgets/trip_cover_picker.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/cooked_meter.dart';
import '../widgets/metric_cards.dart';
import '../widgets/planned_vs_actual_bars.dart';
import '../widgets/spending_velocity_card.dart';

/// Dashboard screen showing spending overview, cooked meter, and planned vs actual.
class DashboardScreen extends ConsumerWidget {
  final TripWithDetails trip;

  const DashboardScreen({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(tripExpensesProvider(trip.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(trip.name),
        actions: [
          IconButton(
            key: const Key('dashboard_cloud_sync_btn'),
            icon: const Icon(Icons.cloud_sync_outlined),
            tooltip: 'Cloud Sync & Share',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => CloudSyncSheet(trip: trip),
            ),
          ),
        ],
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading expenses: $err')),
        data: (expenses) {
          final totalSpent = expenses
              .where((e) => e.confirmed && e.source != 'settlement')
              .fold<int>(
                0,
                (sum, e) => sum + e.amountPaise,
              );

          final effectiveTrip = trip.copyWith(totalSpentPaise: totalSpent);
          final hasCover = effectiveTrip.coverPhotoPath != null &&
              effectiveTrip.coverPhotoPath!.isNotEmpty &&
              File(effectiveTrip.coverPhotoPath!).existsSync();
          final dateSpan =
              formatTripDateSpan(effectiveTrip.startDate, effectiveTrip.endDate);
          final hasDest = effectiveTrip.destination != null &&
              effectiveTrip.destination!.trim().isNotEmpty;

          return ResponsiveCenter(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                if (hasCover || hasDest || dateSpan != null || effectiveTrip.isCompleted) ...[
                  _DashboardTripHeader(
                    trip: effectiveTrip,
                    hasCover: hasCover,
                    dateSpan: dateSpan,
                  ),
                  const SizedBox(height: 12),
                ],
                // 1. Metric Cards
                DashboardMetricCards(trip: effectiveTrip),
                const SizedBox(height: 16),

                // 2. Cooked Meter
                CookedMeterWidget(
                  totalSpentPaise: totalSpent,
                  totalBudgetPaise: effectiveTrip.totalBudgetPaise,
                ),
                const SizedBox(height: 16),

                // 3. Spending Velocity & Forecast
                SpendingVelocityCard(
                  trip: effectiveTrip,
                  expenses: expenses,
                ),
                const SizedBox(height: 16),

                // 4. Planned vs Actual Bars (Turns error color when over plan)
                PlannedVsActualBars(
                  trip: effectiveTrip,
                  expenses: expenses,
                ),
                const SizedBox(height: 16),

                // 5. Pie Chart of Planned Category Split
                CategoryPieChart(trip: effectiveTrip),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardTripHeader extends StatelessWidget {
  final TripWithDetails trip;
  final bool hasCover;
  final String? dateSpan;

  const _DashboardTripHeader({
    required this.trip,
    required this.hasCover,
    this.dateSpan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDest =
        trip.destination != null && trip.destination!.trim().isNotEmpty;

    final chips = Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (hasDest)
          Chip(
            avatar: Icon(
              Icons.location_on,
              size: 16,
              color: hasCover ? Colors.white : theme.colorScheme.primary,
            ),
            label: Text(trip.destination!.trim()),
            backgroundColor: hasCover
                ? Colors.black.withValues(alpha: 0.55)
                : theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: hasCover
                  ? Colors.white
                  : theme.colorScheme.onPrimaryContainer,
            ),
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
          ),
        if (dateSpan != null)
          Chip(
            avatar: Icon(
              Icons.date_range,
              size: 15,
              color: hasCover ? Colors.white : theme.colorScheme.primary,
            ),
            label: Text(dateSpan!),
            backgroundColor: hasCover
                ? Colors.black.withValues(alpha: 0.55)
                : theme.colorScheme.surfaceContainerHighest,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: hasCover ? Colors.white : theme.colorScheme.onSurface,
            ),
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
          ),
        if (trip.isCompleted)
          Chip(
            avatar: Icon(
              Icons.check_circle,
              size: 15,
              color: hasCover ? Colors.white : const Color(0xFF059669),
            ),
            label: const Text('Completed'),
            backgroundColor: hasCover
                ? const Color(0xFF059669).withValues(alpha: 0.85)
                : const Color(0xFF10B981).withValues(alpha: 0.15),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: hasCover ? Colors.white : const Color(0xFF059669),
            ),
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );

    if (!hasCover) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: chips,
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: SizedBox(
        height: 136,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(trip.coverPhotoPath!),
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: chips,
            ),
          ],
        ),
      ),
    );
  }
}
