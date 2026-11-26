import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../features/expenses/domain/expense_model.dart';
import '../../features/trips/domain/trip_model.dart';
import 'notification_models.dart';
import 'notification_rule_engine.dart';
import 'notification_service.dart';

/// Provider for the OS local notification wrapper (overridable in tests).
final localNotificationClientProvider = Provider<LocalNotificationClient>((ref) {
  return FlutterLocalNotificationClient();
});

/// Provider for TripNotificationService.
final tripNotificationServiceProvider = Provider<TripNotificationService>((ref) {
  return TripNotificationService(
    client: ref.watch(localNotificationClientProvider),
  );
});

/// Manages user notification preferences cleanly across Settings and rule evaluation.
class NotificationPreferencesNotifier extends Notifier<NotificationPreferences> {
  bool _loaded = false;

  @override
  NotificationPreferences build() {
    if (!_loaded) {
      _loaded = true;
      _loadAsync();
    }
    return const NotificationPreferences();
  }

  Future<void> _loadAsync() async {
    try {
      final prefs =
          await ref.read(tripNotificationServiceProvider).loadPreferences();
      state = prefs;
    } catch (_) {
      // Safe fallback in isolated widget test environments without SharedPreferences channel
    }
  }

  Future<void> updatePreferences(NotificationPreferences next) async {
    state = next;
    try {
      await ref.read(tripNotificationServiceProvider).savePreferences(next);
    } catch (_) {}
  }
}

final notificationPreferencesProvider =
    NotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
  () => NotificationPreferencesNotifier(),
);

/// Manages dismissed notification IDs without blocking UI on SharedPreferences.
class DismissedNotificationsNotifier extends Notifier<Set<String>> {
  bool _loaded = false;

  @override
  Set<String> build() {
    if (!_loaded) {
      _loaded = true;
      _loadAsync();
    }
    return const {};
  }

  Future<void> _loadAsync() async {
    try {
      final ids =
          await ref.read(tripNotificationServiceProvider).loadDismissedIds();
      state = ids;
    } catch (_) {}
  }

  Future<void> dismiss(String id) async {
    state = {...state, id};
    try {
      await ref.read(tripNotificationServiceProvider).dismissNotification(id);
    } catch (_) {}
  }

  Future<void> dismissAll(Iterable<String> ids) async {
    state = {...state, ...ids};
    try {
      await ref.read(tripNotificationServiceProvider).dismissAll(ids);
    } catch (_) {}
  }
}

final dismissedNotificationsProvider =
    NotifierProvider<DismissedNotificationsNotifier, Set<String>>(
  () => DismissedNotificationsNotifier(),
);

const _ruleEngine = NotificationRuleEngine();

/// Global notifications computed from tripsStreamProvider (safe in TripListScreen tests without DB access).
final globalNotificationsProvider = Provider<List<AppNotificationItem>>((ref) {
  final tripsAsync = ref.watch(tripsStreamProvider);
  final trips = tripsAsync.asData?.value ?? const <TripWithDetails>[];
  final prefs = ref.watch(notificationPreferencesProvider);
  final dismissed = ref.watch(dismissedNotificationsProvider);

  return _ruleEngine.evaluate(
    trips: trips,
    preferences: prefs,
    dismissedIds: dismissed,
  );
});

/// Per-trip notifications combining trip details + expenses (no extra DB isolates opened!).
final tripNotificationsProvider =
    Provider.family<List<AppNotificationItem>, TripWithDetails>((ref, trip) {
  final expensesAsync = ref.watch(tripExpensesProvider(trip.id));
  final expenses = expensesAsync.asData?.value ?? const <ExpenseWithSplits>[];
  final prefs = ref.watch(notificationPreferencesProvider);
  final dismissed = ref.watch(dismissedNotificationsProvider);

  final effectiveSpent = expenses.isNotEmpty
      ? expenses
          .where((e) => e.confirmed && e.source != 'settlement')
          .fold<int>(0, (sum, e) => sum + e.amountPaise)
      : trip.totalSpentPaise;

  return _ruleEngine.evaluate(
    trips: [trip.copyWith(totalSpentPaise: effectiveSpent)],
    expensesByTrip: {trip.id: expenses},
    preferences: prefs,
    dismissedIds: dismissed,
  );
});
