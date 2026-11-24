import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/data/repositories/trip_repository.dart';
import 'package:yeetrip/features/budget/presentation/screens/budget_sliders_screen.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

class _MockTripRepo implements TripRepository {
  Map<String, int>? lastUpdatedAllocations;

  @override
  Future<void> updateCategoryAllocations(String tripId, Map<String, int> allocations) async {
    lastUpdatedAllocations = Map.from(allocations);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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

    final mockRepo = _MockTripRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripRepositoryProvider.overrideWithValue(mockRepo),
        ],
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

  testWidgets('Dragging Stay slider updates Stay and rebalances Food, Transport etc in real-time',
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

    final mockRepo = _MockTripRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          home: BudgetSlidersScreen(trip: trip),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Initial check: Stay is 30%, Food is 25%, Transport is 20%
    expect(find.text('30%'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
    expect(find.text('20%'), findsOneWidget);

    // Find first slider (Stay) and drag it to the right
    final staySlider = find.byType(Slider).first;
    await tester.drag(staySlider, const Offset(150, 0));
    await tester.pumpAndSettle();

    // Total must still be 100%
    expect(find.text('100%'), findsWidgets);

    // Stay increased, and Food & Transport both rebalanced downward
    expect(find.text('30%'), findsNothing);
    expect(mockRepo.lastUpdatedAllocations!['Stay']! > 30, true);
    expect(mockRepo.lastUpdatedAllocations!['Food']! < 25, true);
    expect(mockRepo.lastUpdatedAllocations!['Transport']! < 20, true);
    expect(find.text('All changes saved'), findsOneWidget);
  });

  testWidgets('Releasing Stay slider auto-saves allocations to repository',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockRepo = _MockTripRepo();
    final trip = TripWithDetails(
      id: 'trip-1',
      name: 'Goa Trip',
      totalBudgetPaise: 6000000,
      days: 4,
      currency: 'INR',
      createdAt: DateTime.now(),
      travelers: const [
        Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
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
        overrides: [
          tripRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          home: BudgetSlidersScreen(trip: trip),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final staySlider = find.byType(Slider).first;
    await tester.drag(staySlider, const Offset(100, 0));
    await tester.pumpAndSettle();

    expect(mockRepo.lastUpdatedAllocations, isNotNull);
    expect(mockRepo.lastUpdatedAllocations!['Stay']! > 30, true);
    final sum = mockRepo.lastUpdatedAllocations!.values.fold<int>(0, (s, v) => s + v);
    expect(sum, equals(100));
  });

  testWidgets('Reset button restores default allocations and saves',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockRepo = _MockTripRepo();
    final trip = TripWithDetails(
      id: 'trip-1',
      name: 'Goa Trip',
      totalBudgetPaise: 6000000,
      days: 4,
      currency: 'INR',
      createdAt: DateTime.now(),
      travelers: const [
        Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
      ],
      categoryAllocations: const {
        'Stay': 50,
        'Food': 10,
        'Transport': 10,
        'Activities': 10,
        'Shopping': 10,
        'Buffer': 10,
      },
      totalSpentPaise: 0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          home: BudgetSlidersScreen(trip: trip),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap Reset
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    // Default for Stay is 30%
    expect(find.text('30%'), findsOneWidget);
    expect(mockRepo.lastUpdatedAllocations?['Stay'], equals(30));
  });
}
