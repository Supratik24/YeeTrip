import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yeetrip/core/theme_provider.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/features/dashboard/presentation/widgets/daily_spending_chart.dart';
import 'package:yeetrip/features/dashboard/presentation/widgets/trip_share_card_sheet.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/gallery/domain/trip_photo_model.dart';
import 'package:yeetrip/features/gallery/presentation/screens/trip_gallery_screen.dart';
import 'package:yeetrip/features/settings/presentation/screens/settings_screen.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';
import 'package:yeetrip/features/trips/presentation/screens/trip_list_screen.dart';
import 'package:yeetrip/features/trips/presentation/screens/trip_setup_screen.dart';

void main() {
  final start = DateTime(2026, 12, 10);
  final trip = TripWithDetails(
    id: 'trip-p1',
    name: 'Goa Squad',
    destination: 'North Goa',
    totalBudgetPaise: 4000000, // ₹40,000
    days: 4,
    currency: 'INR',
    createdAt: start,
    startDate: start,
    endDate: DateTime(2026, 12, 13),
    travelers: const [
      Traveler(id: 't-1', tripId: 'trip-p1', name: 'Aarav'),
      Traveler(id: 't-2', tripId: 'trip-p1', name: 'Diya'),
    ],
  );

  final expenses = [
    ExpenseWithSplits(
      id: 'e-1',
      tripId: 'trip-p1',
      description: 'Day 1 Lunch',
      amountPaise: 250000,
      category: 'Food',
      paidBy: 't-1',
      createdAt: start,
      receiptImagePath: '/tmp/bill1.jpg',
      splits: const [
        ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-1', sharePaise: 125000),
        ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-2', sharePaise: 125000),
      ],
    ),
    ExpenseWithSplits(
      id: 'e-2',
      tripId: 'trip-p1',
      description: 'Day 3 Yacht',
      amountPaise: 1200000,
      category: 'Activities',
      paidBy: 't-2',
      createdAt: start.add(const Duration(days: 2)),
      splits: const [
        ExpenseSplitModel(expenseId: 'e-2', travelerId: 't-1', sharePaise: 600000),
        ExpenseSplitModel(expenseId: 'e-2', travelerId: 't-2', sharePaise: 600000),
      ],
    ),
  ];

  group('Daily Spending Chart', () {
    test('analyze groups expenses per day and detects Peak Day', () {
      final summary = DailySpendSummary.analyze(trip: trip, expenses: expenses);
      expect(summary.points.length, equals(4));
      expect(summary.points[0].amountPaise, equals(250000));
      expect(summary.points[1].amountPaise, equals(0));
      expect(summary.points[2].amountPaise, equals(1200000));
      expect(summary.peakDayNumber, equals(3));
      expect(summary.peakAmountPaise, equals(1200000));
    });

    testWidgets('DailySpendingChart toggles between bar and line views',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailySpendingChart(trip: trip, expenses: expenses),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Peak: Day 3'), findsOneWidget);
      await tester.tap(find.byKey(const Key('daily_chart_line_btn')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('daily_chart_bar_btn')));
      await tester.pumpAndSettle();
    });
  });

  group('WhatsApp / Telegram Share Card', () {
    testWidgets('TripShareCardSheet switches themes and captures PNG + text summary',
        (tester) async {
      Uint8List? sharedPng;
      String? sharedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripShareCardSheet(
              trip: trip,
              expenses: expenses,
              onShareImageOverride: (bytes, text) async {
                sharedPng = bytes;
                sharedText = text;
              },
              onShareTextOverride: (text) async {
                sharedText = text;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('YEETRIP SUMMARY'), findsOneWidget);
      await tester.tap(find.byKey(const Key('share_card_theme_midnightPro')));
      await tester.pumpAndSettle();

      final imgBtn = find.byKey(const Key('share_summary_card_image_btn'));
      await tester.scrollUntilVisible(
        imgBtn,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(imgBtn);
      await tester.tap(imgBtn);
      await tester.pump();
      await tester.runAsync(() async {
        for (var i = 0; i < 40 && sharedPng == null; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      });
      await tester.pumpAndSettle();

      expect(sharedPng, isNotNull);
      expect(sharedPng!.length, greaterThan(100));
      expect(sharedPng!.sublist(0, 4), equals(const [137, 80, 78, 71]));
      expect(sharedText, contains('Goa Squad'));
    });
  });

  group('Dark Mode Toggle', () {
    test('AppThemeModeNotifier cycles and persists ThemeMode', () async {
      SharedPreferences.setMockInitialValues({'yeetrip_theme_mode': 'dark'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(appThemeModeProvider);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(container.read(appThemeModeProvider), equals(ThemeMode.dark));

      await container.read(appThemeModeProvider.notifier).setThemeMode(ThemeMode.light);
      expect(container.read(appThemeModeProvider), equals(ThemeMode.light));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppThemeModeNotifier.prefsKey), equals('light'));
    });

    testWidgets('TripListScreen AppBar toggle cycles ThemeMode',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripsStreamProvider.overrideWith((_) => Stream.value([trip])),
            tripExpensesProvider('trip-p1')
                .overrideWith((_) => Stream.value(expenses)),
          ],
          child: const MaterialApp(home: TripListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('theme_toggle_btn')));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Theme: Light (tap for Dark)'), findsOneWidget);
    });

    testWidgets('SettingsScreen Appearance toggle renders segmented control',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripExpensesProvider('trip-p1')
                .overrideWith((_) => Stream.value(expenses)),
          ],
          child: MaterialApp(home: SettingsScreen(trip: trip)),
        ),
      );
      await tester.pumpAndSettle();

      final appearanceBtn = find.byKey(const Key('theme_mode_segmented_button'));
      await tester.scrollUntilVisible(
        appearanceBtn,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(appearanceBtn, findsOneWidget);
    });
  });

  group('Trip Photo Gallery & AI Budget Suggester', () {
    testWidgets('TripGalleryScreen renders memories and bill photos with filters',
        (tester) async {
      final mockPhotos = [
        TripPhotoModel(
          id: 'p-1',
          tripId: 'trip-p1',
          imagePath: '/tmp/chapora.jpg',
          caption: 'Chapora Fort Sunset',
          dayNumber: 2,
          uploadedByName: 'Diya',
          createdAt: start.add(const Duration(days: 1)),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripDetailsProvider('trip-p1')
                .overrideWith((_) => Stream.value(trip)),
            tripPhotosProvider('trip-p1')
                .overrideWith((_) => Stream.value(mockPhotos)),
            tripExpensesProvider('trip-p1')
                .overrideWith((_) => Stream.value(expenses)),
          ],
          child: const MaterialApp(
            home: TripGalleryScreen(tripId: 'trip-p1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chapora Fort Sunset'), findsOneWidget);
      expect(find.text('Day 1 Lunch (Food Bill)'), findsOneWidget);

      await tester.tap(find.byKey(const Key('gallery_filter_memories')));
      await tester.pumpAndSettle();
      expect(find.text('Chapora Fort Sunset'), findsOneWidget);
      expect(find.text('Day 1 Lunch (Food Bill)'), findsNothing);

      await tester.tap(find.byKey(const Key('gallery_filter_receipts')));
      await tester.pumpAndSettle();
      expect(find.text('Day 1 Lunch (Food Bill)'), findsOneWidget);
      expect(find.text('Chapora Fort Sunset'), findsNothing);
    });

    testWidgets('TripSetupScreen opens AI Budget Suggester sheet and applies estimate',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: TripSetupScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('trip_destination_field')),
        'Goa',
      );
      await tester.pumpAndSettle();

      final suggestBtn = find.byKey(const Key('ai_budget_suggester_btn'));
      await tester.scrollUntilVisible(
        suggestBtn,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(suggestBtn);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ai_budget_preview_card')), findsOneWidget);
      final applyBtn = find.byKey(const Key('apply_ai_budget_btn'));
      await tester.scrollUntilVisible(
        applyBtn,
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('ai_budget_sheet_listview')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.ensureVisible(applyBtn);
      await tester.tap(applyBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('AI Budget Applied'), findsOneWidget);
    });
  });
}
