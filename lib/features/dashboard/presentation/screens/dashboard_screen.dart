import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/responsive_center.dart';
import '../../../../data/providers.dart';
import '../../../sync/presentation/widgets/cloud_sync_sheet.dart';
import '../../../trips/domain/trip_model.dart';
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
              .where((e) => e.confirmed && e.source == 'manual')
              .fold<int>(
                0,
                (sum, e) => sum + e.amountPaise,
              );

          final effectiveTrip = trip.copyWith(totalSpentPaise: totalSpent);

          return ResponsiveCenter(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
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
