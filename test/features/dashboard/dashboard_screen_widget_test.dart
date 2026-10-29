import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

void main() {
  testWidgets('DashboardScreen renders metric cards, cooked meter, and planned vs actual bars',
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
      totalSpentPaise: 1600000, // ₹16,000
    );

    final expenses = <ExpenseWithSplits>[
      ExpenseWithSplits(
        id: 'e-1',
        tripId: 'trip-1',
        description: 'Resort Stay',
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

    // Verify Metric cards
    expect(find.text('Total budget'), findsOneWidget);
    expect(find.text('Per person'), findsOneWidget);
    expect(find.text('Per day (group)'), findsOneWidget);
    expect(find.text('Remaining'), findsWidgets);

    // Verify Cooked Meter (₹16,000 / ₹60,000 = 26.7% -> Chill)
    expect(find.text('Cooked meter'), findsOneWidget);
    expect(find.text('Chill'), findsOneWidget);

    // Verify Planned vs Actual Bars
    expect(find.text('Planned vs actual spending'), findsOneWidget);
    expect(find.text('Stay'), findsWidgets);
    expect(find.text('Food'), findsWidgets);
  });
}
