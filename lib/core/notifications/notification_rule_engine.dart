import '../../features/expenses/domain/expense_model.dart';
import '../../features/itinerary/domain/itinerary_model.dart';
import '../../features/settle/domain/settle_calculator.dart';
import '../../features/trips/domain/trip_model.dart';
import '../money.dart';
import 'notification_models.dart';

/// Pure Dart deterministic rule engine generating actionable trip, budget,
/// settlement, and itinerary reminders with zero Flutter/platform dependencies.
class NotificationRuleEngine {
  const NotificationRuleEngine();

  /// Computes active notifications across a set of trips and optional per-trip expenses/itinerary.
  List<AppNotificationItem> evaluate({
    required List<TripWithDetails> trips,
    Map<String, List<ExpenseWithSplits>> expensesByTrip = const {},
    Map<String, List<ItineraryItemModel>> itineraryByTrip = const {},
    NotificationPreferences preferences = const NotificationPreferences(),
    Set<String> dismissedIds = const {},
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final today = DateTime(clock.year, clock.month, clock.day);
    final items = <AppNotificationItem>[];

    for (final trip in trips) {
      if (trip.isCompleted) continue;
      final tripExpenses = expensesByTrip[trip.id] ?? const [];
      final tripItinerary = itineraryByTrip[trip.id] ?? const [];

      // 1. Trip start countdown reminders
      if (preferences.tripStartReminders && trip.startDate != null) {
        final startDay = DateTime(
          trip.startDate!.year,
          trip.startDate!.month,
          trip.startDate!.day,
        );
        final daysUntilStart = startDay.difference(today).inDays;

        if (daysUntilStart == 1) {
          final id = 'trip_start_tomorrow_${trip.id}_${startDay.toIso8601String()}';
          if (!dismissedIds.contains(id)) {
            items.add(
              AppNotificationItem(
                id: id,
                tripId: trip.id,
                tripName: trip.name,
                type: AppNotificationType.tripStart,
                severity: AppNotificationSeverity.info,
                title: '${trip.name} starts tomorrow!',
                body: trip.destination != null && trip.destination!.isNotEmpty
                    ? 'Pack up for ${trip.destination} — budget is ${Money.formatAmount(trip.totalBudgetPaise, currencyCode: trip.currency)}.'
                    : 'Your ${trip.days}-day trip starts tomorrow. Review your itinerary and budget.',
                timestamp: clock,
                actionRoute: '/trips/${trip.id}/itinerary',
              ),
            );
          }
        } else if (daysUntilStart == 0) {
          final id = 'trip_start_today_${trip.id}_${startDay.toIso8601String()}';
          if (!dismissedIds.contains(id)) {
            items.add(
              AppNotificationItem(
                id: id,
                tripId: trip.id,
                tripName: trip.name,
                type: AppNotificationType.tripStart,
                severity: AppNotificationSeverity.info,
                title: '${trip.name} begins today!',
                body: 'Have a great trip! Tap to view Day 1 itinerary and start tracking expenses.',
                timestamp: clock,
                actionRoute: '/trips/${trip.id}/itinerary',
              ),
            );
          }
        }
      }

      // 2. Budget burn alerts
      if (preferences.budgetBurnAlerts && trip.totalBudgetPaise > 0) {
        final ratio = trip.totalSpentPaise / trip.totalBudgetPaise;
        if (ratio > 1.0) {
          final overPaise = trip.totalSpentPaise - trip.totalBudgetPaise;
          final id = 'budget_exceeded_${trip.id}_${trip.totalSpentPaise}';
          if (!dismissedIds.contains(id)) {
            items.add(
              AppNotificationItem(
                id: id,
                tripId: trip.id,
                tripName: trip.name,
                type: AppNotificationType.budgetAlert,
                severity: AppNotificationSeverity.critical,
                title: '${trip.name} exceeded budget',
                body:
                    'Spent ${Money.formatAmount(trip.totalSpentPaise, currencyCode: trip.currency)} (${Money.formatAmount(overPaise, currencyCode: trip.currency)} over your plan).',
                timestamp: clock,
                actionRoute: '/trips/${trip.id}',
              ),
            );
          }
        } else if (ratio >= 0.80) {
          final pct = (ratio * 100).round();
          final id = 'budget_warning_${trip.id}_$pct';
          if (!dismissedIds.contains(id)) {
            items.add(
              AppNotificationItem(
                id: id,
                tripId: trip.id,
                tripName: trip.name,
                type: AppNotificationType.budgetAlert,
                severity: AppNotificationSeverity.warning,
                title: '$pct% of ${trip.name} budget used',
                body:
                    '${Money.formatAmount(trip.remainingBudgetPaise, currencyCode: trip.currency)} remaining across ${trip.days} days.',
                timestamp: clock,
                actionRoute: '/trips/${trip.id}',
              ),
            );
          }
        }
      }

      // 3. Unsettled balances reminder
      if (preferences.settlementReminders && tripExpenses.isNotEmpty && trip.travelers.length > 1) {
        final balances = SettleCalculator.calculateBalances(
          travelers: trip.travelers,
          expenses: tripExpenses,
        );
        final settlements = SettleCalculator.calculateSettlements(balances: balances);
        if (settlements.isNotEmpty) {
          final travelersMap = {for (final t in trip.travelers) t.id: t.name};
          final top = settlements.first;
          final fromName = travelersMap[top.fromTravelerId] ?? 'Someone';
          final toName = travelersMap[top.toTravelerId] ?? 'Someone';
          final amountStr = Money.formatAmount(
            top.amountPaise,
            currencyCode: trip.currency,
          );
          final id = 'settle_${trip.id}_${top.fromTravelerId}_${top.toTravelerId}_${top.amountPaise}';
          if (!dismissedIds.contains(id)) {
            items.add(
              AppNotificationItem(
                id: id,
                tripId: trip.id,
                tripName: trip.name,
                type: AppNotificationType.settlementReminder,
                severity: AppNotificationSeverity.info,
                title: settlements.length == 1
                    ? '$fromName owes $toName $amountStr'
                    : '${settlements.length} pending settlements in ${trip.name}',
                body: settlements.length == 1
                    ? 'Tap Settle Up to pay $toName via UPI or mark settled.'
                    : 'Top balance: $fromName owes $toName $amountStr. Tap to settle.',
                timestamp: clock,
                actionRoute: '/trips/${trip.id}',
              ),
            );
          }
        }
      }

      // 4. Today's pending itinerary activities
      if (preferences.itineraryReminders && tripItinerary.isNotEmpty && trip.startDate != null) {
        final startDay = DateTime(
          trip.startDate!.year,
          trip.startDate!.month,
          trip.startDate!.day,
        );
        final currentTripDay = today.difference(startDay).inDays + 1;
        if (currentTripDay >= 1 && currentTripDay <= trip.days) {
          final pendingToday = tripItinerary
              .where((item) => item.dayNumber == currentTripDay && !item.isCompleted)
              .toList();
          if (pendingToday.isNotEmpty) {
            final nextItem = pendingToday.first;
            final id = 'itinerary_day_${trip.id}_d${currentTripDay}_${pendingToday.length}';
            if (!dismissedIds.contains(id)) {
              items.add(
                AppNotificationItem(
                  id: id,
                  tripId: trip.id,
                  tripName: trip.name,
                  type: AppNotificationType.itineraryUpcoming,
                  severity: AppNotificationSeverity.info,
                  title: 'Day $currentTripDay Plan: ${pendingToday.length} activity pending',
                  body: 'Next up: ${nextItem.title} (${nextItem.displayTime})',
                  timestamp: clock,
                  actionRoute: '/trips/${trip.id}/itinerary',
                ),
              );
            }
          }
        }
      }
    }

    // Order critical first, then warnings, then info
    items.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return items;
  }
}
