import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../features/itinerary/domain/itinerary_model.dart';
import '../local/app_database.dart';

/// Clean interface for Day-by-Day Itinerary data operations.
abstract class ItineraryRepository {
  Future<List<ItineraryItemModel>> getItinerary(String tripId);
  Stream<List<ItineraryItemModel>> watchItinerary(String tripId);
  Future<String> addItem({
    required String tripId,
    required int dayNumber,
    required String title,
    String? location,
    String? timeSlot,
    int? startTimeMinutes,
    String category = 'Activities',
    int estimatedCostPaise = 0,
    String? notes,
    bool isCompleted = false,
    int sortOrder = 0,
  });
  Future<void> updateItem({
    required String itemId,
    required int dayNumber,
    required String title,
    String? location,
    String? timeSlot,
    int? startTimeMinutes,
    String? category,
    int? estimatedCostPaise,
    String? notes,
    bool? isCompleted,
    int? sortOrder,
  });
  Future<void> toggleCompleted(String itemId, bool completed);
  Future<void> deleteItem(String itemId);
}

/// Drift implementation of [ItineraryRepository].
class DriftItineraryRepository implements ItineraryRepository {
  final AppDatabase _db;
  final Uuid _uuid;

  DriftItineraryRepository(this._db, [Uuid? uuid])
      : _uuid = uuid ?? const Uuid();

  void _notifyTripUpdated() {
    _db.notifyUpdates(
      {TableUpdate.onTable(_db.trips, kind: UpdateKind.update)},
    );
  }

  @override
  Future<List<ItineraryItemModel>> getItinerary(String tripId) async {
    final rows = await (_db.select(_db.itineraryItems)
          ..where((i) => i.tripId.equals(tripId))
          ..orderBy([
            (i) => OrderingTerm.asc(i.dayNumber),
            (i) => OrderingTerm.asc(i.startTimeMinutes),
            (i) => OrderingTerm.asc(i.sortOrder),
            (i) => OrderingTerm.asc(i.createdAt),
          ]))
        .get();
    return rows.map(_mapRow).toList();
  }

  @override
  Stream<List<ItineraryItemModel>> watchItinerary(String tripId) {
    return (_db.select(_db.itineraryItems)
          ..where((i) => i.tripId.equals(tripId))
          ..orderBy([
            (i) => OrderingTerm.asc(i.dayNumber),
            (i) => OrderingTerm.asc(i.startTimeMinutes),
            (i) => OrderingTerm.asc(i.sortOrder),
            (i) => OrderingTerm.asc(i.createdAt),
          ]))
        .watch()
        .map((rows) => rows.map(_mapRow).toList());
  }

  @override
  Future<String> addItem({
    required String tripId,
    required int dayNumber,
    required String title,
    String? location,
    String? timeSlot,
    int? startTimeMinutes,
    String category = 'Activities',
    int estimatedCostPaise = 0,
    String? notes,
    bool isCompleted = false,
    int sortOrder = 0,
  }) async {
    final id = _uuid.v4();
    final trimmedLoc = location?.trim();
    final trimmedSlot = timeSlot?.trim();
    final trimmedNotes = notes?.trim();

    await _db.into(_db.itineraryItems).insert(
          ItineraryItemsCompanion.insert(
            id: id,
            tripId: tripId,
            dayNumber: dayNumber < 1 ? 1 : dayNumber,
            title: title.trim(),
            location: Value(
              trimmedLoc != null && trimmedLoc.isNotEmpty ? trimmedLoc : null,
            ),
            timeSlot: Value(
              trimmedSlot != null && trimmedSlot.isNotEmpty ? trimmedSlot : null,
            ),
            startTimeMinutes: Value(startTimeMinutes),
            category: Value(category),
            estimatedCostPaise: Value(estimatedCostPaise),
            notes: Value(
              trimmedNotes != null && trimmedNotes.isNotEmpty
                  ? trimmedNotes
                  : null,
            ),
            isCompleted: Value(isCompleted),
            sortOrder: Value(sortOrder),
            createdAt: DateTime.now(),
          ),
        );
    _notifyTripUpdated();
    return id;
  }

  @override
  Future<void> updateItem({
    required String itemId,
    required int dayNumber,
    required String title,
    String? location,
    String? timeSlot,
    int? startTimeMinutes,
    String? category,
    int? estimatedCostPaise,
    String? notes,
    bool? isCompleted,
    int? sortOrder,
  }) async {
    final trimmedLoc = location?.trim();
    final trimmedSlot = timeSlot?.trim();
    final trimmedNotes = notes?.trim();

    await (_db.update(_db.itineraryItems)..where((i) => i.id.equals(itemId)))
        .write(
      ItineraryItemsCompanion(
        dayNumber: Value(dayNumber < 1 ? 1 : dayNumber),
        title: Value(title.trim()),
        location: Value(
          trimmedLoc != null && trimmedLoc.isNotEmpty ? trimmedLoc : null,
        ),
        timeSlot: Value(
          trimmedSlot != null && trimmedSlot.isNotEmpty ? trimmedSlot : null,
        ),
        startTimeMinutes: Value(startTimeMinutes),
        category:
            category != null ? Value(category) : const Value.absent(),
        estimatedCostPaise: estimatedCostPaise != null
            ? Value(estimatedCostPaise)
            : const Value.absent(),
        notes: Value(
          trimmedNotes != null && trimmedNotes.isNotEmpty ? trimmedNotes : null,
        ),
        isCompleted:
            isCompleted != null ? Value(isCompleted) : const Value.absent(),
        sortOrder:
            sortOrder != null ? Value(sortOrder) : const Value.absent(),
      ),
    );
    _notifyTripUpdated();
  }

  @override
  Future<void> toggleCompleted(String itemId, bool completed) async {
    await (_db.update(_db.itineraryItems)..where((i) => i.id.equals(itemId)))
        .write(
      ItineraryItemsCompanion(isCompleted: Value(completed)),
    );
    _notifyTripUpdated();
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await (_db.delete(_db.itineraryItems)..where((i) => i.id.equals(itemId)))
        .go();
    _notifyTripUpdated();
  }

  ItineraryItemModel _mapRow(ItineraryItem row) {
    return ItineraryItemModel(
      id: row.id,
      tripId: row.tripId,
      dayNumber: row.dayNumber,
      title: row.title,
      location: row.location,
      timeSlot: row.timeSlot,
      startTimeMinutes: row.startTimeMinutes,
      category: row.category,
      estimatedCostPaise: row.estimatedCostPaise,
      notes: row.notes,
      isCompleted: row.isCompleted,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
    );
  }
}
