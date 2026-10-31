import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/locale_provider.dart';

void main() {
  group('AppLocaleNotifier Tests', () {
    test('initial state defaults to null (system default)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(appLocaleProvider), isNull);
      expect(container.read(appLocaleProvider.notifier).currentLanguage,
          equals(AppLanguage.system));
    });

    test('can set language to Hindi and back to English', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLocaleProvider.notifier);

      notifier.setLanguage(AppLanguage.hindi);
      expect(container.read(appLocaleProvider), equals(const Locale('hi')));
      expect(notifier.currentLanguage, equals(AppLanguage.hindi));

      notifier.setLanguage(AppLanguage.english);
      expect(container.read(appLocaleProvider), equals(const Locale('en')));
      expect(notifier.currentLanguage, equals(AppLanguage.english));

      notifier.setLanguage(AppLanguage.system);
      expect(container.read(appLocaleProvider), isNull);
      expect(notifier.currentLanguage, equals(AppLanguage.system));
    });

    test('can set locale directly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLocaleProvider.notifier);
      notifier.setLocale(const Locale('hi'));
      expect(container.read(appLocaleProvider)?.languageCode, equals('hi'));
      expect(notifier.currentLanguage, equals(AppLanguage.hindi));
    });
  });
}
