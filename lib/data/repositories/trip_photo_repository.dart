import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../features/gallery/domain/trip_photo_model.dart';
import '../local/app_database.dart';

/// Interface for managing trip gallery photos.
abstract class TripPhotoRepository {
  Future<List<TripPhotoModel>> getPhotos(String tripId);
  Stream<List<TripPhotoModel>> watchPhotos(String tripId);
  Future<String> addPhoto({
    required String tripId,
    required String imagePath,
    String? caption,
    int dayNumber = 1,
    String? uploadedByTravelerId,
    String uploadedByName = 'You',
    DateTime? createdAt,
  });
  Future<void> updateCaption({
    required String photoId,
    String? caption,
    int? dayNumber,
  });
  Future<void> deletePhoto(String photoId);
}

/// Drift SQLite implementation of [TripPhotoRepository].
class DriftTripPhotoRepository implements TripPhotoRepository {
  final AppDatabase _db;
  final Uuid _uuid;

  DriftTripPhotoRepository(this._db, [Uuid? uuid]) : _uuid = uuid ?? const Uuid();

  TripPhotoModel _mapRow(TripPhoto row) {
    return TripPhotoModel(
      id: row.id,
      tripId: row.tripId,
      imagePath: row.imagePath,
      caption: row.caption,
      dayNumber: row.dayNumber,
      uploadedByTravelerId: row.uploadedByTravelerId,
      uploadedByName: row.uploadedByName,
      createdAt: row.createdAt,
    );
  }

  void _notifyTripsChanged() {
    _db.notifyUpdates(
      {TableUpdate.onTable(_db.trips, kind: UpdateKind.update)},
    );
  }

  @override
  Future<List<TripPhotoModel>> getPhotos(String tripId) async {
    final rows = await (_db.select(_db.tripPhotos)
          ..where((p) => p.tripId.equals(tripId))
          ..orderBy([
            (p) => OrderingTerm.asc(p.dayNumber),
            (p) => OrderingTerm.desc(p.createdAt),
          ]))
        .get();
    return rows.map(_mapRow).toList();
  }

  @override
  Stream<List<TripPhotoModel>> watchPhotos(String tripId) {
    return (_db.select(_db.tripPhotos)
          ..where((p) => p.tripId.equals(tripId))
          ..orderBy([
            (p) => OrderingTerm.asc(p.dayNumber),
            (p) => OrderingTerm.desc(p.createdAt),
          ]))
        .watch()
        .map((rows) => rows.map(_mapRow).toList());
  }

  @override
  Future<String> addPhoto({
    required String tripId,
    required String imagePath,
    String? caption,
    int dayNumber = 1,
    String? uploadedByTravelerId,
    String uploadedByName = 'You',
    DateTime? createdAt,
  }) async {
    final id = _uuid.v4();
    final trimmedCaption = caption?.trim();
    final trimmedAuthor = uploadedByName.trim();
    await _db.into(_db.tripPhotos).insert(
          TripPhotosCompanion.insert(
            id: id,
            tripId: tripId,
            imagePath: imagePath.trim(),
            caption: Value(
              trimmedCaption != null && trimmedCaption.isNotEmpty
                  ? trimmedCaption
                  : null,
            ),
            dayNumber: Value(dayNumber < 1 ? 1 : dayNumber),
            uploadedByTravelerId: Value(uploadedByTravelerId),
            uploadedByName: Value(trimmedAuthor.isNotEmpty ? trimmedAuthor : 'You'),
            createdAt: createdAt ?? DateTime.now(),
          ),
        );
    _notifyTripsChanged();
    return id;
  }

  @override
  Future<void> updateCaption({
    required String photoId,
    String? caption,
    int? dayNumber,
  }) async {
    final trimmed = caption?.trim();
    await (_db.update(_db.tripPhotos)..where((p) => p.id.equals(photoId))).write(
      TripPhotosCompanion(
        caption: caption != null
            ? Value(trimmed != null && trimmed.isNotEmpty ? trimmed : null)
            : const Value.absent(),
        dayNumber: dayNumber != null
            ? Value(dayNumber < 1 ? 1 : dayNumber)
            : const Value.absent(),
      ),
    );
  }

  @override
  Future<void> deletePhoto(String photoId) async {
    await (_db.delete(_db.tripPhotos)..where((p) => p.id.equals(photoId))).go();
    _notifyTripsChanged();
  }
}
