import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import 'remote_sync_repository.dart';
import 'sync_engine.dart';
import 'sync_models.dart';

/// Provider for remote cloud sync server.
final remoteSyncRepositoryProvider = Provider<RemoteSyncRepository>((ref) {
  return MockRemoteSyncServer();
});

/// Provider for YeeTrip sync engine.
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(databaseProvider);
  final remote = ref.watch(remoteSyncRepositoryProvider);
  return SyncEngine(db: db, remoteSync: remote);
});

/// Reactive stream of sync room metadata for a trip.
final tripSyncRoomProvider =
    StreamProvider.family<TripSyncRoom?, String>((ref, tripId) {
  final engine = ref.watch(syncEngineProvider);
  return engine.watchSyncRoom(tripId);
});

/// Reactive stream of sync status for a trip.
final tripSyncStatusProvider =
    StreamProvider.family<SyncStatus, String>((ref, tripId) {
  final engine = ref.watch(syncEngineProvider);
  return engine.watchSyncStatus(tripId);
});
