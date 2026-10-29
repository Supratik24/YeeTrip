import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/features/expenses/presentation/screens/add_edit_expense_screen.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

void main() {
  testWidgets('AddEditExpenseScreen renders form and validates required fields',
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
        Traveler(id: 't-2', tripId: 'trip-1', name: 'Diya'),
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

    // Verify initial fields are present
    expect(find.text('Add expense'), findsWidgets);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Amount (₹)'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Paid by'), findsOneWidget);
    expect(find.text('Split method'), findsOneWidget);

    // Verify split mode options exist
    expect(find.text('Equal'), findsOneWidget);
    expect(find.text('Exact'), findsOneWidget);
    expect(find.text('%'), findsOneWidget);
    expect(find.text('Shares'), findsOneWidget);

    // Tap "Add expense" button without filling required fields
    final submitBtn = find.widgetWithText(FilledButton, 'Add expense');
    expect(submitBtn, findsOneWidget);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Inline errors should trigger
    expect(find.text('Description is required'), findsOneWidget);
    expect(find.text('Amount is required'), findsOneWidget);
  });

  testWidgets('AddEditExpenseScreen switches split modes dynamically',
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
        Traveler(id: 't-2', tripId: 'trip-1', name: 'Diya'),
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

    // Default mode is Equal: shows checkboxes for Aarav and Diya
    expect(find.byType(CheckboxListTile), findsNWidgets(2));

    // Switch to Exact mode
    await tester.tap(find.text('Exact'));
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(find.text('Aarav'), findsWidgets);
    expect(find.text('Diya'), findsWidgets);

    // Switch to Percentage (%) mode
    await tester.tap(find.text('%'));
    await tester.pumpAndSettle();
    expect(find.text('50.0%'), findsNothing); // controllers initialized

    // Switch to Shares mode
    await tester.tap(find.text('Shares'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.add_circle_outline), findsWidgets);
    expect(find.byIcon(Icons.remove_circle_outline), findsWidgets);
  });
}
