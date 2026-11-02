import 'dart:async';

import 'package:drift/drift.dart';

import '../../data/local/app_database.dart' hide Traveler;
import '../../features/trips/domain/trip_model.dart';
import 'conflict_resolver.dart';
import 'remote_sync_repository.dart';
import 'sync_models.dart';
import 'sync_queue.dart';

/// Orchestrates local SQLite persistence, offline queueing, remote syncing,
/// and deterministic conflict resolution for YeeTrip.
class SyncEngine {
  final AppDatabase _db;
  final RemoteSyncRepository _remoteSync;
  final SyncQueue _syncQueue;
  final ConflictResolver _resolver;

  final Map<String, TripSyncRoom> _rooms = {};
  final _roomStreamControllers = <String, StreamController<TripSyncRoom?>>{};

  SyncEngine({
    required this._db,
    required this._remoteSync,
    SyncQueue? syncQueue,
    ConflictResolver? resolver,
  })  : _syncQueue = syncQueue ?? SyncQueue(),
        _resolver = resolver ?? const ConflictResolver();

  SyncQueue get queue => _syncQueue;
  RemoteSyncRepository get remoteSync => _remoteSync;

  StreamController<TripSyncRoom?> _getController(String tripId) {
    return _roomStreamControllers.putIfAbsent(
      tripId,
      () => StreamController<TripSyncRoom?>.broadcast(),
    );
  }

  /// Observes real-time sync room state for a trip.
  Stream<TripSyncRoom?> watchSyncRoom(String tripId) {
    final controller = _getController(tripId);
    // Emit current cached state immediately
    controller.add(_rooms[tripId]);
    return controller.stream;
  }

  /// Observes current sync status for a trip.
  Stream<SyncStatus> watchSyncStatus(String tripId) {
    return watchSyncRoom(tripId).map(
      (room) => room?.status ?? (_remoteSync.isOnline ? SyncStatus.synced : SyncStatus.offline),
    );
  }

  TripSyncRoom? getSyncRoom(String tripId) => _rooms[tripId];

  void _updateRoom(TripSyncRoom room) {
    _rooms[room.tripId] = room;
    _getController(room.tripId).add(room);
  }

  /// Shares a local trip to cloud, creating a cloud room and returning its 6-char code.
  Future<TripSyncRoom> shareTrip(String tripId) async {
    final existingRoom = _rooms[tripId];
    if (existingRoom != null) return existingRoom;

    // Load trip data from SQLite
    final tripRow = await (_db.select(_db.trips)..where((t) => t.id.equals(tripId)))
        .getSingleOrNull();
    if (tripRow == null) {
      throw Exception('Trip not found locally: $tripId');
    }

    final travelerRows = await (_db.select(_db.travelers)
          ..where((t) => t.tripId.equals(tripId)))
        .get();

    final allocationRows = await (_db.select(_db.categoryAllocations)
          ..where((c) => c.tripId.equals(tripId)))
        .get();

    final expenseRows = await (_db.select(_db.expenses)
          ..where((e) => e.tripId.equals(tripId)))
        .get();

    final allocationsMap = <String, int>{
      for (final a in allocationRows) a.category: a.percent,
    };

    final tripRecord = SyncEntityRecord(
      entityId: tripRow.id,
      entityType: SyncEntityType.trip,
      tripId: tripRow.id,
      version: 1,
      updatedAt: DateTime.now().toUtc(),
      data: {
        'name': tripRow.name,
        'totalBudgetPaise': tripRow.totalBudgetPaise,
        'days': tripRow.days,
        'currency': tripRow.currency,
        'createdAt': tripRow.createdAt.toUtc().toIso8601String(),
        'categoryAllocations': allocationsMap,
      },
    );

    final travelerRecords = travelerRows
        .map(
          (t) => SyncEntityRecord(
            entityId: t.id,
            entityType: SyncEntityType.traveler,
            tripId: tripId,
            version: 1,
            updatedAt: DateTime.now().toUtc(),
            data: {
              'name': t.name,
              'upiVpa': t.upiVpa,
            },
          ),
        )
        .toList();

    final expenseRecords = <SyncEntityRecord>[];
    for (final exp in expenseRows) {
      final splits = await (_db.select(_db.expenseSplits)
            ..where((s) => s.expenseId.equals(exp.id)))
          .get();

      expenseRecords.add(
        SyncEntityRecord(
          entityId: exp.id,
          entityType: SyncEntityType.expense,
          tripId: tripId,
          version: 1,
          updatedAt: exp.createdAt.toUtc(),
          data: {
            'description': exp.description,
            'amountPaise': exp.amountPaise,
            'category': exp.category,
            'paidBy': exp.paidBy,
            'source': exp.source,
            'confirmed': exp.confirmed,
            'upiTxnId': exp.upiTxnId,
            'createdAt': exp.createdAt.toUtc().toIso8601String(),
            'splits': splits
                .map((s) => {
                      'travelerId': s.travelerId,
                      'sharePaise': s.sharePaise,
                    })
                .toList(),
          },
        ),
      );
    }

    final inviteCode = await _remoteSync.createSyncRoom(
      tripId: tripId,
      tripName: tripRow.name,
      initialTripRecord: tripRecord,
      initialTravelers: travelerRecords,
      initialExpenses: expenseRecords,
    );

    final room = TripSyncRoom(
      tripId: tripId,
      inviteCode: inviteCode,
      createdAt: DateTime.now().toUtc(),
      lastSyncedAt: DateTime.now().toUtc(),
      status: SyncStatus.synced,
    );

    _updateRoom(room);
    return room;
  }

