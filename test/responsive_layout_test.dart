import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/expenses/presentation/screens/add_edit_expense_screen.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';
import 'package:yeetrip/features/trips/presentation/screens/trip_detail_scaffold.dart';
import 'package:yeetrip/features/trips/presentation/screens/trip_list_screen.dart';
import 'package:yeetrip/features/trips/presentation/screens/trip_setup_screen.dart';

void main() {
  final trip = TripWithDetails(
    id: 'trip-1',
    name: 'Goa Weekend 🌴',
    totalBudgetPaise: 6000000,
    days: 4,
    currency: 'INR',
    createdAt: DateTime.now(),
    travelers: const [
      Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
      Traveler(id: 't-2', tripId: 'trip-1', name: 'Diya'),
      Traveler(id: 't-3', tripId: 'trip-1', name: 'Kabir'),
      Traveler(id: 't-4', tripId: 'trip-1', name: 'Rohan'),
    ],
    categoryAllocations: const {
      'Stay': 30,
      'Food': 25,
      'Transport': 20,
      'Activities': 15,
      'Shopping': 5,
      'Buffer': 5,
    },
    totalSpentPaise: 3860000,
  );

  final expenses = [
    ExpenseWithSplits(
      id: 'e-1',
      tripId: 'trip-1',
      description: 'Beach Villa Stay',
      amountPaise: 1600000,
      category: 'Stay',
      paidBy: 't-1',
      source: 'manual',
      confirmed: true,
      createdAt: DateTime.now(),
      splits: const [
        ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-1', sharePaise: 400000),
        ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-2', sharePaise: 400000),
        ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-3', sharePaise: 400000),
        ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-4', sharePaise: 400000),
      ],
    ),
    ExpenseWithSplits(
      id: 'e-2',
      tripId: 'trip-1',
      description: 'Settlement: Diya → Aarav',
      amountPaise: 145000,
      category: 'Buffer',
      paidBy: 't-2',
      source: 'settlement',
      confirmed: true,
      createdAt: DateTime.now(),
      splits: const [
        ExpenseSplitModel(expenseId: 'e-2', travelerId: 't-1', sharePaise: 145000),
      ],
    ),
  ];

  final sizes = [
    const Size(360, 640),
    const Size(375, 667),
    const Size(390, 844),
    const Size(412, 915),
    const Size(800, 600),
    const Size(1280, 800),
  ];

  for (final size in sizes) {
    group('Screen layout on size $size', () {
      testWidgets('TripListScreen with trips', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tripsStreamProvider.overrideWith((ref) => Stream.value([trip, trip])),
            ],
            child: const MaterialApp(home: TripListScreen()),
          ),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('TripDetailScaffold and all 5 tabs', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tripDetailsProvider('trip-1').overrideWith((ref) => Stream.value(trip)),
              tripExpensesProvider('trip-1').overrideWith((ref) => Stream.value(expenses)),
            ],
            child: const MaterialApp(home: TripDetailScaffold(tripId: 'trip-1')),
          ),
        );
        await tester.pumpAndSettle();

        // Check tab switching
        for (final label in ['Expenses', 'Budget', 'Settle', 'Settings', 'Dashboard']) {
          final dest = find.text(label);
          expect(dest, findsOneWidget);
          await tester.tap(dest);
          await tester.pumpAndSettle();
        }
      });

      testWidgets('TripSetupScreen', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: TripSetupScreen())),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('AddEditExpenseScreen', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tripDetailsProvider('trip-1').overrideWith((ref) => Stream.value(trip)),
              tripExpensesProvider('trip-1').overrideWith((ref) => Stream.value(expenses)),
            ],
            child: const MaterialApp(home: AddEditExpenseScreen(tripId: 'trip-1')),
          ),
        );
        await tester.pumpAndSettle();
      });
    });
  }
}
