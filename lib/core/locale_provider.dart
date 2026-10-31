import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Available language choices in YeeTrip.
enum AppLanguage {
  system,
  english,
  hindi,
}

/// Notifier managing the active app locale.
class AppLocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  /// Sets the active locale directly.
  void setLocale(Locale? locale) {
    state = locale;
  }

  /// Sets the language using the [AppLanguage] enum.
  void setLanguage(AppLanguage language) {
    switch (language) {
      case AppLanguage.system:
        state = null;
        break;
      case AppLanguage.english:
        state = const Locale('en');
        break;
      case AppLanguage.hindi:
        state = const Locale('hi');
        break;
    }
  }

  /// Returns the current [AppLanguage].
  AppLanguage get currentLanguage {
    if (state == null) return AppLanguage.system;
    if (state!.languageCode == 'hi') return AppLanguage.hindi;
    return AppLanguage.english;
  }
}

/// Global provider for the application locale.
final appLocaleProvider =
    NotifierProvider<AppLocaleNotifier, Locale?>(() {
  return AppLocaleNotifier();
});
