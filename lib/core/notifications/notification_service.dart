import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/trips/domain/trip_model.dart';
import 'notification_models.dart';

/// Abstraction for local notification delivery & scheduling, mockable in unit/widget tests.
abstract class LocalNotificationClient {
  Future<void> initialize();
  Future<bool> requestPermissions();
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  });
  Future<void> cancelNotification(int id);
}

/// Real OS notification client powered by `flutter_local_notifications`.
class FlutterLocalNotificationClient implements LocalNotificationClient {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _tzInitialized = false;

  static const String _channelId = 'yeetrip_reminders';
  static const String _channelName = 'Trip & Budget Reminders';
  static const String _channelDesc =
      'Upcoming trip alerts, daily budget warnings, and settlement nudges.';

  void _ensureTimezones() {
    if (_tzInitialized) return;
    tz_data.initializeTimeZones();
    _tzInitialized = true;
  }

  tz.Location _resolveLocalLocation() {
    _ensureTimezones();
    final nowOffset = DateTime.now().timeZoneOffset;
    // Prefer Asia/Kolkata if +05:30
    if (nowOffset.inMinutes == 330 &&
        tz.timeZoneDatabase.locations.containsKey('Asia/Kolkata')) {
      return tz.getLocation('Asia/Kolkata');
    }
    for (final loc in tz.timeZoneDatabase.locations.values) {
      if (loc.currentTimeZone.offset == nowOffset) {
        return loc;
      }
    }
    return tz.UTC;
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _ensureTimezones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    final initSettings = const InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    try {
      await _plugin.initialize(settings: initSettings);
      _initialized = true;
    } catch (e) {
      debugPrint('Notification initialization skipped/failed: $e');
    }
  }

  @override
  Future<bool> requestPermissions() async {
    await initialize();
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        return await androidPlugin?.requestNotificationsPermission() ?? true;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        return await iosPlugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            true;
      }
    } catch (e) {
      debugPrint('Notification permission request skipped: $e');
    }
    return true;
  }

  NotificationDetails _buildDetails() {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    return const NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _buildDetails(),
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    if (!scheduledAt.isAfter(DateTime.now())) return;
    await initialize();
    try {
      final location = _resolveLocalLocation();
      final tzDate = tz.TZDateTime.from(scheduledAt, location);
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzDate,
        notificationDetails: _buildDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id: id);
    } catch (_) {}
  }
}

/// Manages local notification preferences, dismissed alerts, and OS reminders.
class TripNotificationService {
  static const _prefTripStart = 'notif_trip_start';
  static const _prefBudgetAlerts = 'notif_budget_alerts';
  static const _prefSettleReminders = 'notif_settle_reminders';
  static const _prefItineraryReminders = 'notif_itinerary_reminders';
  static const _prefDismissedIds = 'notif_dismissed_ids';

  final LocalNotificationClient _client;

  TripNotificationService({LocalNotificationClient? client})
      : _client = client ?? FlutterLocalNotificationClient();

  Future<NotificationPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPreferences(
      tripStartReminders: prefs.getBool(_prefTripStart) ?? true,
      budgetBurnAlerts: prefs.getBool(_prefBudgetAlerts) ?? true,
      settlementReminders: prefs.getBool(_prefSettleReminders) ?? true,
      itineraryReminders: prefs.getBool(_prefItineraryReminders) ?? true,
    );
  }

  Future<void> savePreferences(NotificationPreferences value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefTripStart, value.tripStartReminders);
    await prefs.setBool(_prefBudgetAlerts, value.budgetBurnAlerts);
    await prefs.setBool(_prefSettleReminders, value.settlementReminders);
    await prefs.setBool(_prefItineraryReminders, value.itineraryReminders);
  }

  Future<Set<String>> loadDismissedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_prefDismissedIds) ?? const []).toSet();
  }

  Future<void> dismissNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = (prefs.getStringList(_prefDismissedIds) ?? const []).toSet();
    current.add(id);
    // Keep only most recent 100 entries so SharedPreferences stays bounded.
    final list = current.toList();
    if (list.length > 100) {
      list.removeRange(0, list.length - 100);
    }
    await prefs.setStringList(_prefDismissedIds, list);
  }

  Future<void> dismissAll(Iterable<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final current = (prefs.getStringList(_prefDismissedIds) ?? const []).toSet();
    current.addAll(ids);
    final list = current.toList();
    if (list.length > 100) {
      list.removeRange(0, list.length - 100);
    }
    await prefs.setStringList(_prefDismissedIds, list);
  }

  Future<bool> requestPermissions() => _client.requestPermissions();

  Future<void> sendInstantAlert({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _client.requestPermissions();
    final notifId = DateTime.now().millisecondsSinceEpoch.remainder(1 << 30);
    await _client.showNotification(
      id: notifId,
      title: title,
      body: body,
      payload: payload,
    );
  }

  /// Schedules a local OS notification 1 day before [trip.startDate] at 09:00 AM.
  Future<void> scheduleTripStartReminder(TripWithDetails trip) async {
    if (trip.startDate == null || trip.isCompleted) return;
    final prefs = await loadPreferences();
    if (!prefs.tripStartReminders) return;

    final reminderDay = trip.startDate!.subtract(const Duration(days: 1));
    final scheduledAt = DateTime(
      reminderDay.year,
      reminderDay.month,
      reminderDay.day,
      9,
      0,
    );
    final notifId = trip.id.hashCode.abs().remainder(1 << 30);
    await _client.cancelNotification(notifId);
    if (scheduledAt.isAfter(DateTime.now())) {
      await _client.requestPermissions();
      await _client.scheduleNotification(
        id: notifId,
        title: '${trip.name} starts tomorrow!',
        body: trip.destination != null && trip.destination!.isNotEmpty
            ? 'Get ready for ${trip.destination}. Check your Day 1 plan in YeeTrip.'
            : 'Tap to review your itinerary and budget before departure.',
        scheduledAt: scheduledAt,
        payload: '/trips/${trip.id}/itinerary',
      );
    }
  }
}
