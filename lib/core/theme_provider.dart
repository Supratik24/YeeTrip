import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier managing user-selected [ThemeMode] with SharedPreferences persistence.
class AppThemeModeNotifier extends Notifier<ThemeMode> {
  static const String prefsKey = 'yeetrip_theme_mode';
  bool _loaded = false;

  @override
  ThemeMode build() {
    if (!_loaded) {
      _loaded = true;
      _loadAsync();
    }
    return ThemeMode.system;
  }

  Future<void> _loadAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(prefsKey);
      if (!ref.mounted) return;
      final loaded = switch (raw) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => null,
      };
      if (loaded != null) {
        state = loaded;
      }
    } catch (_) {
      // Safe fallback in unit/widget tests without SharedPreferences channel
    }
  }

  /// Sets and persists the active [ThemeMode].
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      await prefs.setString(prefsKey, encoded);
    } catch (_) {}
  }

  /// Cycles through System -> Light -> Dark -> System.
  Future<void> cycleThemeMode() {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    return setThemeMode(next);
  }
}

/// Global provider for the application's [ThemeMode].
final appThemeModeProvider = NotifierProvider<AppThemeModeNotifier, ThemeMode>(
  AppThemeModeNotifier.new,
);
