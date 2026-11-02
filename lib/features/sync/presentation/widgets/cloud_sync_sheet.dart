import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/sync/sync_models.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../trips/domain/trip_model.dart';

/// Modal bottom sheet for viewing and managing a trip's cloud sync room,
/// invite code, collaboration, and instant sync.
class CloudSyncSheet extends ConsumerStatefulWidget {
  final TripWithDetails trip;

  const CloudSyncSheet({
    super.key,
    required this.trip,
  });

  @override
  ConsumerState<CloudSyncSheet> createState() => _CloudSyncSheetState();
}

class _CloudSyncSheetState extends ConsumerState<CloudSyncSheet> {
  bool _isEnabling = false;
  bool _isSyncing = false;
  String? _syncMessage;

  Future<void> _handleEnableShare() async {
    setState(() => _isEnabling = true);
    try {
      final engine = ref.read(syncEngineProvider);
      await engine.shareTrip(widget.trip.id);
      if (mounted) {
        setState(() => _isEnabling = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isEnabling = false;
          _syncMessage = 'Failed to enable cloud sync: $e';
        });
      }
    }
  }

  Future<void> _handleSyncNow() async {
    setState(() {
      _isSyncing = true;
      _syncMessage = null;
    });

    try {
      final engine = ref.read(syncEngineProvider);
      final report = await engine.syncTrip(widget.trip.id);
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _syncMessage = report.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _syncMessage = 'Sync error: $e';
        });
      }
    }
  }

  void _copyInviteCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invite code "$code" copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _shareInviteCode(String code) async {
    await SharePlus.instance.share(
      ShareParams(
        subject: 'Join "${widget.trip.name}" on YeeTrip',
        text: 'Join our trip "${widget.trip.name}" on YeeTrip! Use Invite Code: $code to collaborate and track expenses.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roomAsync = ref.watch(tripSyncRoomProvider(widget.trip.id));
    final room = roomAsync.value;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.cloud_sync,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cloud Sync & Collaboration',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.trip.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (room == null) ...[
            // Not shared yet state
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wifi_off, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Currently Local Only',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This trip is saved on this device. Enable cloud collaboration to get a 6-character Invite Code that friends can use to view and add expenses together.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                key: const Key('enable_cloud_sync_btn'),
                onPressed: _isEnabling ? null : _handleEnableShare,
                icon: _isEnabling
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.cloud_upload),
                label: const Text('Enable Cloud Collaboration'),
              ),
            ),
          ] else ...[
            // Already shared: Invite Code Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRIP INVITE CODE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          room.inviteCode,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.0,
                            fontFamily: 'monospace',
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton.filledTonal(
                        key: const Key('copy_invite_code_btn'),
                        icon: const Icon(Icons.copy, size: 20),
                        tooltip: 'Copy Code',
                        onPressed: () => _copyInviteCode(room.inviteCode),
                      ),
                      const SizedBox(width: 6),
                      IconButton.filled(
                        key: const Key('share_invite_code_btn'),
                        icon: const Icon(Icons.share, size: 20),
                        tooltip: 'Share Code',
                        onPressed: () => _shareInviteCode(room.inviteCode),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Share this code with your travel group so they can join and log expenses.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sync Status Indicator
            _buildSyncStatusBadge(context, room),
            const SizedBox(height: 16),

            // Sync Now Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.tonalIcon(
                key: const Key('sync_now_btn'),
                onPressed: _isSyncing ? null : _handleSyncNow,
                icon: _isSyncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: const Text('Sync Now'),
              ),
            ),
          ],

          if (_syncMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _syncMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncStatusBadge(BuildContext context, TripSyncRoom room) {
    final (badgeColor, textColor, iconData, statusLabel) = switch (room.status) {
      SyncStatus.synced => (
          Colors.green.shade50,
          Colors.green.shade800,
          Icons.cloud_done,
          'All changes synced to cloud',
        ),
      SyncStatus.syncing => (
          Colors.blue.shade50,
          Colors.blue.shade800,
          Icons.sync,
          'Syncing in progress...',
        ),
      SyncStatus.offline => (
          Colors.amber.shade50,
          Colors.amber.shade900,
          Icons.cloud_off,
          'Offline: ${room.pendingChangesCount} pending changes queued',
        ),
      SyncStatus.error => (
          Colors.red.shade50,
          Colors.red.shade800,
          Icons.error_outline,
          'Sync error occurred',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(iconData, color: textColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                if (room.lastSyncedAt != null)
                  Text(
                    'Last synced: ${room.lastSyncedAt!.toLocal().toIso8601String().substring(11, 16)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
