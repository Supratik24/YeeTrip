import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/sync/remote_sync_repository.dart';
import 'package:yeetrip/core/sync/sync_engine.dart';
import 'package:yeetrip/core/sync/sync_models.dart';
import 'package:yeetrip/core/sync/sync_providers.dart';
import 'package:yeetrip/data/local/app_database.dart' hide Traveler;
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/features/sync/presentation/widgets/cloud_sync_sheet.dart';
import 'package:yeetrip/features/sync/presentation/widgets/join_trip_dialog.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';
import 'package:yeetrip/features/settings/presentation/screens/settings_screen.dart';
import 'package:yeetrip/features/trips/presentation/screens/trip_list_screen.dart';

class _FakeSyncEngine extends SyncEngine {
  final Map<String, TripSyncRoom> mockRooms = {};
  final _roomController = StreamController<TripSyncRoom?>.broadcast();
  TripWithDetails? joinResult;

  _FakeSyncEngine({
    required super.db,
    required super.remoteSync,
  });

  @override
  TripSyncRoom? getSyncRoom(String tripId) => mockRooms[tripId];

  @override
  Stream<TripSyncRoom?> watchSyncRoom(String tripId) async* {
    yield mockRooms[tripId];
    yield* _roomController.stream;
  }

  @override
  Future<TripSyncRoom> shareTrip(String tripId) async {
    final room = TripSyncRoom(
      tripId: tripId,
      inviteCode: 'GOA-782',
      createdAt: DateTime.now().toUtc(),
      status: SyncStatus.synced,
    );
    mockRooms[tripId] = room;
    _roomController.add(room);
    return room;
  }

  @override
  Future<TripWithDetails> joinTripByCode(String inviteCode) async {
    if (inviteCode != 'GOA-782' && inviteCode != 'MUM-104') {
      throw Exception('Trip with invite code "$inviteCode" was not found.');
    }
    return joinResult ??
        TripWithDetails(
          id: 'trip-joined',
          name: 'Joined Goa Trip',
          totalBudgetPaise: 5000000,
          days: 4,
          createdAt: DateTime.now(),
          travelers: const [Traveler(id: 't-1', tripId: 'trip-joined', name: 'Aarav')],
          categoryAllocations: const {'Stay': 100},
          totalSpentPaise: 0,
        );
  }

  @override
  Future<SyncReport> syncTrip(String tripId) async {
    return SyncReport(
      success: true,
      message: 'Sync completed: 0 pushed, 0 pulled',
      timestamp: DateTime.now().toUtc(),
    );
  }
}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  final trip = TripWithDetails(
    id: 'trip-1',
    name: 'Goa Weekend 🌴',
    totalBudgetPaise: 5000000,
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
    totalSpentPaise: 100000,
  );

  group('JoinTripDialog UI Tests', () {
    testWidgets('Validates input, displays error for invalid code, and joins successfully for valid code',
        (tester) async {
      final fakeEngine = _FakeSyncEngine(
        db: AppDatabase(),
        remoteSync: MockRemoteSyncServer(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncEngineProvider.overrideWithValue(fakeEngine),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: JoinTripDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Join Trip'), findsWidgets);
      expect(find.byKey(const Key('invite_code_input')), findsOneWidget);

      // 1. Submit with empty code -> shows validation error
      await tester.tap(find.byKey(const Key('submit_join_trip_btn')));
      await tester.pumpAndSettle();
      expect(find.text('Please enter an invite code'), findsOneWidget);

      // 2. Submit with invalid format -> shows format error
      await tester.enterText(find.byKey(const Key('invite_code_input')), 'INVALID');
      await tester.tap(find.byKey(const Key('submit_join_trip_btn')));
      await tester.pumpAndSettle();
      expect(find.text('Code must be in ABC-123 format'), findsOneWidget);

      // 3. Submit with valid code 'GOA-782'
      await tester.enterText(find.byKey(const Key('invite_code_input')), 'GOA-782');
      await tester.tap(find.byKey(const Key('submit_join_trip_btn')));
      await tester.pumpAndSettle();

      // Dialog dismissed on success
      expect(find.byKey(const Key('invite_code_input')), findsNothing);
    });
  });

  group('CloudSyncSheet UI Tests', () {
    testWidgets('Shows local-only state initially and enables cloud collaboration on tap',
        (tester) async {
      final fakeEngine = _FakeSyncEngine(
        db: AppDatabase(),
        remoteSync: MockRemoteSyncServer(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncEngineProvider.overrideWithValue(fakeEngine),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CloudSyncSheet(trip: trip),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cloud Sync & Collaboration'), findsOneWidget);
      expect(find.text('Currently Local Only'), findsOneWidget);
      expect(find.byKey(const Key('enable_cloud_sync_btn')), findsOneWidget);

      // Tap enable cloud collaboration
      await tester.tap(find.byKey(const Key('enable_cloud_sync_btn')));
      await tester.pumpAndSettle();

      // Should now display invite code 'GOA-782' and Sync Now button
      expect(find.text('GOA-782'), findsOneWidget);
      expect(find.byKey(const Key('copy_invite_code_btn')), findsOneWidget);
      expect(find.byKey(const Key('share_invite_code_btn')), findsOneWidget);
      expect(find.byKey(const Key('sync_now_btn')), findsOneWidget);
      expect(find.text('All changes synced to cloud'), findsOneWidget);

      // Tap Sync Now
      await tester.tap(find.byKey(const Key('sync_now_btn')));
      await tester.pumpAndSettle();
      expect(find.text('Sync completed: 0 pushed, 0 pulled'), findsOneWidget);
    });
  });

  group('TripListScreen & SettingsScreen Cloud Sync Integration Tests', () {
    testWidgets('TripListScreen renders join trip button in AppBar and opens dialog',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripsStreamProvider.overrideWith((ref) => Stream.value([trip])),
          ],
          child: const MaterialApp(
            home: TripListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final joinBtn = find.byKey(const Key('join_trip_code_btn'));
      expect(joinBtn, findsOneWidget);

      await tester.tap(joinBtn);
      await tester.pumpAndSettle();

      expect(find.byType(JoinTripDialog), findsOneWidget);
    });

    testWidgets('SettingsScreen renders Cloud Sync & Collaboration Card and opens sheet',
        (tester) async {
      final fakeEngine = _FakeSyncEngine(
        db: AppDatabase(),
        remoteSync: MockRemoteSyncServer(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncEngineProvider.overrideWithValue(fakeEngine),
            tripExpensesProvider(trip.id).overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            home: SettingsScreen(trip: trip),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('cloud_sync_card')), findsOneWidget);
      expect(find.text('Cloud Sync & Collaboration'), findsOneWidget);

      final openSheetBtn = find.byKey(const Key('open_cloud_sync_sheet_btn'));
      expect(openSheetBtn, findsOneWidget);

      await tester.tap(openSheetBtn);
      await tester.pumpAndSettle();

      expect(find.byType(CloudSyncSheet), findsOneWidget);
    });
  });
}
