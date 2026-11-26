import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yeetrip/core/notifications/notification_models.dart';
import 'package:yeetrip/core/notifications/notification_providers.dart';
import 'package:yeetrip/core/notifications/notification_service.dart';
import 'package:yeetrip/core/notifications/notifications_sheet.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/settings/presentation/screens/settings_screen.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

class _FakeNotificationClient implements LocalNotificationClient {
  int shownCount = 0;
  int scheduledCount = 0;
  String? lastTitle;

  @override
  Future<void> cancelNotification(int id) async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    scheduledCount++;
    lastTitle = title;
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    shownCount++;
    lastTitle = title;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final trip = TripWithDetails(
    id: 'trip-1',
    name: 'Euro Rail',
    totalBudgetPaise: 500000, // €5,000
    days: 5,
    currency: 'EUR',
    createdAt: DateTime.now(),
    totalSpentPaise: 450000, // 90%
    itineraryTotalCount: 4,
    itineraryCompletedCount: 1,
    nextItineraryTitle: 'Day 2: Louvre Museum',
    travelers: const [
      Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
      Traveler(id: 't-2', tripId: 'trip-1', name: 'Diya'),
    ],
  );

  testWidgets('DashboardScreen displays itinerary card, notification badge, and EUR currency',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripExpensesProvider('trip-1').overrideWith(
            (ref) => Stream.value(<ExpenseWithSplits>[]),
          ),
        ],
        child: MaterialApp(
          home: DashboardScreen(trip: trip),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard_itinerary_card')), findsOneWidget);
    expect(find.textContaining('1 of 4 done'), findsOneWidget);
    expect(find.textContaining('Day 2: Louvre Museum'), findsOneWidget);
    expect(find.byKey(const Key('dashboard_notifications_btn')), findsOneWidget);
    expect(find.text('€5,000'), findsWidgets);
  });

  testWidgets('NotificationsSheet renders reminders and supports dismiss all', (tester) async {
    final items = [
      AppNotificationItem(
        id: 'n-1',
        tripId: 'trip-1',
        tripName: 'Euro Rail',
        type: AppNotificationType.budgetAlert,
        severity: AppNotificationSeverity.warning,
        title: '90% of Euro Rail budget used',
        body: '€500 remaining across 5 days.',
        timestamp: DateTime.now(),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: NotificationsSheet(notifications: items),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('90% of Euro Rail budget used'), findsOneWidget);
    await tester.tap(find.byKey(const Key('clear_all_notifications_btn')));
    await tester.pumpAndSettle();
    expect(find.text('You are all caught up!'), findsOneWidget);
  });

  testWidgets('SettingsScreen shows Notifications card and sends test alert via client',
      (tester) async {
    final fakeClient = _FakeNotificationClient();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localNotificationClientProvider.overrideWithValue(fakeClient),
          tripExpensesProvider('trip-1').overrideWith(
            (ref) => Stream.value(<ExpenseWithSplits>[]),
          ),
        ],
        child: MaterialApp(
          home: SettingsScreen(trip: trip),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final testBtn = find.byKey(const Key('test_notification_btn'));
    await tester.scrollUntilVisible(
      testBtn,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(testBtn);
    await tester.pumpAndSettle();
    expect(testBtn, findsOneWidget);
    await tester.tap(testBtn);
    await tester.pumpAndSettle();

    expect(fakeClient.shownCount, equals(1));
    expect(fakeClient.lastTitle, contains('Euro Rail'));
  });
}
