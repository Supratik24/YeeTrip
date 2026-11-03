import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_providers.dart';
import '../../../../core/locale_provider.dart';
import '../../../../core/money.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../data/providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/widgets/auth_modal.dart';
import '../../../auth/presentation/widgets/edit_profile_dialog.dart';
import '../../../sync/presentation/widgets/cloud_sync_sheet.dart';
import '../../../trips/domain/trip_model.dart';
import '../../../trips/services/trip_backup_service.dart';
import '../../services/csv_exporter.dart';

/// Settings screen for YeeTrip: exports trip expenses to CSV and provides app information.
class SettingsScreen extends ConsumerStatefulWidget {
  final TripWithDetails trip;

  const SettingsScreen({
    super.key,
    required this.trip,
  });

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isExporting = false;

  Future<void> _handleExport() async {
    final expensesAsync = ref.read(tripExpensesProvider(widget.trip.id));
    final expenses = expensesAsync.value ?? [];

    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No expenses logged yet to export.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isExporting = true);
    try {
      await CsvExporter.exportAndShare(
        trip: widget.trip,
        expenses: expenses,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export CSV: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  bool _isBackingUp = false;

  Future<void> _handleBackupJson() async {
    final expensesAsync = ref.read(tripExpensesProvider(widget.trip.id));
    final expenses = expensesAsync.value ?? [];

    setState(() => _isBackingUp = true);
    try {
      await TripBackupService.exportAndShareBackup(
        trip: widget.trip,
        expenses: expenses,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to backup trip: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  Future<void> _handleRestoreJson() async {
    final textController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore trip from backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste the contents of a .yeetrip.json backup file below to restore the trip and its expenses:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('restore_trip_json_field'),
              controller: textController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '{\n  "version": 1,\n  "trip": { ... }\n}',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm_restore_btn'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed == true && textController.text.trim().isNotEmpty) {
      try {
        final backupService = ref.read(tripBackupServiceProvider);
        final newTripId =
            await backupService.restoreTripFromJson(textController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip restored successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.push('/trips/$newTripId');
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Restore Failed'),
              content: Text('Could not restore trip: $e'),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final activeLocale = ref.watch(appLocaleProvider);
    final expensesAsync = ref.watch(tripExpensesProvider(widget.trip.id));
    final expenseCount = expensesAsync.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settingsTab ?? 'Settings'),
      ),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Account & Cloud Profile Card
            _buildAccountCard(context, ref),
            const SizedBox(height: 16),

            // Trip Summary Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flight_takeoff, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.trip.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        key: const Key('edit_trip_summary_btn'),
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: l10n?.editTripDetails ?? 'Edit trip details',
                        onPressed: () => context.push('/trips/${widget.trip.id}/edit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    l10n?.totalBudget ?? 'Total budget',
                    Money.formatRupees(widget.trip.totalBudgetPaise),
                  ),
                  const SizedBox(height: 6),
                  _buildDetailRow(
                    context,
                    l10n?.duration ?? 'Duration',
                    '${widget.trip.days} ${widget.trip.days == 1 ? (l10n?.day ?? "day") : (l10n?.days ?? "days")}',
                  ),
                  const SizedBox(height: 6),
                  _buildDetailRow(
                    context,
                    l10n?.travelers ?? 'Travelers',
                    '${widget.trip.travelers.length} (${widget.trip.travelers.map((t) => t.name).join(", ")})',
                  ),
                  const SizedBox(height: 6),
                  _buildDetailRow(
                    context,
                    l10n?.loggedExpenses ?? 'Logged expenses',
                    '$expenseCount ${l10n?.recorded ?? "recorded"}',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('edit_trip_and_travelers_btn'),
                      onPressed: () => context.push('/trips/${widget.trip.id}/edit'),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(l10n?.editTripAndTravelers ?? 'Edit trip & travelers'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cloud Collaboration & Sync Card
          Card(
            key: const Key('cloud_sync_card'),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud_sync, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cloud Sync & Collaboration',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Collaborate with group members via a 6-character Invite Code. Works offline with deterministic sync.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('open_cloud_sync_sheet_btn'),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => CloudSyncSheet(trip: widget.trip),
                      ),
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Manage Cloud Sync & Code'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Language Selector Card
          Card(
            key: const Key('language_card'),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.language, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n?.language ?? 'Language',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n?.languageSubtitle ?? 'Select your preferred display language',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      key: const Key('language_segmented_button'),
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment<String>(
                          value: 'en',
                          label: Text(l10n?.english ?? 'English'),
                        ),
                        ButtonSegment<String>(
                          value: 'hi',
                          label: Text(l10n?.hindi ?? 'हिन्दी (Hindi)'),
                        ),
                      ],
                      selected: {
                        activeLocale?.languageCode == 'hi' ? 'hi' : 'en',
                      },
                      onSelectionChanged: (selectedSet) {
                        final selectedCode = selectedSet.first;
                        ref.read(appLocaleProvider.notifier).setLanguage(
                              selectedCode == 'hi'
                                  ? AppLanguage.hindi
                                  : AppLanguage.english,
                            );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Data Export Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.file_download_outlined, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n?.dataExport ?? 'Data export',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n?.dataExportDesc(widget.trip.name) ??
                        'Export all logged expenses for "${widget.trip.name}" as an RFC 4180 compliant CSV file.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: _isExporting ? null : _handleExport,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.share_outlined),
                      label: Text(
                        _isExporting
                            ? (l10n?.exporting ?? 'Exporting...')
                            : (l10n?.exportAndShareCsv ?? 'Export & share CSV'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('backup_trip_json_btn'),
                      onPressed: _isBackingUp ? null : _handleBackupJson,
                      icon: _isBackingUp
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.archive_outlined),
                      label: Text(
                        _isBackingUp ? 'Creating backup...' : 'Backup trip (.json)',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('restore_trip_from_settings_btn'),
                      onPressed: _handleRestoreJson,
                      icon: const Icon(Icons.unarchive_outlined),
                      label: const Text('Restore trip from backup'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // About YeeTrip Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/logo_transparent.png',
                          width: 32,
                          height: 32,
                          errorBuilder: (_, _, _) => Icon(Icons.wallet, color: colorScheme.primary, size: 28),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n?.aboutYeeTrip ?? 'About YeeTrip',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n?.aboutYeeTripDesc ??
                        'YeeTrip is an offline-first group trip budget and expense-splitting app crafted specifically for Indian travelers.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildFeaturePoint(
                    context,
                    Icons.offline_pin_outlined,
                    l10n?.offlinePrivate ?? '100% Offline & Private',
                    l10n?.offlinePrivateDesc ??
                        'All trip data and expenses remain strictly on this phone. No accounts or internet required.',
                  ),
                  const SizedBox(height: 8),
                  _buildFeaturePoint(
                    context,
                    Icons.currency_rupee,
                    l10n?.precisionTitle ?? 'Exact Integer Paise Precision',
                    l10n?.precisionDesc ??
                        'Calculated in exact integer paise to prevent floating-point rounding errors. Formatted in standard Indian numbering (₹1,00,000).',
                  ),
                  const SizedBox(height: 8),
                  _buildFeaturePoint(
                    context,
                    Icons.handshake_outlined,
                    l10n?.settlementTitle ?? 'Minimum Transactions Settlement',
                    l10n?.settlementDesc ??
                        'Greedy balance netting algorithm calculates the fewest peer-to-peer transfers to settle all trip debts.',
                  ),
                  const SizedBox(height: 16),
                  Divider(color: colorScheme.outlineVariant),
                  const SizedBox(height: 8),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'YeeTrip Core v1.0.0 • Offline Edition',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton.icon(
                          key: const Key('replay_splash_animation_btn'),
                          onPressed: () => context.push('/splash'),
                          icon: const Icon(Icons.play_circle_outline, size: 16),
                          label: const Text('Replay intro animation'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildAccountCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authStateProvider).value ?? ref.watch(authServiceProvider).currentState;
    final user = authState.user;

    return Card(
      key: const Key('account_profile_card'),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: user == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.person_outline, color: Colors.amber.shade900, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guest User',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Local offline mode',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sign in or create an account to backup your trips to cloud and link your traveler profile across trips.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('open_auth_modal_btn'),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const AuthModal(),
                      ),
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text('Sign In / Create Account'),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              user.email ?? user.phoneNumber ?? 'Authenticated User',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (user.defaultUpiVpa != null && user.defaultUpiVpa!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance, size: 14, color: Colors.green.shade800),
                          const SizedBox(width: 6),
                          Text(
                            'UPI: ${user.defaultUpiVpa}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('edit_profile_btn'),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => EditProfileDialog(user: user),
                          ),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit Profile'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        key: const Key('sign_out_btn'),
                        onPressed: () => ref.read(authServiceProvider).signOut(),
                        icon: const Icon(Icons.logout, size: 16),
                        label: const Text('Sign Out'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturePoint(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
