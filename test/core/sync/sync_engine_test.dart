import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/sync/remote_sync_repository.dart';
import 'package:yeetrip/core/sync/sync_engine.dart';
import 'package:yeetrip/core/sync/sync_models.dart';
import 'package:yeetrip/data/local/app_database.dart';
import 'package:yeetrip/data/repositories/trip_repository.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase dbA;
  late AppDatabase dbB;
  late MockRemoteSyncServer remoteServer;
  late SyncEngine engineA;
  late SyncEngine engineB;
  late DriftTripRepository tripRepoA;

  setUp(() {
    dbA = AppDatabase(NativeDatabase.memory());
    dbB = AppDatabase(NativeDatabase.memory());
    remoteServer = MockRemoteSyncServer();

    engineA = SyncEngine(db: dbA, remoteSync: remoteServer);
    engineB = SyncEngine(db: dbB, remoteSync: remoteServer);

    tripRepoA = DriftTripRepository(dbA);
  });

  tearDown(() async {
    await dbA.close();
    await dbB.close();
  });

  group('SyncEngine - Cloud Room & Multi-Device Sync Tests', () {
    test('generateInviteCode produces a valid 6-7 character alphanumeric code', () {
      final code1 = remoteServer.generateInviteCode('Goa Beach');
      expect(code1, matches(RegExp(r'^[A-Z]{3}-[0-9]{3}$')));

      final code2 = remoteServer.generateInviteCode('MUMBAI');
      expect(code2.startsWith('MUM-'), isTrue);
    });

    test('Device A creates trip, shares it to cloud, and Device B joins using invite code', () async {
      // 1. Device A creates trip locally
      final tripId = await tripRepoA.createTrip(
        name: 'Goa Trip 🌴',
        totalBudgetPaise: 5000000,
        days: 4,
        travelerNames: ['Aarav', 'Diya'],
      );

      // 2. Device A shares trip to cloud
      final roomA = await engineA.shareTrip(tripId);
      expect(roomA.inviteCode, isNotEmpty);
      expect(roomA.status, equals(SyncStatus.synced));

      // 3. Device B joins trip using Device A's invite code
      final tripOnB = await engineB.joinTripByCode(roomA.inviteCode);
      expect(tripOnB.id, equals(tripId));
      expect(tripOnB.name, equals('Goa Trip 🌴'));
      expect(tripOnB.totalBudgetPaise, equals(5000000));
      expect(tripOnB.days, equals(4));
      expect(tripOnB.travelers.length, equals(2));
      expect(tripOnB.travelers.map((t) => t.name), containsAll(['Aarav', 'Diya']));

      // Verify trip was persisted in Device B's local database
      final storedB = await (dbB.select(dbB.trips)..where((t) => t.id.equals(tripId))).getSingle();
      expect(storedB.name, equals('Goa Trip 🌴'));
    });

    test('Bidirectional syncing: Device B adds an expense and Device A pulls it', () async {
      // 1. Setup shared trip
      final tripId = await tripRepoA.createTrip(
        name: 'Manali Snow ❄️',
        totalBudgetPaise: 8000000,
        days: 5,
        travelerNames: ['Kabir', 'Rohan'],
      );

      final roomA = await engineA.shareTrip(tripId);
      final tripB = await engineB.joinTripByCode(roomA.inviteCode);
      final kabirId = tripB.travelers.firstWhere((t) => t.name == 'Kabir').id;

      // 2. Device B records a local expense and adds to sync queue
      const expenseId = 'exp-b-1';
      engineB.recordLocalExpenseChange(
        tripId: tripId,
        expenseId: expenseId,
        operation: SyncOperationType.create,
        data: {
          'description': 'Snow Boots Rental',
          'amountPaise': 240000,
          'category': 'Activities',
          'paidBy': kabirId,
          'source': 'manual',
          'confirmed': true,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'splits': [
            {'travelerId': kabirId, 'sharePaise': 240000},
          ],
        },
      );

      expect(engineB.queue.countForTrip(tripId), equals(1));

      // 3. Device B syncs to push the expense to cloud
      final reportB = await engineB.syncTrip(tripId);
      expect(reportB.success, isTrue);
      expect(reportB.itemsPushed, equals(1));
      expect(engineB.queue.countForTrip(tripId), equals(0));

      // 4. Device A syncs to pull Device B's expense
      final reportA = await engineA.syncTrip(tripId);
      expect(reportA.success, isTrue);
      expect(reportA.itemsPulled, greaterThanOrEqualTo(1));

      // 5. Verify Device A's local SQLite has the expense
      final expRow = await (dbA.select(dbA.expenses)..where((e) => e.id.equals(expenseId))).getSingle();
      expect(expRow.description, equals('Snow Boots Rental'));
      expect(expRow.amountPaise, equals(240000));
      expect(expRow.category, equals('Activities'));
    });

    test('Offline queuing: changes queued while offline are synced when back online', () async {
      final tripId = await tripRepoA.createTrip(
        name: 'Jaipur Forts 🏰',
        totalBudgetPaise: 4000000,
        days: 3,
        travelerNames: ['Aarav'],
      );
      await engineA.shareTrip(tripId);

      // Simulate network disconnected
      remoteServer.setOnline(false);

      final aarav = await (dbA.select(dbA.travelers)..where((t) => t.tripId.equals(tripId))).getSingle();

      // Queue an expense while offline
      engineA.recordLocalExpenseChange(
        tripId: tripId,
        expenseId: 'exp-offline-1',
        operation: SyncOperationType.create,
        data: {
          'description': 'Amber Fort Ticket',
          'amountPaise': 50000,
          'category': 'Activities',
          'paidBy': aarav.id,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'splits': [
            {'travelerId': aarav.id, 'sharePaise': 50000},
          ],
        },
      );

      expect(engineA.queue.countForTrip(tripId), equals(1));

      // Attempt sync while offline -> should report offline and keep queue intact
      final offlineReport = await engineA.syncTrip(tripId);
      expect(offlineReport.success, isFalse);
      expect(engineA.getSyncRoom(tripId)?.status, equals(SyncStatus.offline));
      expect(engineA.queue.countForTrip(tripId), equals(1));

      // Reconnect network
      remoteServer.setOnline(true);

      // Sync again -> flushes queue
      final onlineReport = await engineA.syncTrip(tripId);
      expect(onlineReport.success, isTrue);
      expect(onlineReport.itemsPushed, equals(1));
      expect(engineA.queue.countForTrip(tripId), equals(0));
      expect(engineA.getSyncRoom(tripId)?.status, equals(SyncStatus.synced));
    });

    test('Deletions propagate via tombstones', () async {
      final tripId = await tripRepoA.createTrip(
        name: 'Kerala Backwaters ⛵',
        totalBudgetPaise: 6000000,
        days: 4,
        travelerNames: ['Diya'],
      );
      final room = await engineA.shareTrip(tripId);
      final tripB = await engineB.joinTripByCode(room.inviteCode);

      // Device A creates an expense and syncs
      const expId = 'exp-boat-1';
      engineA.recordLocalExpenseChange(
        tripId: tripId,
        expenseId: expId,
        operation: SyncOperationType.create,
        data: {
          'description': 'Houseboat Ride',
          'amountPaise': 350000,
          'category': 'Stay',
          'paidBy': tripB.travelers.first.id,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'splits': [],
        },
      );
      await engineA.syncTrip(tripId);

      // Device B syncs and gets the expense
      await engineB.syncTrip(tripId);
      var bExpenses = await (dbB.select(dbB.expenses)..where((e) => e.id.equals(expId))).get();
      expect(bExpenses.length, equals(1));

      // Device A deletes the expense and syncs
      engineA.recordLocalExpenseChange(
        tripId: tripId,
        expenseId: expId,
        operation: SyncOperationType.delete,
        data: {},
      );
      await engineA.syncTrip(tripId);

      // Device B syncs -> tombstone deletes the expense from Device B's local SQLite
      await engineB.syncTrip(tripId);
      bExpenses = await (dbB.select(dbB.expenses)..where((e) => e.id.equals(expId))).get();
      expect(bExpenses.isEmpty, isTrue);
    });
  });
}
