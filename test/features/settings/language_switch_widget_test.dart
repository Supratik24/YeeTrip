import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/locale_provider.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/settings/presentation/screens/settings_screen.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';
import 'package:yeetrip/features/trips/presentation/screens/trip_detail_scaffold.dart';
import 'package:yeetrip/l10n/app_localizations.dart';

void main() {
  final testTrip = TripWithDetails(
    id: 'trip-1',
    name: 'Manali Chill 🏔️',
    totalBudgetPaise: 4500000,
    days: 5,
    currency: 'INR',
    createdAt: DateTime.now(),
    travelers: const [
      Traveler(id: 't-1', tripId: 'trip-1', name: 'Rohan'),
      Traveler(id: 't-2', tripId: 'trip-1', name: 'Simran'),
    ],
    categoryAllocations: const {},
    totalSpentPaise: 120000,
  );

  Widget buildAppWithScope({Widget? home, ProviderContainer? container}) {
    return Consumer(
      builder: (context, ref, _) {
        final locale = ref.watch(appLocaleProvider);
        return MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        );
      },
    );
  }

  group('Language Switcher Tests', () {
    testWidgets('toggles language from English to Hindi in SettingsScreen',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripExpensesProvider('trip-1')
                .overrideWith((ref) => Stream.value(<ExpenseWithSplits>[])),
          ],
          child: buildAppWithScope(
            home: SettingsScreen(trip: testTrip),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // By default in test environment, English is selected
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('हिन्दी (Hindi)'), findsOneWidget);
      expect(find.text('Edit trip & travelers'), findsOneWidget);

      // Tap Hindi option in SegmentedButton
      await tester.tap(find.text('हिन्दी (Hindi)'));
      await tester.pumpAndSettle();

      // Verify strings switch to Hindi
      expect(find.text('सेटिंग्स'), findsOneWidget);
      expect(find.text('भाषा (Language)'), findsOneWidget);
      expect(find.text('यात्रा और यात्री संपादित करें'), findsOneWidget);
      expect(find.text('डेटा निर्यात'), findsOneWidget);

      // Tap English option back
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Verify strings switch back to English
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Edit trip & travelers'), findsOneWidget);
    });

    testWidgets('TripDetailScaffold translates bottom navigation tabs dynamically',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripDetailsProvider('trip-1')
                .overrideWith((ref) => Stream.value(testTrip)),
            tripExpensesProvider('trip-1')
                .overrideWith((ref) => Stream.value(<ExpenseWithSplits>[])),
          ],
          child: buildAppWithScope(
            home: const TripDetailScaffold(tripId: 'trip-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial English tabs
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Budget'), findsOneWidget);
      expect(find.text('Settle'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Switch to Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Switch language to Hindi
      await tester.tap(find.text('हिन्दी (Hindi)'));
      await tester.pumpAndSettle();

      // Tab labels should now be in Hindi
      expect(find.text('डैशबोर्ड'), findsOneWidget);
      expect(find.text('खर्चे'), findsOneWidget);
      expect(find.text('बजट'), findsOneWidget);
      expect(find.text('हिसाब'), findsOneWidget);
      expect(find.text('सेटिंग्स'), findsWidgets); // App bar and Tab label
    });
  });
}
