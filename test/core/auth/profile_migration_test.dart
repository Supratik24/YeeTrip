import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/auth/auth_models.dart';
import 'package:yeetrip/core/auth/profile_migration_service.dart';
import 'package:yeetrip/data/local/app_database.dart';
import 'package:yeetrip/data/repositories/trip_repository.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late DriftTripRepository tripRepo;
  late ProfileMigrationService migrationService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    tripRepo = DriftTripRepository(db);
    migrationService = ProfileMigrationService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ProfileMigrationService Tests', () {
    test('Zero-loss migration links travelers across trips to authenticated profile', () async {
      // 1. Create two trips in Guest mode
      final trip1Id = await tripRepo.createTrip(
        name: 'Goa Weekend 🌴',
        totalBudgetPaise: 6000000,
        days: 4,
        travelerNames: ['Aarav', 'Diya'],
      );

      final trip2Id = await tripRepo.createTrip(
        name: 'Manali Snow ❄️',
        totalBudgetPaise: 9000000,
        days: 5,
        travelerNames: ['Aarav Sharma', 'Kabir'],
      );

      // Verify initial state: travelers have null UPI VPA
      final trip1Initial = await tripRepo.getTripById(trip1Id);
      final aaravTrip1 = trip1Initial!.travelers.firstWhere((t) => t.name == 'Aarav');
      expect(aaravTrip1.upiVpa, isNull);

      final trip2Initial = await tripRepo.getTripById(trip2Id);
      final aaravTrip2 = trip2Initial!.travelers.firstWhere((t) => t.name == 'Aarav Sharma');
      expect(aaravTrip2.upiVpa, isNull);

      // 2. User signs in with cloud account
      final user = UserProfile(
        uid: 'usr-12345',
        displayName: 'Aarav Sharma',
        email: 'aarav.sharma@gmail.com',
        defaultUpiVpa: 'aarav@oksbi',
        createdAt: DateTime.now().toUtc(),
      );

      // 3. Run migration
      final report = await migrationService.linkProfileToLocalTrips(user);
      expect(report.tripsInspected, equals(2));
      expect(report.travelersLinked, equals(2));
      expect(report.upisUpdated, equals(2));

      // 4. Verify post-migration state: Aarav has UPI ID linked
      final trip1Updated = await tripRepo.getTripById(trip1Id);
      expect(trip1Updated!.id, equals(trip1Id)); // Trip ID intact
      expect(trip1Updated.totalBudgetPaise, equals(6000000)); // Budget intact
      expect(trip1Updated.days, equals(4)); // Days intact
      final aarav1After = trip1Updated.travelers.firstWhere((t) => t.name == 'Aarav');
      expect(aarav1After.upiVpa, equals('aarav@oksbi'));

      final diya = trip1Updated.travelers.firstWhere((t) => t.name == 'Diya');
      expect(diya.upiVpa, isNull); // Other travelers unaffected

      final trip2Updated = await tripRepo.getTripById(trip2Id);
      expect(trip2Updated!.id, equals(trip2Id));
      final aarav2After = trip2Updated.travelers.firstWhere((t) => t.name == 'Aarav Sharma');
      expect(aarav2After.upiVpa, equals('aarav@oksbi'));
    });

    test('Migration handles empty database without errors', () async {
      final user = UserProfile(
        uid: 'usr-empty',
        displayName: 'Neha Gupta',
        email: 'neha@gmail.com',
        defaultUpiVpa: 'neha@okaxis',
        createdAt: DateTime.now().toUtc(),
      );

      final report = await migrationService.linkProfileToLocalTrips(user);
      expect(report.tripsInspected, equals(0));
      expect(report.travelersLinked, equals(0));
      expect(report.upisUpdated, equals(0));
    });
  });
}
