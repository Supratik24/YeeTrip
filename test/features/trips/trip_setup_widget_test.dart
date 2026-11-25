import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/auth/auth_providers.dart';
import 'package:yeetrip/core/auth/auth_service.dart';
import 'package:yeetrip/core/auth/auth_storage.dart';
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

    // Verify initial fields and guest sign-in banner are present
    expect(find.text('Plan new trip'), findsOneWidget);
    expect(find.textContaining('Sign-in required'), findsOneWidget);
    expect(find.byKey(const Key('trip_name_field')), findsOneWidget);
    expect(find.byKey(const Key('trip_cover_picker_card')), findsOneWidget);
    expect(find.byKey(const Key('trip_date_range_btn')), findsOneWidget);
    expect(find.byKey(const Key('total_budget_field')), findsOneWidget);
    expect(find.byKey(const Key('days_field')), findsOneWidget);
    expect(find.byKey(const Key('create_trip_button')), findsOneWidget);

    // Tap "Create trip" button without entering required name and budget
    final createBtn = find.byKey(const Key('create_trip_button'));
    await tester.ensureVisible(createBtn);
    await tester.tap(createBtn);
    await tester.pumpAndSettle();

    // Verify inline validation error messages
    await tester.ensureVisible(find.byKey(const Key('trip_name_field')));
    expect(find.text('Trip name is required'), findsOneWidget);
    expect(find.text('Budget is required'), findsOneWidget);

    // Enter name
    await tester.enterText(find.byKey(const Key('trip_name_field')), 'Goa Trip');
    // Enter invalid budget
    await tester.enterText(find.byKey(const Key('total_budget_field')), '-500');
    await tester.ensureVisible(createBtn);
    await tester.tap(createBtn);
    await tester.pumpAndSettle();

    // Verify name error cleared, budget error updated
    expect(find.text('Trip name is required'), findsNothing);
    expect(find.text('Enter a valid amount'), findsOneWidget);

    // Add another traveler
    final addPersonButton = find.widgetWithText(TextButton, 'Add person');
    await tester.ensureVisible(addPersonButton);
    expect(addPersonButton, findsOneWidget);
    await tester.tap(addPersonButton);
    await tester.pumpAndSettle();

    // Should now have 2 traveler fields
    expect(find.byKey(const Key('traveler_field_0')), findsOneWidget);
    expect(find.byKey(const Key('traveler_field_1')), findsOneWidget);
  });

  testWidgets('TripSetupScreen pre-populates traveler name when user is authenticated', (WidgetTester tester) async {
    final storage = InMemoryAuthStorage();
    final authService = AuthService(storage: storage);
    await authService.signInWithGoogle(
      customEmail: 'supratik@gmail.com',
      customName: 'Supratik',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(authService),
        ],
        child: const MaterialApp(
          home: TripSetupScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify guest banner is not displayed
    expect(find.textContaining('Sign-in required'), findsNothing);

    // Traveler 0 should be pre-filled with the authenticated user's name
    final travelerField = tester.widget<TextFormField>(find.byKey(const Key('traveler_field_0')));
    expect(travelerField.controller?.text, equals('Supratik'));
  });
}
