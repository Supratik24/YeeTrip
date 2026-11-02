import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import 'auth_models.dart';
import 'auth_service.dart';
import 'auth_storage.dart';
import 'profile_migration_service.dart';

/// Provider for auth persistence. Can be overridden in tests.
final authStorageProvider = Provider<AuthStorage>((ref) {
  return InMemoryAuthStorage();
});

/// Provider for user authentication service.
final authServiceProvider = Provider<AuthService>((ref) {
  final storage = ref.watch(authStorageProvider);
  final service = AuthService(storage: storage);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Reactive stream of authentication state (Guest vs Authenticated).
final authStateProvider = StreamProvider<AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.authStateChanges;
});

/// Current authenticated user profile (or null if guest).
final currentUserProvider = Provider<UserProfile?>((ref) {
  final state = ref.watch(authStateProvider).value;
  return state?.user ?? ref.watch(authServiceProvider).currentState.user;
});

/// Provider for local trip traveler profile linking.
final profileMigrationServiceProvider = Provider<ProfileMigrationService>((ref) {
  final db = ref.watch(databaseProvider);
  return ProfileMigrationService(db);
});
