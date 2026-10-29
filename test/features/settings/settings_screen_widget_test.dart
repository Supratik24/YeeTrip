import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/settings/presentation/screens/settings_screen.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

void main() {
  testWidgets('SettingsScreen renders summary, export button, and about sections',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final trip = TripWithDetails(
      id: 'trip-1',
      name: 'Goa Trip 🌴',
      totalBudgetPaise: 6000000,
      days: 4,
      currency: 'INR',
      createdAt: DateTime.now(),
      travelers: const [
        Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
        Traveler(id: 't-2', tripId: 'trip-1', name: 'Diya'),
      ],
      categoryAllocations: const {},
      totalSpentPaise: 2000000,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripExpensesProvider('trip-1').overrideWith(
            (ref) => Stream.value(<ExpenseWithSplits>[]),
          ),
        ],
        child: MaterialApp(
          home: SettingsScreen(trip: trip),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Sections
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Goa Trip 🌴'), findsOneWidget);
    expect(find.text('Data export'), findsOneWidget);
    expect(find.text('Export & share CSV'), findsOneWidget);
    expect(find.text('About YeeTrip'), findsOneWidget);
    expect(find.text('100% Offline & Private'), findsOneWidget);
  });
}
