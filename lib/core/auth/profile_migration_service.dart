import 'package:drift/drift.dart';

import '../../data/local/app_database.dart';
import 'auth_models.dart';

/// Report summarizing local traveler profile linking after user signs in.
class ProfileMigrationReport {
  final int tripsInspected;
  final int travelersLinked;
  final int upisUpdated;

  const ProfileMigrationReport({
    required this.tripsInspected,
    required this.travelersLinked,
    required this.upisUpdated,
  });
}

/// Service that safely links local offline trips to a newly authenticated user account
/// without altering trip IDs, expenses, or split amounts.
class ProfileMigrationService {
  final AppDatabase _db;

  const ProfileMigrationService(this._db);

  /// Inspects all local trips and links travelers matching the user's name or identity.
  Future<ProfileMigrationReport> linkProfileToLocalTrips(UserProfile user) async {
    final allTrips = await _db.select(_db.trips).get();
    if (allTrips.isEmpty) {
      return const ProfileMigrationReport(
        tripsInspected: 0,
        travelersLinked: 0,
        upisUpdated: 0,
      );
    }

    int linkedCount = 0;
    int upiUpdatedCount = 0;

    final userNameLower = user.displayName.trim().toLowerCase();
    final userFirstNameLower = userNameLower.split(' ').first;

    await _db.transaction(() async {
      for (final trip in allTrips) {
        final travelers = await (_db.select(_db.travelers)
              ..where((t) => t.tripId.equals(trip.id)))
            .get();

        for (final traveler in travelers) {
          final travNameLower = traveler.name.trim().toLowerCase();
          final isMatch = travNameLower == userNameLower ||
              travNameLower == userFirstNameLower ||
              userNameLower.startsWith(travNameLower);

          if (isMatch) {
            linkedCount++;
            // If traveler has no UPI ID and user has a default UPI ID, assign it
            if ((traveler.upiVpa == null || traveler.upiVpa!.isEmpty) &&
                user.defaultUpiVpa != null &&
                user.defaultUpiVpa!.isNotEmpty) {
              await (_db.update(_db.travelers)..where((t) => t.id.equals(traveler.id))).write(
                TravelersCompanion(
                  upiVpa: Value(user.defaultUpiVpa),
                ),
              );
              upiUpdatedCount++;
            }
          }
        }
      }
    });

    return ProfileMigrationReport(
      tripsInspected: allTrips.length,
      travelersLinked: linkedCount,
      upisUpdated: upiUpdatedCount,
    );
  }
}
