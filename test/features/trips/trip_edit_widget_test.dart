import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/data/repositories/trip_repository.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';
import 'package:yeetrip/features/trips/presentation/screens/trip_edit_screen.dart';

class MockTripRepository extends Mock implements TripRepository {}

void main() {
  late MockTripRepository mockTripRepo;

  final initialTrip = TripWithDetails(
    id: 'trip-1',
    name: 'Goa Weekend 🌴',
    totalBudgetPaise: 6000000, // ₹60,000
    days: 4,
    currency: 'INR',
    createdAt: DateTime.now(),
    travelers: const [
      Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav', upiVpa: 'aarav@upi'),
      Traveler(id: 't-2', tripId: 'trip-1', name: 'Diya'),
    ],
    categoryAllocations: const {},
    totalSpentPaise: 100000,
  );

  setUp(() {
    mockTripRepo = MockTripRepository();
    when(() => mockTripRepo.watchTripById('trip-1'))
        .thenAnswer((_) => Stream.value(initialTrip));
    when(() => mockTripRepo.getTripById('trip-1'))
        .thenAnswer((_) => Future.value(initialTrip));
  });

  Widget buildScreen() {
    return ProviderScope(
      overrides: [
        tripRepositoryProvider.overrideWithValue(mockTripRepo),
        tripDetailsProvider('trip-1').overrideWith(
          (ref) => Stream.value(initialTrip),
        ),
      ],
      child: const MaterialApp(
        home: TripEditScreen(tripId: 'trip-1'),
      ),
    );
  }

  group('TripEditScreen Widget Tests', () {
    testWidgets('populates existing trip name, budget, days, and travelers', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Edit trip details'), findsOneWidget);
      expect(find.text('Goa Weekend 🌴'), findsOneWidget);
      expect(find.text('60000'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Aarav'), findsOneWidget);
      expect(find.text('aarav@upi'), findsOneWidget);
      expect(find.text('Diya'), findsOneWidget);
    });

    testWidgets('allows adding a new traveler with optional UPI ID and saving', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => mockTripRepo.updateTripDetails(
            tripId: any(named: 'tripId'),
            name: any(named: 'name'),
            totalBudgetPaise: any(named: 'totalBudgetPaise'),
            days: any(named: 'days'),
          )).thenAnswer((_) async {});

      when(() => mockTripRepo.updateTraveler(
            travelerId: any(named: 'travelerId'),
            name: any(named: 'name'),
            upiVpa: any(named: 'upiVpa'),
          )).thenAnswer((_) async {});

      when(() => mockTripRepo.addTraveler(
            tripId: any(named: 'tripId'),
            name: any(named: 'name'),
            upiVpa: any(named: 'upiVpa'),
          )).thenAnswer((_) async => 't-3');

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Tap "Add person"
      await tester.tap(find.byKey(const Key('add_traveler_btn')));
      await tester.pumpAndSettle();

      // Third traveler fields should now be present
      expect(find.byKey(const Key('edit_traveler_name_2')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('edit_traveler_name_2')), 'Kabir');
      await tester.enterText(find.byKey(const Key('edit_traveler_vpa_2')), 'kabir@okaxis');
      await tester.pumpAndSettle();

      // Tap Save changes
      await tester.tap(find.byKey(const Key('save_trip_changes_btn')));
      await tester.pumpAndSettle();

      verify(() => mockTripRepo.updateTripDetails(
            tripId: 'trip-1',
            name: 'Goa Weekend 🌴',
            totalBudgetPaise: 6000000,
            days: 4,
          )).called(1);

      verify(() => mockTripRepo.addTraveler(
            tripId: 'trip-1',
            name: 'Kabir',
            upiVpa: 'kabir@okaxis',
          )).called(1);
    });

    testWidgets('blocks removing traveler if they have logged expenses', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      when(() => mockTripRepo.canDeleteTraveler('t-1'))
          .thenAnswer((_) async => false);

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Try removing Aarav (index 0)
      await tester.tap(find.byKey(const Key('remove_traveler_btn_0')));
      await tester.pumpAndSettle();

      // Alert dialog explaining removal is blocked
      expect(find.text('Cannot remove traveler'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Aarav should still be present
      expect(find.text('Aarav'), findsOneWidget);
    });
  });
}
