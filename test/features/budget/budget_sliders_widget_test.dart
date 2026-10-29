import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/features/budget/presentation/screens/budget_sliders_screen.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

void main() {
  testWidgets('BudgetSlidersScreen renders 6 category sliders with stats and 100% total',
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
      totalBudgetPaise: 6000000, // ₹60,000
      days: 4,
      currency: 'INR',
      createdAt: DateTime.now(),
      travelers: const [
        Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
        Traveler(id: 't-2', tripId: 'trip-1', name: 'Diya'),
      ],
      categoryAllocations: const {
        'Stay': 30,
        'Food': 25,
        'Transport': 20,
        'Activities': 15,
        'Shopping': 5,
        'Buffer': 5,
      },
      totalSpentPaise: 0,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: BudgetSlidersScreen(trip: trip),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title and total 100% indicator
    expect(find.text('Budget distribution'), findsOneWidget);
    expect(find.text('Total allocation'), findsOneWidget);
    expect(find.text('100%'), findsWidgets);

    // Verify 6 category titles
    expect(find.text('Stay'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('Activities'), findsOneWidget);
    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('Buffer'), findsOneWidget);

    // Verify slider stats labels
    expect(find.text('Total'), findsWidgets);
    expect(find.text('Per person'), findsWidgets);
    expect(find.text('Per day'), findsWidgets);

    // Verify 6 sliders exist
    expect(find.byType(Slider), findsNWidgets(6));
  });
}
