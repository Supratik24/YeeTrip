import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/notifications/notification_models.dart';
import 'package:yeetrip/core/notifications/notification_rule_engine.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/itinerary/domain/itinerary_model.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

void main() {
  const engine = NotificationRuleEngine();
  final now = DateTime(2026, 12, 10, 10, 0);

  TripWithDetails buildTrip({
    String id = 'trip-1',
    String name = 'Thailand Escape',
    String currency = 'THB',
    int budget = 5000000,
    int spent = 0,
    int days = 5,
    String status = 'active',
    DateTime? startDate,
  }) {
    return TripWithDetails(
      id: id,
      name: name,
      totalBudgetPaise: budget,
      days: days,
      currency: currency,
      createdAt: now.subtract(const Duration(days: 2)),
      status: status,
      startDate: startDate,
      totalSpentPaise: spent,
      travelers: const [
        Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
        Traveler(id: 't-2', tripId: 'trip-1', name: 'Diya'),
      ],
    );
  }

  group('NotificationRuleEngine', () {
    test('triggers trip start tomorrow reminder', () {
      final trip = buildTrip(startDate: DateTime(2026, 12, 11));
      final alerts = engine.evaluate(trips: [trip], now: now);

      expect(alerts.length, equals(1));
      expect(alerts.first.type, equals(AppNotificationType.tripStart));
      expect(alerts.first.title, contains('starts tomorrow'));
    });

    test('triggers 80% warning and >100% critical budget alerts in trip currency', () {
      final warnTrip = buildTrip(spent: 4200000); // 84%
      final warnAlerts = engine.evaluate(trips: [warnTrip], now: now);
      expect(warnAlerts.single.type, equals(AppNotificationType.budgetAlert));
      expect(warnAlerts.single.severity, equals(AppNotificationSeverity.warning));
      expect(warnAlerts.single.body, contains('฿'));

      final overTrip = buildTrip(spent: 5500000); // 110%
      final overAlerts = engine.evaluate(trips: [overTrip], now: now);
      expect(overAlerts.single.severity, equals(AppNotificationSeverity.critical));
      expect(overAlerts.single.title, contains('exceeded budget'));
    });

    test('triggers settlement reminder and today itinerary alert', () {
      final trip = buildTrip(
        startDate: DateTime(2026, 12, 10), // today = Day 1
        currency: 'USD',
      );
      final expenses = [
        ExpenseWithSplits(
          id: 'e-1',
          tripId: 'trip-1',
          description: 'Hotel',
          amountPaise: 20000, // $200
          category: 'Stay',
          paidBy: 't-1',
          createdAt: now,
          splits: const [
            ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-1', sharePaise: 10000),
            ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-2', sharePaise: 10000),
          ],
        ),
      ];
      final itinerary = [
        ItineraryItemModel(
          id: 'i-1',
          tripId: 'trip-1',
          dayNumber: 1,
          title: 'Grand Palace Tour',
          startTimeMinutes: 9 * 60,
          createdAt: now,
        ),
      ];

      final alerts = engine.evaluate(
        trips: [trip],
        expensesByTrip: {'trip-1': expenses},
        itineraryByTrip: {'trip-1': itinerary},
        now: now,
      );

      expect(
        alerts.any((a) => a.type == AppNotificationType.settlementReminder && a.title.contains('\$100')),
        isTrue,
      );
      expect(
        alerts.any((a) => a.type == AppNotificationType.itineraryUpcoming && a.body.contains('Grand Palace Tour')),
        isTrue,
      );
    });

    test('respects notification preferences, dismissedIds, and skips completed trips', () {
      final active = buildTrip(
        startDate: DateTime(2026, 12, 11),
        spent: 4500000,
      );
      final completed = buildTrip(
        id: 'trip-2',
        status: 'completed',
        spent: 6000000,
      );

      final all = engine.evaluate(trips: [active, completed], now: now);
      expect(all.length, equals(2));

      final dismissed = engine.evaluate(
        trips: [active],
        dismissedIds: {all.first.id},
        now: now,
      );
      expect(dismissed.length, equals(1));

      final muted = engine.evaluate(
        trips: [active],
        preferences: const NotificationPreferences(
          tripStartReminders: false,
          budgetBurnAlerts: false,
        ),
        now: now,
      );
      expect(muted, isEmpty);
    });
  });
}
