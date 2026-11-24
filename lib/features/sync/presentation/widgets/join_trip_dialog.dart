import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_models.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../auth/presentation/widgets/auth_modal.dart';
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
  final _upiController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _upiErrorMessage;

  @override
  void initState() {
    super.initState();
    final currentUpi = ref.read(currentUserProvider)?.defaultUpiVpa;
    if (currentUpi != null && currentUpi.isNotEmpty) {
      _upiController.text = currentUpi;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _upiController.dispose();
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

    final auth = ref.read(authServiceProvider);
    if (auth.currentState.isGuest) {
      final user = await showModalBottomSheet<UserProfile>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AuthModal(
          reason: 'Sign in or create an account to join this trip',
          isJoining: true,
          prefilledUpi: _upiController.text.trim().isNotEmpty ? _upiController.text.trim() : null,
        ),
      );
      if (user == null) {
        setState(() => _errorMessage = 'Sign-in is required to join a trip');
        return;
      }
      if (user.defaultUpiVpa != null && user.defaultUpiVpa!.isNotEmpty) {
        _upiController.text = user.defaultUpiVpa!;
      }
    }

    final upi = _upiController.text.trim();
    if (upi.isEmpty) {
      setState(() => _upiErrorMessage = 'UPI ID is required to join a trip');
      return;
    }

    if (!RegExp(r'^[\w.\-]+@[\w.\-]+$').hasMatch(upi)) {
      setState(() => _upiErrorMessage = 'Enter a valid UPI ID (e.g. name@okhdfcbank)');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _upiErrorMessage = null;
    });

    try {
      final engine = ref.read(syncEngineProvider);
      final TripWithDetails trip = await engine.joinTripByCode(rawCode);

      // Save confirmed mandatory UPI to profile
      await auth.updateProfile(defaultUpiVpa: upi);

      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        final migration = ref.read(profileMigrationServiceProvider);
        await migration.linkProfileToLocalTrips(currentUser.copyWith(defaultUpiVpa: upi));
      }

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
        try {
          context.go('/trips/${trip.id}');
        } catch (_) {}
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
              labelText: 'Invite Code *',
              hintText: 'e.g. GOA-782',
              errorText: _errorMessage,
              prefixIcon: const Icon(Icons.key),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _handleJoin(),
          ),
          const SizedBox(height: 14),
          TextField(
            key: const Key('join_trip_upi_input'),
            controller: _upiController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Your UPI ID * (Required)',
              hintText: 'e.g. name@bank or 9876543210@upi',
              helperText: 'Caution: Please add correct UPI ID for seamless settlement',
              errorText: _upiErrorMessage,
              prefixIcon: const Icon(Icons.account_balance),
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
