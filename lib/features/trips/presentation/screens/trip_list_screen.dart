import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_models.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/money.dart';
import '../../../../core/notifications/notification_providers.dart';
import '../../../../core/notifications/notifications_sheet.dart';
import '../../../../core/theme_provider.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../core/widgets/traveler_avatar.dart';
import '../../../../data/providers.dart';
import '../../../auth/presentation/widgets/auth_modal.dart';
import '../../../sync/presentation/widgets/join_trip_dialog.dart';
import '../../domain/trip_model.dart';
import '../../services/demo_data_seeder.dart';
import '../widgets/trip_cover_picker.dart';

/// Home screen showing the list of trips.
class TripListScreen extends ConsumerWidget {
  const TripListScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TripWithDetails trip,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete trip?'),
        content: Text(
          'Are you sure you want to delete "${trip.name}"? '
          'This will permanently remove the trip and all its expenses.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(tripRepositoryProvider).deleteTrip(trip.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${trip.name}"')),
        );
      }
    }
  }

  Future<void> _handlePlanTrip(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authServiceProvider);
    if (auth.currentState.isGuest) {
      final user = await showModalBottomSheet<UserProfile>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const AuthModal(
          reason: 'Sign in or create an account to plan a trip',
        ),
      );
      if (user == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign-in is required to create a trip'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }
    if (context.mounted) {
      context.push('/trips/new');
    }
  }

  Future<void> _handleJoinTrip(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authServiceProvider);
    if (auth.currentState.isGuest) {
      final user = await showModalBottomSheet<UserProfile>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const AuthModal(
          reason: 'Sign in or create an account to join a trip',
          isJoining: true,
        ),
      );
      if (user == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign-in is required to join a trip'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => const JoinTripDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsStreamProvider);
    final notifications = ref.watch(globalNotificationsProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final theme = Theme.of(context);

    final (themeIcon, themeTooltip) = switch (themeMode) {
      ThemeMode.light => (Icons.light_mode_outlined, 'Theme: Light (tap for Dark)'),
      ThemeMode.dark => (Icons.dark_mode_outlined, 'Theme: Dark (tap for System)'),
      ThemeMode.system => (Icons.brightness_auto_outlined, 'Theme: System (tap for Light)'),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('YeeTrip'),
        actions: [
          IconButton(
            key: const Key('theme_toggle_btn'),
            tooltip: themeTooltip,
            icon: Icon(themeIcon),
            onPressed: () =>
                ref.read(appThemeModeProvider.notifier).cycleThemeMode(),
          ),
          IconButton(
            key: const Key('open_notifications_btn'),
            tooltip: 'Notifications & Reminders',
            icon: Badge.count(
              count: notifications.length,
              isLabelVisible: notifications.isNotEmpty,
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => NotificationsSheet.show(
              context,
              notifications: notifications,
            ),
          ),
          IconButton(
            key: const Key('join_trip_code_btn'),
            icon: const Icon(Icons.group_add_outlined),
            tooltip: 'Join trip with invite code',
            onPressed: () => _handleJoinTrip(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('plan_trip_fab'),
        onPressed: () => _handlePlanTrip(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Plan trip'),
      ),
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error loading trips: $err'),
          ),
        ),
        data: (trips) {
          if (trips.isEmpty) {
            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 16 * (1.0 - value)),
                    child: child,
                  ),
                );
              },
              child: Center(
                child: ResponsiveCenter(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo_transparent.png',
                          height: 80,
                          width: 80,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.flight_takeoff_rounded,
                            size: 64,
                            color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No trips planned yet',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Plan your group budget and split expenses offline with ease.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          key: const Key('plan_first_trip_btn'),
                          onPressed: () => _handlePlanTrip(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Plan your first trip'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          key: const Key('seed_demo_trip_btn'),
                          onPressed: () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Setting up demo trip...'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                            try {
                              final tripId = await DemoDataSeeder.seedDemoTrip(
                                tripRepo: ref.read(tripRepositoryProvider),
                                expenseRepo: ref.read(expenseRepositoryProvider),
                                itineraryRepo:
                                    ref.read(itineraryRepositoryProvider),
                              );
                              if (context.mounted) {
                                context.go('/trips/$tripId');
                              }
                            } catch (e) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('Failed to seed demo trip: $e')),
                              );
                            }
                          },
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Explore with demo trip'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 16 * (1.0 - value)),
                  child: child,
                ),
              );
            },
            child: ResponsiveCenter(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                itemCount: trips.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
              final trip = trips[index];
              final isOverBudget = trip.remainingBudgetPaise < 0;
              final double budgetProgress = trip.totalBudgetPaise > 0
                  ? (trip.totalSpentPaise / trip.totalBudgetPaise).clamp(0.0, 1.0)
                  : 0.0;
              final isCritical = trip.totalBudgetPaise > 0 &&
                  (trip.totalSpentPaise / trip.totalBudgetPaise) >= 0.90;
              final isWarning = trip.totalBudgetPaise > 0 &&
                  (trip.totalSpentPaise / trip.totalBudgetPaise) >= 0.70 &&
                  !isCritical;

              final burnColor = isOverBudget || isCritical
                  ? theme.colorScheme.error
                  : isWarning
                      ? Colors.amber.shade700
                      : const Color(0xFF10B981); // Emerald Green
              final hasCover = trip.coverPhotoPath != null &&
                  trip.coverPhotoPath!.isNotEmpty &&
                  File(trip.coverPhotoPath!).existsSync();
              final dateSpan =
                  formatTripDateSpan(trip.startDate, trip.endDate);

              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.go('/trips/${trip.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasCover)
                        SizedBox(
                          key: Key('trip_cover_banner_${trip.id}'),
                          height: 118,
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
                                      Colors.black.withValues(alpha: 0.6),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 12,
                                bottom: 10,
                                right: 12,
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    if (trip.destination != null &&
                                        trip.destination!.trim().isNotEmpty)
                                      _CoverOverlayChip(
                                        icon: Icons.location_on,
                                        label: trip.destination!.trim(),
                                      ),
                                    if (dateSpan != null)
                                      _CoverOverlayChip(
                                        icon: Icons.date_range,
                                        label: dateSpan,
                                      ),
                                    if (trip.isCompleted)
                                      const _CoverOverlayChip(
                                        icon: Icons.check_circle,
                                        label: 'Completed',
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              trip.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (trip.isCompleted && !hasCover) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF10B981)
                                                    .withValues(alpha: 0.14),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                'Completed',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF059669),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${trip.days} ${trip.days == 1 ? "day" : "days"} • ${trip.travelers.length} ${trip.travelers.length == 1 ? "traveler" : "travelers"}${!hasCover && dateSpan != null ? " • $dateSpan" : ""}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20),
                                  color: Colors.grey.shade500,
                                  onPressed: () =>
                                      _confirmDelete(context, ref, trip),
                                  tooltip: 'Delete trip',
                                ),
                              ],
                            ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Budget',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      Money.formatAmount(
                                        trip.totalBudgetPaise,
                                        currencyCode: trip.currency,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Spent',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.center,
                                    child: Text(
                                      Money.formatAmount(
                                        trip.totalSpentPaise,
                                        currencyCode: trip.currency,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    isOverBudget ? 'Over by' : 'Remaining',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isOverBudget
                                          ? theme.colorScheme.error
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      Money.formatAmount(
                                        trip.remainingBudgetPaise.abs(),
                                        currencyCode: trip.currency,
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isOverBudget
                                            ? theme.colorScheme.error
                                            : theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Visual Budget Burn Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: budgetProgress,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            valueColor: AlwaysStoppedAnimation<Color>(burnColor),
                            minHeight: 6,
                          ),
                        ),
                        if (trip.travelers.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                height: 26,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (int i = 0; i < trip.travelers.take(4).length; i++)
                                      Align(
                                        widthFactor: 0.75,
                                        child: TravelerAvatar(
                                          name: trip.travelers[i].name,
                                          avatarPath:
                                              trip.travelers[i].avatarPath,
                                          radius: 12,
                                          fontSize: 9,
                                        ),
                                      ),
                                    if (trip.travelers.length > 4)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Text(
                                          '+${trip.travelers.length - 4}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (!hasCover &&
                                  trip.destination != null &&
                                  trip.destination!.trim().isNotEmpty) ...[
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 12,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        trip.destination!.trim(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
  },
  ),
  );
  }
}

class _CoverOverlayChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CoverOverlayChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
