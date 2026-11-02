import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import 'smart_categorizer.dart';
import 'spending_velocity_predictor.dart';

/// Provider for pure Dart on-device ML categorizer.
final smartCategorizerProvider = Provider<SmartCategorizer>((ref) {
  return const SmartCategorizer();
});

/// Provider for pure Dart spending velocity predictor.
final spendingVelocityPredictorProvider = Provider<SpendingVelocityPredictor>((ref) {
  return const SpendingVelocityPredictor();
});

/// Reactive provider computing real-time spending velocity and forecast for a trip.
final tripVelocityReportProvider =
    Provider.family<SpendingVelocityReport?, String>((ref, tripId) {
  final tripAsync = ref.watch(tripDetailsProvider(tripId));
  final expensesAsync = ref.watch(tripExpensesProvider(tripId));

  return tripAsync.when(
    data: (trip) {
      if (trip == null) return null;

      return expensesAsync.when(
        data: (expenses) {
          final predictor = ref.watch(spendingVelocityPredictorProvider);

          // Calculate elapsed days from trip creation to today
          final now = DateTime.now();
          final start = trip.createdAt;
          final diffDays = now.difference(start).inDays + 1; // at least day 1
          final elapsedDays = diffDays.clamp(1, trip.days);

          // Calculate total category budgets in paise
          final categoryBudgetsPaise = <String, int>{};
          for (final entry in trip.categoryAllocations.entries) {
            final percent = entry.value;
            // allocation in paise = totalBudgetPaise * percent / 100
            categoryBudgetsPaise[entry.key] = (trip.totalBudgetPaise * percent) ~/ 100;
          }

          // Calculate category spent in paise
          final categorySpentPaise = <String, int>{};
          for (final exp in expenses) {
            categorySpentPaise[exp.category] =
                (categorySpentPaise[exp.category] ?? 0) + exp.amountPaise;
          }

          return predictor.calculate(
            totalBudgetPaise: trip.totalBudgetPaise,
            totalSpentPaise: trip.totalSpentPaise,
            totalTripDays: trip.days,
            elapsedDays: elapsedDays,
            categoryBudgetsPaise: categoryBudgetsPaise,
            categorySpentPaise: categorySpentPaise,
          );
        },
        loading: () => null,
        error: (err, stack) => null,
      );
    },
    loading: () => null,
    error: (err, stack) => null,
  );
});
