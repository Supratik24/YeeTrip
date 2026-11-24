import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_models.dart';

/// Secure token & profile persistence abstraction.
abstract class AuthStorage {
  Future<UserProfile?> loadStoredProfile();
  Future<void> saveProfile(UserProfile profile);
  Future<void> clear();
}

/// SharedPreferences-backed persistent storage across app restarts.
class SharedPrefsAuthStorage implements AuthStorage {
  static const _profileKey = 'yeetrip_user_profile';

  @override
  Future<UserProfile?> loadStoredProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized = prefs.getString(_profileKey);
      if (serialized == null || serialized.isEmpty) return null;
      final map = jsonDecode(serialized) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized = jsonEncode(profile.toJson());
      await prefs.setString(_profileKey, serialized);
    } catch (_) {}
  }

  @override
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
    } catch (_) {}
  }
}

/// In-memory storage implementation for tests.
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
