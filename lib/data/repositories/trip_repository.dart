import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/categories.dart';
import '../../features/trips/domain/trip_model.dart';
import '../local/app_database.dart' hide Traveler;

/// Clean interface for Trip data operations.
/// UI never talks to drift directly; it accesses data through this interface.
abstract class TripRepository {
  Future<List<TripWithDetails>> getTrips();
  Stream<List<TripWithDetails>> watchTrips();
  Future<TripWithDetails?> getTripById(String id);
  Stream<TripWithDetails?> watchTripById(String id);
  Future<String> createTrip({
    required String name,
    required int totalBudgetPaise,
    required int days,
    required List<String> travelerNames,
    Map<String, int>? allocations,
  });
  Future<void> deleteTrip(String tripId);
  Future<void> updateCategoryAllocations(
    String tripId,
    Map<String, int> allocations,
  );
}

/// Drift implementation of [TripRepository].
class DriftTripRepository implements TripRepository {
  final AppDatabase _db;
  final Uuid _uuid;

  DriftTripRepository(this._db, [Uuid? uuid]) : _uuid = uuid ?? const Uuid();

  @override
  Future<List<TripWithDetails>> getTrips() async {
    final tripRows = await (_db.select(_db.trips)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();

    final List<TripWithDetails> result = [];
    for (final row in tripRows) {
      final details = await _loadTripDetails(row);
      result.add(details);
    }
    return result;
  }

  @override
  Stream<List<TripWithDetails>> watchTrips() {
    return (_db.select(_db.trips)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .asyncMap((rows) async {
      final List<TripWithDetails> result = [];
      for (final row in rows) {
        final details = await _loadTripDetails(row);
        result.add(details);
      }
      return result;
    });
  }

  @override
  Future<TripWithDetails?> getTripById(String id) async {
    final tripRow = await (_db.select(_db.trips)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (tripRow == null) return null;
    return _loadTripDetails(tripRow);
  }

  @override
  Stream<TripWithDetails?> watchTripById(String id) {
    return (_db.select(_db.trips)..where((t) => t.id.equals(id)))
        .watchSingleOrNull()
        .asyncMap((row) async {
      if (row == null) return null;
      return _loadTripDetails(row);
    });
  }

  @override
  Future<String> createTrip({
    required String name,
    required int totalBudgetPaise,
    required int days,
    required List<String> travelerNames,
    Map<String, int>? allocations,
  }) async {
    final tripId = _uuid.v4();
    final now = DateTime.now();

    await _db.transaction(() async {
      // 1. Insert Trip
      await _db.into(_db.trips).insert(
            TripsCompanion.insert(
              id: tripId,
              name: name.trim(),
              totalBudgetPaise: totalBudgetPaise,
              days: days,
              createdAt: now,
            ),
          );

      // 2. Insert Travelers
      for (final travelerName in travelerNames) {
        final travelerId = _uuid.v4();
        await _db.into(_db.travelers).insert(
              TravelersCompanion.insert(
                id: travelerId,
                tripId: tripId,
                name: travelerName.trim(),
              ),
            );
      }

      // 3. Insert Category Allocations
      final effectiveAllocations = allocations ?? TripCategory.defaultPercentages;
      for (final entry in effectiveAllocations.entries) {
        await _db.into(_db.categoryAllocations).insert(
              CategoryAllocationsCompanion.insert(
                tripId: tripId,
                category: entry.key,
                percent: entry.value,
              ),
            );
      }
    });

    return tripId;
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    // Foreign keys with cascade delete are configured, so deleting the trip
    // deletes its travelers, category allocations, expenses, and splits.
    await (_db.delete(_db.trips)..where((t) => t.id.equals(tripId))).go();
  }

  @override
  Future<void> updateCategoryAllocations(
    String tripId,
    Map<String, int> allocations,
  ) async {
    await _db.transaction(() async {
      await (_db.delete(_db.categoryAllocations)
            ..where((a) => a.tripId.equals(tripId)))
          .go();

      for (final entry in allocations.entries) {
        await _db.into(_db.categoryAllocations).insert(
              CategoryAllocationsCompanion.insert(
                tripId: tripId,
                category: entry.key,
                percent: entry.value,
              ),
            );
      }
    });
  }

  Future<TripWithDetails> _loadTripDetails(Trip row) async {
    // Fetch travelers
    final travelerRows = await (_db.select(_db.travelers)
          ..where((t) => t.tripId.equals(row.id)))
        .get();

    final travelers = travelerRows
        .map((t) => Traveler(
              id: t.id,
              tripId: t.tripId,
              name: t.name,
              upiVpa: t.upiVpa,
            ))
        .toList();

    // Fetch allocations
    final allocationRows = await (_db.select(_db.categoryAllocations)
          ..where((a) => a.tripId.equals(row.id)))
        .get();

    final allocations = {
      for (final a in allocationRows) a.category: a.percent,
    };

    // Calculate total spent from confirmed manual expenses (exclude settlements)
    final expenseRows = await (_db.select(_db.expenses)
          ..where((e) =>
              e.tripId.equals(row.id) &
              e.confirmed.equals(true) &
              e.source.equals('manual')))
        .get();

    final totalSpentPaise = expenseRows.fold<int>(
      0,
      (sum, e) => sum + e.amountPaise,
    );

    return TripWithDetails(
      id: row.id,
      name: row.name,
      totalBudgetPaise: row.totalBudgetPaise,
      days: row.days,
      currency: row.currency,
      createdAt: row.createdAt,
      travelers: travelers,
      categoryAllocations: allocations,
      totalSpentPaise: totalSpentPaise,
    );
  }
}
