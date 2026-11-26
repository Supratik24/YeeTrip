import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'notification_models.dart';
import 'notification_providers.dart';

/// Shows an in-app reminders and alerts sheet.
class NotificationsSheet extends ConsumerWidget {
  final List<AppNotificationItem> notifications;
  final String? activeTripId;

  const NotificationsSheet({
    super.key,
    required this.notifications,
    this.activeTripId,
  });

  static Future<void> show(
    BuildContext context, {
    required List<AppNotificationItem> notifications,
    String? activeTripId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => NotificationsSheet(
        notifications: notifications,
        activeTripId: activeTripId,
      ),
    );
  }

  IconData _iconFor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.tripStart:
        return Icons.flight_takeoff_rounded;
      case AppNotificationType.budgetAlert:
        return Icons.warning_amber_rounded;
      case AppNotificationType.settlementReminder:
        return Icons.handshake_outlined;
      case AppNotificationType.itineraryUpcoming:
        return Icons.event_note_rounded;
    }
  }

  Color _colorFor(AppNotificationSeverity severity, ThemeData theme) {
    switch (severity) {
      case AppNotificationSeverity.critical:
        return theme.colorScheme.error;
      case AppNotificationSeverity.warning:
        return Colors.orange.shade700;
      case AppNotificationSeverity.info:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dismissed = ref.watch(dismissedNotificationsProvider);
    final visible = notifications.where((n) => !dismissed.contains(n.id)).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (ctx, scrollController) {
        return Padding(
          key: const Key('notifications_sheet'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.notifications_active_outlined,
                      color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Trip & Budget Reminders',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (visible.isNotEmpty)
                    TextButton(
                      key: const Key('clear_all_notifications_btn'),
                      onPressed: () {
                        ref
                            .read(dismissedNotificationsProvider.notifier)
                            .dismissAll(visible.map((e) => e.id));
                      },
                      child: const Text('Clear all'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: visible.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'You are all caught up!',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Upcoming departures, budget alerts, and pending settlements appear here.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = visible[index];
                          final accent = _colorFor(item.severity, theme);
                          return Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: accent.withValues(alpha: 0.14),
                                child: Icon(_iconFor(item.type), color: accent),
                              ),
                              title: Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  item.body,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                tooltip: 'Dismiss',
                                onPressed: () {
                                  ref
                                      .read(dismissedNotificationsProvider.notifier)
                                      .dismiss(item.id);
                                },
                              ),
                              onTap: item.actionRoute != null
                                  ? () {
                                      Navigator.of(context).pop();
                                      if (activeTripId == null ||
                                          item.actionRoute != '/trips/$activeTripId') {
                                        context.push(item.actionRoute!);
                                      }
                                    }
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
