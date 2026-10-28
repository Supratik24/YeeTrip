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
}
