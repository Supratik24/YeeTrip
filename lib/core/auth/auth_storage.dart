import 'dart:convert';
import 'auth_models.dart';

/// Secure token & profile persistence abstraction.
abstract class AuthStorage {
  Future<UserProfile?> loadStoredProfile();
  Future<void> saveProfile(UserProfile profile);
  Future<void> clear();
}

/// In-memory storage implementation for tests and offline session management.
class InMemoryAuthStorage implements AuthStorage {
  String? _serializedProfile;

  @override
  Future<UserProfile?> loadStoredProfile() async {
    if (_serializedProfile == null) return null;
    try {
      final map = jsonDecode(_serializedProfile!) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _serializedProfile = jsonEncode(profile.toJson());
  }

  @override
  Future<void> clear() async {
    _serializedProfile = null;
  }
}