  /// Joins a remote trip via a 6-character invite code and downloads it to SQLite.
  Future<TripWithDetails> joinTripByCode(String inviteCode) async {
    final snapshot = await _remoteSync.fetchTripByInviteCode(inviteCode);
    if (snapshot == null) {
      throw Exception('Trip with invite code "$inviteCode" was not found.');
    }

    final tripData = snapshot.trip.data;
    final tripId = snapshot.trip.tripId;

    // Check if trip already exists locally
    final existing = await (_db.select(_db.trips)..where((t) => t.id.equals(tripId)))
        .getSingleOrNull();

    if (existing == null) {
      // Atomic SQLite transaction
      await _db.transaction(() async {
        await _db.into(_db.trips).insert(
              TripsCompanion(
                id: Value(tripId),
                name: Value(tripData['name'] as String),
                totalBudgetPaise: Value(tripData['totalBudgetPaise'] as int),
                days: Value(tripData['days'] as int),
                currency: Value(tripData['currency'] as String? ?? 'INR'),
                createdAt: Value(
                  DateTime.parse(tripData['createdAt'] as String),
                ),
              ),
            );

        // Allocations
        final rawAlloc = tripData['categoryAllocations'] as Map?;
        if (rawAlloc != null) {
          for (final entry in rawAlloc.entries) {
            await _db.into(_db.categoryAllocations).insert(
                  CategoryAllocationsCompanion(
                    tripId: Value(tripId),
                    category: Value(entry.key.toString()),
                    percent: Value(entry.value as int),
                  ),
                );
          }
        }

        // Travelers
        for (final t in snapshot.travelers) {
          await _db.into(_db.travelers).insert(
                TravelersCompanion(
                  id: Value(t.entityId),
                  tripId: Value(tripId),
                  name: Value(t.data['name'] as String),
                  upiVpa: Value(t.data['upiVpa'] as String?),
                ),
              );
        }

        // Expenses & Splits
        for (final expRecord in snapshot.expenses) {
          final expData = expRecord.data;
          await _db.into(_db.expenses).insert(
                ExpensesCompanion(
                  id: Value(expRecord.entityId),
                  tripId: Value(tripId),
                  description: Value(expData['description'] as String),
                  amountPaise: Value(expData['amountPaise'] as int),
                  category: Value(expData['category'] as String),
                  paidBy: Value(expData['paidBy'] as String),
                  source: Value(expData['source'] as String? ?? 'manual'),
                  confirmed: Value(expData['confirmed'] as bool? ?? true),
                  upiTxnId: Value(expData['upiTxnId'] as String?),
                  createdAt: Value(
                    DateTime.parse(expData['createdAt'] as String),
                  ),
                ),
              );

          final rawSplits = expData['splits'] as List? ?? [];
          for (final s in rawSplits) {
            final splitMap = Map<String, dynamic>.from(s as Map);
            await _db.into(_db.expenseSplits).insert(
                  ExpenseSplitsCompanion(
                    expenseId: Value(expRecord.entityId),
                    travelerId: Value(splitMap['travelerId'] as String),
                    sharePaise: Value(splitMap['sharePaise'] as int),
                  ),
                );
          }
        }
      });
    }

    final room = TripSyncRoom(
      tripId: tripId,
      inviteCode: snapshot.inviteCode,
      createdAt: DateTime.now().toUtc(),
      lastSyncedAt: DateTime.now().toUtc(),
      status: SyncStatus.synced,
    );
    _updateRoom(room);

    // Build TripWithDetails to return
    final travelers = snapshot.travelers
        .map(
          (t) => Traveler(
            id: t.entityId,
            tripId: tripId,
            name: t.data['name'] as String,
            upiVpa: t.data['upiVpa'] as String?,
          ),
        )
        .toList();

    final allocations = <String, int>{};
    final rawAlloc = tripData['categoryAllocations'] as Map?;
    if (rawAlloc != null) {
      for (final entry in rawAlloc.entries) {
        allocations[entry.key.toString()] = entry.value as int;
      }
    }

    int totalSpent = 0;
    for (final exp in snapshot.expenses) {
      totalSpent += exp.data['amountPaise'] as int? ?? 0;
    }

    return TripWithDetails(
      id: tripId,
      name: tripData['name'] as String,
      totalBudgetPaise: tripData['totalBudgetPaise'] as int,
      days: tripData['days'] as int,
      currency: tripData['currency'] as String? ?? 'INR',
      createdAt: DateTime.parse(tripData['createdAt'] as String),
      travelers: travelers,
      categoryAllocations: allocations,
      totalSpentPaise: totalSpent,
    );
  }

