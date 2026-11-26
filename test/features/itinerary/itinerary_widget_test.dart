import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/data/repositories/itinerary_repository.dart';
import 'package:yeetrip/features/itinerary/domain/itinerary_model.dart';
import 'package:yeetrip/features/itinerary/presentation/screens/itinerary_screen.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

class _MockItineraryRepo extends Mock implements ItineraryRepository {}

void main() {
  late _MockItineraryRepo mockItineraryRepo;

  final trip = TripWithDetails(
    id: 'trip-1',
    name: 'Goa Escape',
    totalBudgetPaise: 5000000,
    days: 3,
    currency: 'INR',
    createdAt: DateTime(2026, 12, 1),
    startDate: DateTime(2026, 12, 10),
    travelers: const [
      Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
    ],
  );

  final items = [
    ItineraryItemModel(
      id: 'i-1',
      tripId: 'trip-1',
      dayNumber: 1,
      title: 'Airport Pickup & Villa Check-in',
      location: 'Candolim, Goa',
      startTimeMinutes: 11 * 60,
      category: 'Stay',
      estimatedCostPaise: 800000,
      createdAt: DateTime(2026, 12, 1),
    ),
    ItineraryItemModel(
      id: 'i-2',
      tripId: 'trip-1',
      dayNumber: 2,
      title: 'Kayaking at Palolem',
      startTimeMinutes: 8 * 60 + 30,
      category: 'Activities',
      estimatedCostPaise: 150000,
      isCompleted: true,
      createdAt: DateTime(2026, 12, 1),
    ),
  ];

  setUp(() {
    mockItineraryRepo = _MockItineraryRepo();
    when(() => mockItineraryRepo.toggleCompleted(any(), any()))
        .thenAnswer((_) async {});
    when(
      () => mockItineraryRepo.addItem(
        tripId: any(named: 'tripId'),
        dayNumber: any(named: 'dayNumber'),
        title: any(named: 'title'),
        location: any(named: 'location'),
        timeSlot: any(named: 'timeSlot'),
        startTimeMinutes: any(named: 'startTimeMinutes'),
        category: any(named: 'category'),
        estimatedCostPaise: any(named: 'estimatedCostPaise'),
        notes: any(named: 'notes'),
        isCompleted: any(named: 'isCompleted'),
        sortOrder: any(named: 'sortOrder'),
      ),
    ).thenAnswer((_) async => 'i-new');
  });

  testWidgets('ItineraryScreen renders days, filters by day, toggles done, and opens add sheet',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripDetailsProvider('trip-1').overrideWith((ref) => Stream.value(trip)),
          tripItineraryProvider('trip-1').overrideWith((ref) => Stream.value(items)),
          itineraryRepositoryProvider.overrideWithValue(mockItineraryRepo),
        ],
        child: const MaterialApp(
          home: ItineraryScreen(tripId: 'trip-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 of 2 completed'), findsOneWidget);
    expect(find.text('Airport Pickup & Villa Check-in'), findsOneWidget);
    expect(find.text('Kayaking at Palolem'), findsOneWidget);

    // Filter to Day 1
    await tester.tap(find.byKey(const Key('itinerary_day_1')));
    await tester.pumpAndSettle();
    expect(find.text('Airport Pickup & Villa Check-in'), findsOneWidget);
    expect(find.text('Kayaking at Palolem'), findsNothing);

    // Toggle Checkbox
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    verify(() => mockItineraryRepo.toggleCompleted('i-1', true)).called(1);

    // Open Add activity sheet & add activity
    await tester.tap(find.byKey(const Key('add_itinerary_item_fab')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('itinerary_title_field')),
      'Sunset Beach Walk',
    );
    await tester.tap(find.byKey(const Key('save_itinerary_item_btn')));
    await tester.pumpAndSettle();

    verify(
      () => mockItineraryRepo.addItem(
        tripId: 'trip-1',
        dayNumber: 1,
        title: 'Sunset Beach Walk',
        location: '',
        startTimeMinutes: null,
        category: 'Activities',
        estimatedCostPaise: 0,
        notes: '',
      ),
    ).called(1);
  });
}
