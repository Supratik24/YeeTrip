import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/settle/presentation/screens/settle_screen.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

void main() {
  testWidgets('SettleScreen displays balances and settlement plan with mark settled button',
      (WidgetTester tester) async {
    final trip = TripWithDetails(
      id: 'trip-1',
      name: 'Manali Trip',
      totalBudgetPaise: 1000000,
      days: 3,
      currency: 'INR',
      createdAt: DateTime.now(),
      travelers: const [
        Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
        Traveler(id: 't-2', tripId: 'trip-1', name: 'Diya'),
      ],
      categoryAllocations: const {},
      totalSpentPaise: 10000,
    );

    final expenses = <ExpenseWithSplits>[
      ExpenseWithSplits(
        id: 'e-1',
        tripId: 'trip-1',
        description: 'Lunch',
        amountPaise: 10000,
        category: 'Food',
        paidBy: 't-1',
        source: 'manual',
        confirmed: true,
        createdAt: DateTime.now(),
        splits: const [
          ExpenseSplitModel(
            expenseId: 'e-1',
            travelerId: 't-1',
            sharePaise: 5000,
          ),
          ExpenseSplitModel(
            expenseId: 'e-1',
            travelerId: 't-2',
            sharePaise: 5000,
          ),
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
          home: SettleScreen(trip: trip),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify balances section
    expect(find.text('Individual balances'), findsOneWidget);
    expect(find.text('Aarav'), findsOneWidget);
    expect(find.text('Diya'), findsOneWidget);

    // Verify settlement plan section
    expect(find.text('Settlement plan'), findsOneWidget);
    expect(find.textContaining('Diya'), findsWidgets);
    expect(find.textContaining('pays'), findsOneWidget);
    expect(find.textContaining('Aarav'), findsWidgets);

    // Verify mark settled button exists
    final settleBtn = find.byKey(const Key('mark_settled_t-2_t-1'));
    expect(settleBtn, findsOneWidget);

    // Tap mark settled button
    await tester.tap(settleBtn);
    await tester.pumpAndSettle();

    // Verify confirmation dialog
    expect(find.text('Mark as settled?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
  });
}
