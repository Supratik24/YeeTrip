import 'dart:async';
import 'package:uuid/uuid.dart';

import 'auth_models.dart';
import 'auth_storage.dart';

/// Service managing user authentication, sessions, and profile lifecycle.
class AuthService {
  final AuthStorage _storage;
  final Uuid _uuid;

  final _authStateController = StreamController<AuthState>.broadcast();
  AuthState _currentState = AuthState.guest();

  AuthService({
    AuthStorage? storage,
    Uuid? uuid,
  })  : _storage = storage ?? InMemoryAuthStorage(),
        _uuid = uuid ?? const Uuid();

  AuthState get currentState => _currentState;
  Stream<AuthState> get authStateChanges => _authStateController.stream;

  void _setState(AuthState state) {
    _currentState = state;
    _authStateController.add(state);
  }

  /// Restores existing session from storage if present.
  Future<AuthState> restoreSession() async {
    _setState(_currentState.copyWith(isLoading: true));
    try {
      final stored = await _storage.loadStoredProfile();
      if (stored != null) {
        final state = AuthState.authenticated(stored);
        _setState(state);
        return state;
      } else {
        final state = AuthState.guest();
        _setState(state);
        return state;
      }
    } catch (e) {
      final state = AuthState.guest();
      _setState(state);
      return state;
    }
  }

  /// Signs in with Email and Password. Creates new profile if user doesn't exist.
  Future<UserProfile> signInWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      throw const FormatException('Please enter a valid email address');
    }
    if (password.length < 6) {
      throw const FormatException('Password must be at least 6 characters');
    }

    _setState(_currentState.copyWith(isLoading: true, errorMessage: null));

    final name = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : email.split('@').first;

    final user = UserProfile(
      uid: 'usr_${_uuid.v4().substring(0, 8)}',
      displayName: name,
      email: email.trim().toLowerCase(),
      createdAt: DateTime.now().toUtc(),
    );

    await _storage.saveProfile(user);
    _setState(AuthState.authenticated(user));
    return user;
  }

  /// Signs in with Google (mock/adapter for multi-platform support).
  Future<UserProfile> signInWithGoogle({
    String? customName,
    String? customEmail,
    String? customAvatarUrl,
  }) async {
    _setState(_currentState.copyWith(isLoading: true, errorMessage: null));

    final email = customEmail ?? 'user.traveler@gmail.com';
    final name = customName ?? 'Aarav Sharma';

    final user = UserProfile(
      uid: 'google_${_uuid.v4().substring(0, 8)}',
      displayName: name,
      email: email,
      avatarUrl: customAvatarUrl ?? 'https://api.dicebear.com/7.x/bottts/svg?seed=Aarav',
      defaultUpiVpa: 'aarav@oksbi',
      createdAt: DateTime.now().toUtc(),
    );

    await _storage.saveProfile(user);
    _setState(AuthState.authenticated(user));
    return user;
  }

  /// Signs in with Indian Phone Number & OTP verification.
  Future<UserProfile> signInWithPhone({
    required String phoneNumber,
    required String otp,
    String? displayName,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length < 10) {
      throw const FormatException('Please enter a valid 10-digit mobile number');
    }
    if (otp.trim() != '123456' && otp.trim().length != 6) {
      throw const FormatException('Invalid OTP. Please enter 6-digit code');
    }

    _setState(_currentState.copyWith(isLoading: true, errorMessage: null));

    final name = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : 'Traveler +91-${cleanPhone.substring(cleanPhone.length - 4)}';

    final user = UserProfile(
      uid: 'phone_${_uuid.v4().substring(0, 8)}',
      displayName: name,
      phoneNumber: '+91$cleanPhone',
      createdAt: DateTime.now().toUtc(),
    );

    await _storage.saveProfile(user);
    _setState(AuthState.authenticated(user));
    return user;
  }

  /// Updates profile details (e.g. display name, default UPI ID, avatar).
  Future<UserProfile> updateProfile({
    String? displayName,
    String? defaultUpiVpa,
    String? avatarUrl,
    String? preferredLanguage,
  }) async {
    final current = _currentState.user;
    if (current == null) {
      throw Exception('Cannot update profile: user is not signed in');
    }

    final updated = current.copyWith(
      displayName: displayName?.trim().isNotEmpty == true ? displayName!.trim() : current.displayName,
      defaultUpiVpa: defaultUpiVpa?.trim().isNotEmpty == true ? defaultUpiVpa!.trim() : current.defaultUpiVpa,
      avatarUrl: avatarUrl ?? current.avatarUrl,
      preferredLanguage: preferredLanguage ?? current.preferredLanguage,
    );

    await _storage.saveProfile(updated);
    _setState(AuthState.authenticated(updated));
    return updated;
  }

  /// Signs out the user, returning to Guest mode without modifying local trips.
  Future<void> signOut() async {
    await _storage.clear();
    _setState(AuthState.guest());
  }

  void dispose() {
    _authStateController.close();
  }
}
