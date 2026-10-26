import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/features/trips/presentation/screens/trip_setup_screen.dart';

void main() {
  testWidgets('TripSetupScreen validates required fields and shows inline errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TripSetupScreen(),
        ),
      ),
    );

    // Verify initial fields are present
    expect(find.text('Plan new trip'), findsOneWidget);
    expect(find.byKey(const Key('trip_name_field')), findsOneWidget);
    expect(find.byKey(const Key('total_budget_field')), findsOneWidget);
    expect(find.byKey(const Key('days_field')), findsOneWidget);
    expect(find.byKey(const Key('create_trip_button')), findsOneWidget);

    // Tap "Create trip" button without entering required name and budget
    await tester.tap(find.byKey(const Key('create_trip_button')));
    await tester.pumpAndSettle();

    // Verify inline validation error messages
    expect(find.text('Trip name is required'), findsOneWidget);
    expect(find.text('Budget is required'), findsOneWidget);

    // Enter name
    await tester.enterText(find.byKey(const Key('trip_name_field')), 'Goa Trip');
    // Enter invalid budget
    await tester.enterText(find.byKey(const Key('total_budget_field')), '-500');
    await tester.tap(find.byKey(const Key('create_trip_button')));
    await tester.pumpAndSettle();

    // Verify name error cleared, budget error updated
    expect(find.text('Trip name is required'), findsNothing);
    expect(find.text('Enter a valid amount'), findsOneWidget);

    // Add another traveler
    final addPersonButton = find.widgetWithText(TextButton, 'Add person');
    expect(addPersonButton, findsOneWidget);
    await tester.tap(addPersonButton);
    await tester.pumpAndSettle();

    // Should now have 2 traveler fields
    expect(find.byKey(const Key('traveler_field_0')), findsOneWidget);
    expect(find.byKey(const Key('traveler_field_1')), findsOneWidget);
  });
}
