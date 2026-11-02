import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/sync/sync_providers.dart';
import '../../../trips/domain/trip_model.dart';

/// Modal dialog allowing users to enter a 6-7 character Trip Invite Code
/// and join a collaborative cloud trip.
class JoinTripDialog extends ConsumerStatefulWidget {
  const JoinTripDialog({super.key});

  @override
  ConsumerState<JoinTripDialog> createState() => _JoinTripDialogState();
}

class _JoinTripDialogState extends ConsumerState<JoinTripDialog> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatInputCode(String input) {
    var raw = input.trim().toUpperCase().replaceAll(' ', '');
    // If user enters 6 letters/numbers without dash, e.g. "GOA782", auto-insert dash "GOA-782"
    if (raw.length == 6 && !raw.contains('-')) {
      raw = '${raw.substring(0, 3)}-${raw.substring(3)}';
    }
    return raw;
  }

  Future<void> _handleJoin() async {
    final rawCode = _formatInputCode(_controller.text);

    if (rawCode.isEmpty) {
      setState(() => _errorMessage = 'Please enter an invite code');
      return;
    }

    if (!RegExp(r'^[A-Z0-9]{3}-[A-Z0-9]{3}$').hasMatch(rawCode)) {
      setState(() => _errorMessage = 'Code must be in ABC-123 format');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final engine = ref.read(syncEngineProvider);
      final TripWithDetails trip = await engine.joinTripByCode(rawCode);

      if (mounted) {
        Navigator.of(context).pop(trip);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully joined "${trip.name}"!'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Navigate to the joined trip
        context.go('/trips/${trip.id}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.group_add, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Join Trip'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter the 6-character invite code shared by your friend to sync and collaborate on the trip.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('invite_code_input'),
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]')),
              LengthLimitingTextInputFormatter(7),
            ],
            decoration: InputDecoration(
              labelText: 'Invite Code',
              hintText: 'e.g. GOA-782',
              errorText: _errorMessage,
              prefixIcon: const Icon(Icons.key),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _handleJoin(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('submit_join_trip_btn'),
          onPressed: _isLoading ? null : _handleJoin,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Join Trip'),
        ),
      ],
    );
  }
}