  /// Performs a full bidirectional sync cycle for a trip:
  /// 1. Push pending local changes from queue
  /// 2. Pull remote changes and merge using Last-Write-Wins
  Future<SyncReport> syncTrip(String tripId) async {
    final room = _rooms[tripId];
    if (room == null) {
      return SyncReport(
        success: false,
        message: 'Trip $tripId is not linked to a cloud room',
        timestamp: DateTime.now().toUtc(),
      );
    }

    if (!_remoteSync.isOnline) {
      _updateRoom(room.copyWith(
        status: SyncStatus.offline,
        pendingChangesCount: _syncQueue.countForTrip(tripId),
      ));
      return SyncReport.offline();
    }

    _updateRoom(room.copyWith(status: SyncStatus.syncing));

    try {
      // 1. Push local changes
      final pendingItems = _syncQueue.getItemsForTrip(tripId);
      int pushedCount = 0;
      int pushConflicts = 0;

      if (pendingItems.isNotEmpty) {
        final pushReport = await _remoteSync.pushChanges(
          inviteCode: room.inviteCode,
          queueItems: pendingItems,
        );
        pushedCount = pushReport.itemsPushed;
        pushConflicts = pushReport.conflictsResolved;
        _syncQueue.removeItems(pendingItems.map((i) => i.id).toList());
      }

      // 2. Pull remote changes
      final remoteChanges = await _remoteSync.pullChanges(
        inviteCode: room.inviteCode,
        since: room.lastSyncedAt,
      );

      int pulledCount = 0;
      int pullConflicts = 0;

      for (final change in remoteChanges) {
        if (change.entityType == SyncEntityType.expense) {
          if (change.isDeleted) {
            // Tombstone deletion
            await (_db.delete(_db.expenses)..where((e) => e.id.equals(change.entityId)))
                .go();
            pulledCount++;
          } else {
            // Apply or update expense
            final existing = await (_db.select(_db.expenses)
                  ..where((e) => e.id.equals(change.entityId)))
                .getSingleOrNull();

            final expData = change.data;
            if (existing == null) {
              await _db.into(_db.expenses).insert(
                    ExpensesCompanion(
                      id: Value(change.entityId),
                      tripId: Value(tripId),
                      description: Value(expData['description'] as String),
                      amountPaise: Value(expData['amountPaise'] as int),
                      category: Value(expData['category'] as String),
                      paidBy: Value(expData['paidBy'] as String),
                      source: Value(expData['source'] as String? ?? 'manual'),
                      confirmed: Value(expData['confirmed'] as bool? ?? true),
                      upiTxnId: Value(expData['upiTxnId'] as String?),
                      createdAt: Value(
                        DateTime.parse(expData['createdAt'] as String),
                      ),
                    ),
                  );

              final rawSplits = expData['splits'] as List? ?? [];
              for (final s in rawSplits) {
                final splitMap = Map<String, dynamic>.from(s as Map);
                await _db.into(_db.expenseSplits).insert(
                      ExpenseSplitsCompanion(
                        expenseId: Value(change.entityId),
                        travelerId: Value(splitMap['travelerId'] as String),
                        sharePaise: Value(splitMap['sharePaise'] as int),
                      ),
                    );
              }
              pulledCount++;
            } else {
              // Existing expense conflict resolution
              final localRecord = SyncEntityRecord(
                entityId: existing.id,
                entityType: SyncEntityType.expense,
                tripId: tripId,
                version: 1,
                updatedAt: existing.createdAt.toUtc(),
                data: {'amountPaise': existing.amountPaise},
              );

              final winner = _resolver.resolveWinner(
                local: localRecord,
                remote: change,
              );

              if (winner == ConflictWinner.remote) {
                // Update expense
                await (_db.update(_db.expenses)..where((e) => e.id.equals(change.entityId)))
                    .write(
                  ExpensesCompanion(
                    description: Value(expData['description'] as String),
                    amountPaise: Value(expData['amountPaise'] as int),
                    category: Value(expData['category'] as String),
                    paidBy: Value(expData['paidBy'] as String),
                  ),
                );

                // Re-write splits
                await (_db.delete(_db.expenseSplits)
                      ..where((s) => s.expenseId.equals(change.entityId)))
                    .go();

                final rawSplits = expData['splits'] as List? ?? [];
                for (final s in rawSplits) {
                  final splitMap = Map<String, dynamic>.from(s as Map);
                  await _db.into(_db.expenseSplits).insert(
                        ExpenseSplitsCompanion(
                          expenseId: Value(change.entityId),
                          travelerId: Value(splitMap['travelerId'] as String),
                          sharePaise: Value(splitMap['sharePaise'] as int),
                        ),
                      );
                }
                pulledCount++;
              } else {
                pullConflicts++;
              }
            }
          }
        } else if (change.entityType == SyncEntityType.trip) {
          final tripData = change.data;
          await (_db.update(_db.trips)..where((t) => t.id.equals(tripId))).write(
            TripsCompanion(
              name: Value(tripData['name'] as String),
              totalBudgetPaise: Value(tripData['totalBudgetPaise'] as int),
              days: Value(tripData['days'] as int),
            ),
          );
          pulledCount++;
        }
      }

      final updatedRoom = room.copyWith(
        status: SyncStatus.synced,
        lastSyncedAt: DateTime.now().toUtc(),
        pendingChangesCount: _syncQueue.countForTrip(tripId),
      );
      _updateRoom(updatedRoom);

      return SyncReport(
        success: true,
        message: 'Sync completed: $pushedCount pushed, $pulledCount pulled',
        itemsPushed: pushedCount,
        itemsPulled: pulledCount,
        conflictsResolved: pushConflicts + pullConflicts,
        timestamp: DateTime.now().toUtc(),
      );
    } catch (e) {
      _updateRoom(room.copyWith(status: SyncStatus.error));
      return SyncReport(
        success: false,
        message: 'Sync failed: $e',
        timestamp: DateTime.now().toUtc(),
      );
    }
  }

  // Queue helper methods called by repositories when changes occur
  void recordLocalExpenseChange({
    required String tripId,
    required String expenseId,
    required SyncOperationType operation,
    required Map<String, dynamic> data,
  }) {
    _syncQueue.enqueue(
      SyncQueueItem(
        id: '${expenseId}_${DateTime.now().millisecondsSinceEpoch}',
        tripId: tripId,
        entityType: SyncEntityType.expense,
        entityId: expenseId,
        operation: operation,
        version: 1,
        updatedAt: DateTime.now().toUtc(),
        payload: data,
        createdAt: DateTime.now().toUtc(),
      ),
    );

    final room = _rooms[tripId];
    if (room != null) {
      _updateRoom(room.copyWith(
        pendingChangesCount: _syncQueue.countForTrip(tripId),
      ));
    }
  }
}
