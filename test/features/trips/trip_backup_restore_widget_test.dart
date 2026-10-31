import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/data/repositories/trip_repository.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/settings/presentation/screens/settings_screen.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';
import 'package:yeetrip/features/trips/presentation/screens/trip_list_screen.dart';
import 'package:yeetrip/features/trips/services/trip_backup_service.dart';

class MockTripBackupService extends Mock implements TripBackupService {}
class MockTripRepository extends Mock implements TripRepository {}

void main() {
  late MockTripBackupService mockBackupService;
  late MockTripRepository mockTripRepo;

  final sampleTrip = TripWithDetails(
    id: 'trip-1',
    name: 'Coorg Coffee Trails ☕',
    totalBudgetPaise: 3000000,
    days: 3,
    currency: 'INR',
    createdAt: DateTime.now(),
    travelers: const [
      Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
    ],
    categoryAllocations: const {},
    totalSpentPaise: 0,
  );

  setUp(() {
    mockBackupService = MockTripBackupService();
    mockTripRepo = MockTripRepository();
  });

  group('Trip Backup & Restore UI Tests', () {
    testWidgets('SettingsScreen opens restore dialog and restores trip',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => mockBackupService.restoreTripFromJson(any()))
          .thenAnswer((_) async => 'restored-trip-id');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripBackupServiceProvider.overrideWithValue(mockBackupService),
            tripExpensesProvider('trip-1')
                .overrideWith((ref) => Stream.value(<ExpenseWithSplits>[])),
          ],
          child: MaterialApp(
            home: SettingsScreen(trip: sampleTrip),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Backup and Restore buttons
      expect(find.byKey(const Key('backup_trip_json_btn')), findsOneWidget);
      expect(find.byKey(const Key('restore_trip_from_settings_btn')),
          findsOneWidget);

      // Tap restore from settings button
      await tester.tap(find.byKey(const Key('restore_trip_from_settings_btn')));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.widgetWithText(AlertDialog, 'Restore trip from backup'),
          findsOneWidget);
      expect(find.byKey(const Key('restore_trip_json_field')), findsOneWidget);

      // Enter sample JSON
      const sampleJson = '{"version": 1, "trip": {"name": "Restored Trip"}}';
      await tester.enterText(
          find.byKey(const Key('restore_trip_json_field')), sampleJson);
      await tester.pumpAndSettle();

      // Tap Confirm Restore
      await tester.tap(find.byKey(const Key('confirm_restore_btn')));
      await tester.pumpAndSettle();

      verify(() => mockBackupService.restoreTripFromJson(sampleJson)).called(1);
    });

    testWidgets('TripListScreen has import backup action in AppBar',
        (tester) async {
      when(() => mockTripRepo.watchTrips())
          .thenAnswer((_) => Stream.value([sampleTrip]));
      when(() => mockBackupService.restoreTripFromJson(any()))
          .thenAnswer((_) async => 'restored-trip-id');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripRepositoryProvider.overrideWithValue(mockTripRepo),
            tripBackupServiceProvider.overrideWithValue(mockBackupService),
            tripsStreamProvider.overrideWith((ref) => Stream.value([sampleTrip])),
          ],
          child: const MaterialApp(
            home: TripListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Action button should exist in AppBar
      final importBtn = find.byKey(const Key('import_trip_backup_btn'));
      expect(importBtn, findsOneWidget);

      await tester.tap(importBtn);
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Import trip backup'), findsOneWidget);
      expect(find.byKey(const Key('restore_trip_json_field')), findsOneWidget);

      const sampleJson = '{"version": 1, "trip": {"name": "Coorg Trip"}}';
      await tester.enterText(
          find.byKey(const Key('restore_trip_json_field')), sampleJson);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_restore_btn')));
      await tester.pumpAndSettle();

      verify(() => mockBackupService.restoreTripFromJson(sampleJson)).called(1);
    });
  });
}
