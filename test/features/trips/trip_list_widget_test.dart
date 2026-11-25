import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';
import 'package:yeetrip/features/trips/presentation/screens/trip_list_screen.dart';

void main() {
  testWidgets('TripListScreen renders empty state with plan and explore demo buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripsStreamProvider.overrideWith(
            (ref) => Stream.value(<TripWithDetails>[]),
          ),
        ],
        child: const MaterialApp(
          home: TripListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('YeeTrip'), findsOneWidget);
    expect(find.text('No trips planned yet'), findsOneWidget);
    expect(find.byKey(const Key('plan_first_trip_btn')), findsOneWidget);
    expect(find.byKey(const Key('seed_demo_trip_btn')), findsOneWidget);
    expect(find.text('Explore with demo trip'), findsOneWidget);
  });

  testWidgets('TripListScreen shows destination chip, date span, and Completed status',
      (WidgetTester tester) async {
    final trip = TripWithDetails(
      id: 'trip-2',
      name: 'Manali Winter',
      totalBudgetPaise: 4000000,
      days: 5,
      createdAt: DateTime(2026, 12, 10),
      destination: 'Manali',
      status: 'completed',
      startDate: DateTime(2026, 12, 12),
      endDate: DateTime(2026, 12, 16),
      travelers: const [
        Traveler(id: 't-1', tripId: 'trip-2', name: 'Aarav'),
        Traveler(id: 't-2', tripId: 'trip-2', name: 'Diya'),
      ],
      totalSpentPaise: 2000000,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripsStreamProvider.overrideWith(
            (ref) => Stream.value([trip]),
          ),
        ],
        child: const MaterialApp(
          home: TripListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Manali Winter'), findsOneWidget);
    expect(find.text('Manali'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.textContaining('12–16 Dec'), findsOneWidget);
  });
}
