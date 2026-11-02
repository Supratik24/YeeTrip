import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_models.dart';
import '../../../../core/auth/auth_providers.dart';

/// Modal bottom sheet allowing users to sign in or create an account via
/// Google, Email/Password, or Indian Mobile OTP.
class AuthModal extends ConsumerStatefulWidget {
  const AuthModal({super.key});

  @override
  ConsumerState<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends ConsumerState<AuthModal> {
  int _selectedTab = 0; // 0: Google, 1: Email, 2: Phone
  bool _isLoading = false;
  String? _errorMessage;

  // Email form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  // Phone form controllers
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handlePostSignIn(UserProfile user) async {
    // Run zero-loss local trip migration
    final migrationService = ref.read(profileMigrationServiceProvider);
    final report = await migrationService.linkProfileToLocalTrips(user);

    if (mounted) {
      Navigator.of(context).pop(user);
      final msg = report.travelersLinked > 0
          ? 'Welcome, ${user.displayName}! Linked to ${report.travelersLinked} travelers in your trips.'
          : 'Welcome, ${user.displayName}!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      final user = await auth.signInWithGoogle();
      await _handlePostSignIn(user);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _handleEmailSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      final user = await auth.signInWithEmailPassword(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _displayNameController.text,
      );
      await _handlePostSignIn(user);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('FormatException: ', '');
        });
      }
    }
  }

  Future<void> _handlePhoneSignIn() async {
    if (!_otpSent) {
      final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      if (cleanPhone.length < 10) {
        setState(() => _errorMessage = 'Please enter a valid 10-digit mobile number');
        return;
      }
      setState(() {
        _otpSent = true;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      final user = await auth.signInWithPhone(
        phoneNumber: _phoneController.text,
        otp: _otpController.text,
        displayName: _displayNameController.text,
      );
      await _handlePostSignIn(user);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('FormatException: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
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
                    Icons.account_circle,
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
                        'Account & Cloud Profile',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Sign in to link your traveler profile across trips',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
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
            const SizedBox(height: 16),

            // Method Selector
            SegmentedButton<int>(
              key: const Key('auth_method_segmented_btn'),
              segments: const [
                ButtonSegment(value: 0, label: Text('Google')),
                ButtonSegment(value: 1, label: Text('Email')),
                ButtonSegment(value: 2, label: Text('Phone OTP')),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (set) => setState(() {
                _selectedTab = set.first;
                _errorMessage = null;
              }),
            ),
            const SizedBox(height: 20),

            // Tab Content
            if (_selectedTab == 0) ...[
              // Google Sign In
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.g_mobiledata, size: 48, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      'Fast & Secure Sign In',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Connect your Google Account to back up trips and link your name across group expenses.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  key: const Key('google_sign_in_btn'),
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.login),
                  label: const Text('Continue with Google'),
                ),
              ),
            ] else if (_selectedTab == 1) ...[
              // Email / Password Form
              TextField(
                key: const Key('auth_display_name_field'),
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Your Name (optional)',
                  hintText: 'e.g. Aarav Sharma',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('auth_email_field'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'e.g. aarav@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('auth_password_field'),
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'At least 6 characters',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  key: const Key('email_sign_in_btn'),
                  onPressed: _isLoading ? null : _handleEmailSignIn,
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Sign In / Register'),
                ),
              ),
            ] else ...[
              // Indian Mobile Phone OTP Form
              TextField(
                key: const Key('auth_phone_field'),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !_otpSent,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  prefixText: '+91 ',
                  hintText: '9876543210',
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_otpSent) ...[
                const SizedBox(height: 12),
                TextField(
                  key: const Key('auth_otp_field'),
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    labelText: '6-digit OTP',
                    hintText: 'Enter 123456',
                    prefixIcon: const Icon(Icons.pin),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  key: const Key('phone_submit_btn'),
                  onPressed: _isLoading ? null : _handlePhoneSignIn,
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_otpSent ? 'Verify OTP & Sign In' : 'Send Verification OTP'),
                ),
              ),
            ],

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
      ),
    );
  }
}
