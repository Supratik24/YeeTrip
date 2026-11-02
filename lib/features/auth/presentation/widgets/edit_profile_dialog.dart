import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_models.dart';
import '../../../../core/auth/auth_providers.dart';

/// Dialog allowing user to update display name and default UPI VPA.
class EditProfileDialog extends ConsumerStatefulWidget {
  final UserProfile user;

  const EditProfileDialog({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _upiController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _upiController = TextEditingController(text: widget.user.defaultUpiVpa ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Display name cannot be empty');
      return;
    }

    final upi = _upiController.text.trim();
    if (upi.isNotEmpty && !RegExp(r'^[\w.\-]+@[\w.\-]+$').hasMatch(upi)) {
      setState(() => _errorMessage = 'Please enter a valid UPI ID (e.g. name@bank)');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      final updated = await auth.updateProfile(
        displayName: name,
        defaultUpiVpa: upi.isNotEmpty ? upi : null,
      );

      // Re-run migration so any newly linked UPI applies to existing trips
      final migration = ref.read(profileMigrationServiceProvider);
      await migration.linkProfileToLocalTrips(updated);

      if (mounted) {
        Navigator.of(context).pop(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
          Icon(Icons.edit, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Edit Profile'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('profile_name_input'),
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              hintText: 'e.g. Aarav Sharma',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('profile_upi_input'),
            controller: _upiController,
            decoration: const InputDecoration(
              labelText: 'Default UPI ID (for receiving settlements)',
              hintText: 'e.g. aarav@oksbi',
              prefixIcon: Icon(Icons.account_balance),
              border: OutlineInputBorder(),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('save_profile_btn'),
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}
