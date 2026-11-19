import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/auth/auth_models.dart';
import '../../../../core/auth/auth_providers.dart';

/// Modal bottom sheet allowing users to sign in or create an account via
/// Google, Email/Password, or Indian Mobile OTP.
class AuthModal extends ConsumerStatefulWidget {
  final String? reason;
  final bool isJoining;
  final String? prefilledUpi;

  const AuthModal({
    super.key,
    this.reason,
    this.isJoining = false,
    this.prefilledUpi,
  });

  @override
  ConsumerState<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends ConsumerState<AuthModal> {
  int _selectedTab = 0; // 0: Google, 1: Email, 2: Phone
  bool _isLoading = false;
  String? _errorMessage;

  // Google OAuth Step 2 profile completion state
  bool _isGoogleProfileStep = false;
  GoogleSignInAccount? _pendingGoogleAccount;
  final _profileNameController = TextEditingController();
  final _profileUpiController = TextEditingController();
  String? _profileNameError;
  String? _profileUpiError;

  // Google form controllers
  final _googleEmailController = TextEditingController();
  final _googleNameController = TextEditingController();
  final _googleUpiController = TextEditingController();

  // Email form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  // Phone form controllers
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    // Do not pre-fill generated bank names; user writes their own UPI ID.
  }

  @override
  void dispose() {
    _profileNameController.dispose();
    _profileUpiController.dispose();
    _googleEmailController.dispose();
    _googleNameController.dispose();
    _googleUpiController.dispose();
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

  Future<void> _handleGoogleOAuthSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _profileNameError = null;
      _profileUpiError = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      final account = await auth.authenticateWithGoogleOAuth();

      if (mounted) {
        setState(() {
          _pendingGoogleAccount = account;
          _profileNameController.text = account.displayName?.trim().isNotEmpty == true
              ? account.displayName!.trim()
              : auth.deriveDisplayNameFromEmail(account.email);

          // Never auto-fill bank names. User must type their own UPI ID!
          _profileUpiController.clear();

          _isGoogleProfileStep = true;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          final err = e.toString();
          if (err.contains('canceled') || err.contains('cancelled') || err.contains('Sign in canceled')) {
            _errorMessage = 'Google sign-in was cancelled';
          } else {
            _errorMessage = 'Google OAuth: $err. You can also sign in manually below.';
          }
        });
      }
    }
  }

  Future<void> _handleCompleteGoogleProfile() async {
    final name = _profileNameController.text.trim();
    final upi = _profileUpiController.text.trim();

    setState(() {
      _profileNameError = null;
      _profileUpiError = null;
    });

    if (name.isEmpty) {
      setState(() => _profileNameError = 'Please enter your display name');
      return;
    }

    if (upi.isEmpty) {
      setState(() => _profileUpiError = 'UPI ID is mandatory (e.g. yourname@okhdfcbank)');
      return;
    }

    if (!RegExp(r'^[\w.\-]+@[\w.\-]+$').hasMatch(upi)) {
      setState(() => _profileUpiError = 'Please enter a valid UPI ID (e.g. yourname@okhdfcbank)');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      final user = await auth.completeGoogleOAuthSignIn(
        account: _pendingGoogleAccount!,
        displayName: name,
        defaultUpiVpa: upi,
      );
      await _handlePostSignIn(user);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('FormatException: ', '').replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final email = _googleEmailController.text.trim();
    final name = _googleNameController.text.trim();
    final upi = _googleUpiController.text.trim();

    if (widget.isJoining && upi.isEmpty) {
      setState(() {
        _errorMessage = 'UPI ID is mandatory to join a trip (e.g. yourname@okhdfcbank)';
      });
      return;
    }

    if (widget.isJoining && !RegExp(r'^[\w.\-]+@[\w.\-]+$').hasMatch(upi)) {
      setState(() {
        _errorMessage = 'Please enter a valid UPI ID (e.g. yourname@okhdfcbank)';
      });
      return;
    }

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your Google email address to continue';
      });
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        _errorMessage = 'Please enter a valid Google email address (e.g. name@gmail.com)';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      final user = await auth.signInWithGoogle(
        customName: name.isNotEmpty ? name : null,
        customEmail: email,
        defaultUpiVpa: upi.isNotEmpty ? upi : null,
      );
      await _handlePostSignIn(user);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('FormatException: ', '').replaceFirst('Exception: ', '');
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

    // Step 2: After Google OAuth succeeds, allow editing name and mandate entering UPI ID
    if (_isGoogleProfileStep && _pendingGoogleAccount != null) {
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

              // Header with Google avatar & verified email
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: _pendingGoogleAccount!.photoUrl != null
                        ? NetworkImage(_pendingGoogleAccount!.photoUrl!)
                        : null,
                    child: _pendingGoogleAccount!.photoUrl == null
                        ? Text(
                            _profileNameController.text.isNotEmpty
                                ? _profileNameController.text[0].toUpperCase()
                                : 'G',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Complete Profile',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: Color(0xFF4285F4), size: 18),
                          ],
                        ),
                        Text(
                          _pendingGoogleAccount!.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
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
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Google sign-in verified! Confirm your name and enter your UPI ID to settle debts with trip mates.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Editable Name Field
              TextField(
                key: const Key('google_profile_name_field'),
                controller: _profileNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Your Name *',
                  hintText: 'e.g. Supratik',
                  errorText: _profileNameError,
                  prefixIcon: const Icon(Icons.person_outline),
                  helperText: 'Pre-filled from your Google account. You can edit this.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Mandatory UPI ID Field
              TextField(
                key: const Key('google_profile_upi_field'),
                controller: _profileUpiController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Your UPI ID * (Mandatory)',
                  hintText: 'e.g. name@bank or 9876543210@upi',
                  errorText: _profileUpiError,
                  prefixIcon: const Icon(Icons.account_balance),
                  helperText: 'Mandatory: Enter your own UPI ID for receiving and settling trip payments',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: theme.colorScheme.onErrorContainer, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Complete Profile Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  key: const Key('complete_google_profile_btn'),
                  onPressed: _isLoading ? null : _handleCompleteGoogleProfile,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'Complete Setup & Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isGoogleProfileStep = false;
                            _pendingGoogleAccount = null;
                            _errorMessage = null;
                          });
                        },
                  child: const Text('Use a different account'),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                        widget.reason ?? 'Sign in to link your traveler profile across trips',
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
              // 1-Tap Google OAuth Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  key: const Key('google_oauth_sign_in_btn'),
                  onPressed: _isLoading ? null : _handleGoogleOAuthSignIn,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1F1F1F),
                    elevation: 1,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4285F4),
                              ),
                            ),
                          ),
                        ),
                  label: const Text(
                    'Sign in with Google (1-Tap OAuth)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OR SIGN IN MANUALLY',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('google_email_field'),
                controller: _googleEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Google Email Address *',
                  hintText: 'e.g. yourname@gmail.com',
                  prefixIcon: const Icon(Icons.mail_outline),
                  helperText: 'Enter your Gmail address to connect your profile',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('google_name_field'),
                controller: _googleNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Your Full Name (optional)',
                  hintText: 'e.g. Supratik',
                  prefixIcon: const Icon(Icons.person_outline),
                  helperText: 'Defaults to name from email if left blank',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('google_upi_field'),
                controller: _googleUpiController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: widget.isJoining ? 'Your UPI ID * (Required for joining)' : 'Your UPI ID (optional)',
                  hintText: 'e.g. name@bank or 9876543210@upi',
                  prefixIcon: const Icon(Icons.account_balance),
                  helperText: widget.isJoining
                      ? 'Mandatory to join trip for 1-tap debt settlements'
                      : 'Used for 1-tap UPI debt settlements with friends',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  key: const Key('google_sign_in_btn'),
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login),
                  label: const Text('Continue with Email Above'),
                ),
              ),
            ] else if (_selectedTab == 1) ...[
              // Email / Password Form
              TextField(
                key: const Key('auth_display_name_field'),
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Your Name (optional)',
                  hintText: 'e.g. Supratik',
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
                  hintText: 'e.g. user@example.com',
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
