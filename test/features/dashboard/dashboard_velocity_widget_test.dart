import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/expenses/presentation/screens/add_edit_expense_screen.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

void main() {
  group('SpendingVelocityCard & Smart Categorizer UI Tests', () {
    testWidgets('DashboardScreen renders SpendingVelocityCard with burn metrics and safe status',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final trip = TripWithDetails(
        id: 'trip-1',
        name: 'Goa Weekend 🌴',
        totalBudgetPaise: 6000000, // ₹60,000
        days: 4,
        currency: 'INR',
        createdAt: DateTime.now(),
        travelers: const [
          Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
        ],
        categoryAllocations: const {
          'Stay': 30,
          'Food': 25,
          'Transport': 20,
          'Activities': 15,
          'Shopping': 5,
          'Buffer': 5,
        },
        totalSpentPaise: 1000000, // ₹10,000
      );

      final expenses = <ExpenseWithSplits>[
        ExpenseWithSplits(
          id: 'e-1',
          tripId: 'trip-1',
          description: 'Resort booking',
          amountPaise: 1000000,
          category: 'Stay',
          paidBy: 't-1',
          source: 'manual',
          confirmed: true,
          createdAt: DateTime.now(),
          splits: const [
            ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-1', sharePaise: 1000000),
          ],
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripExpensesProvider('trip-1').overrideWith(
              (ref) => Stream.value(expenses),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DashboardScreen(trip: trip),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Spending Velocity header
      expect(find.text('Spending Velocity'), findsOneWidget);
      expect(find.text('Daily Burn Rate'), findsOneWidget);
      expect(find.text('Projected Total'), findsOneWidget);

      // Verify Safe Pace badge
      expect(find.text('Safe Pace'), findsOneWidget);
      expect(find.textContaining('Healthy pace!'), findsOneWidget);
    });

    testWidgets('DashboardScreen highlights category depletion warning when burn rate exceeds plan',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final trip = TripWithDetails(
        id: 'trip-1',
        name: 'Goa Weekend 🌴',
        totalBudgetPaise: 4000000, // ₹40,000
        days: 5,
        currency: 'INR',
        // created 2 days ago
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        travelers: const [
          Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
        ],
        categoryAllocations: const {
          'Food': 25, // ₹10,000 allocated
          'Stay': 75,
        },
        totalSpentPaise: 800000, // ₹8,000 spent on Food in 2 days
      );

      final expenses = <ExpenseWithSplits>[
        ExpenseWithSplits(
          id: 'e-1',
          tripId: 'trip-1',
          description: 'Dining out and seafood',
          amountPaise: 800000,
          category: 'Food',
          paidBy: 't-1',
          source: 'manual',
          confirmed: true,
          createdAt: DateTime.now(),
          splits: const [
            ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-1', sharePaise: 800000),
          ],
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripExpensesProvider('trip-1').overrideWith(
              (ref) => Stream.value(expenses),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DashboardScreen(trip: trip),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Category Depletion banner is visible
      expect(find.textContaining('Food: At'), findsOneWidget);
      expect(find.textContaining('budget will exhaust in'), findsOneWidget);
    });

    testWidgets('AddEditExpenseScreen displays smart category suggestion chip as user types',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final trip = TripWithDetails(
        id: 'trip-1',
        name: 'Goa Trip',
        totalBudgetPaise: 5000000,
        days: 3,
        currency: 'INR',
        createdAt: DateTime.now(),
        travelers: const [
          Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
        ],
        categoryAllocations: const {},
        totalSpentPaise: 0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripDetailsProvider('trip-1').overrideWith(
              (ref) => Stream.value(trip),
            ),
          ],
          child: const MaterialApp(
            home: AddEditExpenseScreen(tripId: 'trip-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Type a description with strong Food keywords
      final descField = find.widgetWithText(TextFormField, 'Description');
      expect(descField, findsOneWidget);
      await tester.enterText(descField, 'Hyderabadi Chicken Biryani for dinner');
      await tester.pumpAndSettle();

      // Verify Smart Suggestion chip appeared
      final chipFinder = find.byKey(const Key('smart_category_suggestion_chip'));
      expect(chipFinder, findsOneWidget);
      expect(find.textContaining('Suggested: Food'), findsOneWidget);

      // Verify category dropdown was auto-updated to Food
      expect(find.text('Food'), findsWidgets);

      // Tap suggestion chip
      await tester.tap(chipFinder);
      await tester.pumpAndSettle();

      // Clear text and type Transport keywords
      await tester.enterText(descField, 'Uber ride to Goa Airport');
      await tester.pumpAndSettle();

      // Verify suggestion changed to Transport
      expect(find.textContaining('Suggested: Transport'), findsOneWidget);
    });
  });
}
