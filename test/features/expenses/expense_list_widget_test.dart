import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

void main() {
  final trip = TripWithDetails(
    id: 'trip-1',
    name: 'Goa Weekend 🌴',
    totalBudgetPaise: 5000000,
    days: 4,
    currency: 'INR',
    createdAt: DateTime.now(),
    travelers: const [
      Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
      Traveler(id: 't-2', tripId: 'trip-1', name: 'Diya'),
    ],
    categoryAllocations: const {},
    totalSpentPaise: 400000,
  );

  final now = DateTime(2026, 5, 10, 14, 0);

  final expenses = [
    ExpenseWithSplits(
      id: 'e-1',
      tripId: 'trip-1',
      description: 'Beach Shack Lunch',
      amountPaise: 120000, // ₹1,200
      category: 'Food',
      paidBy: 't-1',
      createdAt: now.subtract(const Duration(hours: 2)),
      splits: const [
        ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-1', sharePaise: 60000),
        ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-2', sharePaise: 60000),
      ],
    ),
    ExpenseWithSplits(
      id: 'e-2',
      tripId: 'trip-1',
      description: 'Scuba Diving Adventure',
      amountPaise: 280000, // ₹2,800
      category: 'Activities',
      paidBy: 't-2',
      createdAt: now.subtract(const Duration(hours: 1)),
      splits: const [
        ExpenseSplitModel(expenseId: 'e-2', travelerId: 't-1', sharePaise: 140000),
        ExpenseSplitModel(expenseId: 'e-2', travelerId: 't-2', sharePaise: 140000),
      ],
    ),
  ];

  Widget buildScreen({List<ExpenseWithSplits>? expenseList}) {
    return ProviderScope(
      overrides: [
        tripExpensesProvider('trip-1').overrideWith(
          (ref) => Stream.value(expenseList ?? expenses),
        ),
      ],
      child: MaterialApp(
        home: ExpenseListScreen(trip: trip),
      ),
    );
  }

  group('ExpenseListScreen Search, Filter & Sort Widget Tests', () {
    testWidgets('renders expense list, search icon, and sort icon', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Expenses'), findsOneWidget);
      expect(find.byKey(const Key('open_search_btn')), findsOneWidget);
      expect(find.byKey(const Key('sort_expenses_menu_btn')), findsOneWidget);
      expect(find.text('Beach Shack Lunch'), findsOneWidget);
      expect(find.text('Scuba Diving Adventure'), findsOneWidget);
    });

    testWidgets('searches expenses by typing query in search field', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Open search bar
      await tester.tap(find.byKey(const Key('open_search_btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expense_search_field')), findsOneWidget);

      // Search for "Scuba"
      await tester.enterText(find.byKey(const Key('expense_search_field')), 'Scuba');
      await tester.pumpAndSettle();

      expect(find.text('Scuba Diving Adventure'), findsOneWidget);
      expect(find.text('Beach Shack Lunch'), findsNothing);

      // Clear search
      await tester.tap(find.byKey(const Key('clear_search_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Beach Shack Lunch'), findsOneWidget);
      expect(find.text('Scuba Diving Adventure'), findsOneWidget);
    });

    testWidgets('sorts expenses by amount highest first', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Open sort menu
      await tester.tap(find.byKey(const Key('sort_expenses_menu_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Amount: Highest first'), findsOneWidget);
      await tester.tap(find.text('Amount: Highest first'));
      await tester.pumpAndSettle();

      // Sort chip should be visible
      expect(find.text('Amount: Highest first'), findsOneWidget);

      // Scuba (₹2,800) should appear before Lunch (₹1,200)
      final scubaOffset = tester.getTopLeft(find.text('Scuba Diving Adventure')).dy;
      final lunchOffset = tester.getTopLeft(find.text('Beach Shack Lunch')).dy;
      expect(scubaOffset, lessThan(lunchOffset));
    });

    testWidgets('shows empty state when search finds no matches and allows reset', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_search_btn')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('expense_search_field')), 'NonExistentWord');
      await tester.pumpAndSettle();

      expect(find.text('No matching expenses found'), findsOneWidget);
      expect(find.text('Reset search & filters'), findsOneWidget);

      await tester.tap(find.text('Reset search & filters'));
      await tester.pumpAndSettle();

      expect(find.text('Beach Shack Lunch'), findsOneWidget);
      expect(find.text('Scuba Diving Adventure'), findsOneWidget);
    });
  });
}
