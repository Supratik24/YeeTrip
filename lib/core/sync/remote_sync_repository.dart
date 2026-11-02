import 'dart:math';

import 'conflict_resolver.dart';
import 'sync_models.dart';

/// Data bundle for a full trip snapshot from the remote server.
class RemoteTripSnapshot {
  final String inviteCode;
  final SyncEntityRecord trip;
  final List<SyncEntityRecord> travelers;
  final List<SyncEntityRecord> expenses;

  const RemoteTripSnapshot({
    required this.inviteCode,
    required this.trip,
    required this.travelers,
    required this.expenses,
  });
}

/// Abstract contract for remote cloud sync.
/// Can be backed by Supabase, Firebase Firestore, WebSockets, or custom backend.
abstract class RemoteSyncRepository {
  bool get isOnline;
  void setOnline(bool online);

  Future<String> createSyncRoom({
    required String tripId,
    required String tripName,
    required SyncEntityRecord initialTripRecord,
    required List<SyncEntityRecord> initialTravelers,
    List<SyncEntityRecord> initialExpenses = const [],
  });

  Future<RemoteTripSnapshot?> fetchTripByInviteCode(String inviteCode);

  Future<SyncReport> pushChanges({
    required String inviteCode,
    required List<SyncQueueItem> queueItems,
  });

  Future<List<SyncEntityRecord>> pullChanges({
    required String inviteCode,
    DateTime? since,
  });
}

/// In-memory cloud simulation server with real-time multi-device support,
/// deterministic conflict resolution, and offline toggle.
class MockRemoteSyncServer implements RemoteSyncRepository {
  bool _isOnline = true;
  final Map<String, _MockCloudRoom> _roomsByCode = {};
  final Map<String, String> _codeByTripId = {};
  final ConflictResolver _resolver;
  final Random _random;

  MockRemoteSyncServer({
    ConflictResolver? resolver,
    Random? random,
  })  : _resolver = resolver ?? const ConflictResolver(),
        _random = random ?? Random(42);

  @override
  bool get isOnline => _isOnline;

  @override
  void setOnline(bool online) {
    _isOnline = online;
  }

  /// Formats 6-character room code (e.g. "GOA-782" or "MUM-419").
  String generateInviteCode(String tripName) {
    final cleanName = tripName.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    final prefix = cleanName.length >= 3
        ? cleanName.substring(0, 3)
        : cleanName.padRight(3, 'X');
    final num = (_random.nextInt(900) + 100).toString();
    return '$prefix-$num';
  }

  @override
  Future<String> createSyncRoom({
    required String tripId,
    required String tripName,
    required SyncEntityRecord initialTripRecord,
    required List<SyncEntityRecord> initialTravelers,
    List<SyncEntityRecord> initialExpenses = const [],
  }) async {
    if (!_isOnline) {
      throw Exception('Cannot create cloud room: device is offline');
    }

    if (_codeByTripId.containsKey(tripId)) {
      final code = _codeByTripId[tripId]!;
      return code;
    }

    String code;
    do {
      code = generateInviteCode(tripName);
    } while (_roomsByCode.containsKey(code));

    final room = _MockCloudRoom(
      inviteCode: code,
      tripId: tripId,
      tripRecord: initialTripRecord,
    );

    for (final t in initialTravelers) {
      room.travelers[t.entityId] = t;
    }
    for (final e in initialExpenses) {
      room.expenses[e.entityId] = e;
    }

    _roomsByCode[code] = room;
    _codeByTripId[tripId] = code;

    return code;
  }

  @override
  Future<RemoteTripSnapshot?> fetchTripByInviteCode(String inviteCode) async {
    if (!_isOnline) {
      throw Exception('Cannot connect to cloud: device is offline');
    }

    final normalizedCode = inviteCode.trim().toUpperCase();
    final room = _roomsByCode[normalizedCode];
    if (room == null) return null;

    return RemoteTripSnapshot(
      inviteCode: normalizedCode,
      trip: room.tripRecord,
      travelers: room.travelers.values.where((t) => !t.isDeleted).toList(),
      expenses: room.expenses.values.where((e) => !e.isDeleted).toList(),
    );
  }

  @override
  Future<SyncReport> pushChanges({
    required String inviteCode,
    required List<SyncQueueItem> queueItems,
  }) async {
    if (!_isOnline) {
      return SyncReport.offline();
    }

    final normalizedCode = inviteCode.trim().toUpperCase();
    final room = _roomsByCode[normalizedCode];
    if (room == null) {
      return SyncReport(
        success: false,
        message: 'Cloud room not found for code $inviteCode',
        timestamp: DateTime.now().toUtc(),
      );
    }

    int applied = 0;
    int conflicts = 0;

    for (final item in queueItems) {
      final incomingRecord = SyncEntityRecord(
        entityId: item.entityId,
        entityType: item.entityType,
        tripId: item.tripId,
        version: item.version,
        updatedAt: item.updatedAt,
        isDeleted: item.operation == SyncOperationType.delete,
        data: item.payload,
      );

      switch (item.entityType) {
        case SyncEntityType.trip:
          final existing = room.tripRecord;
          final winner = _resolver.resolveWinner(
            local: existing,
            remote: incomingRecord,
          );
          if (winner == ConflictWinner.remote) {
            room.tripRecord = incomingRecord;
            applied++;
          } else {
            conflicts++;
          }
          break;

        case SyncEntityType.traveler:
          final existing = room.travelers[item.entityId];
          if (existing == null) {
            room.travelers[item.entityId] = incomingRecord;
            applied++;
          } else {
            final winner = _resolver.resolveWinner(
              local: existing,
              remote: incomingRecord,
            );
            if (winner == ConflictWinner.remote) {
              room.travelers[item.entityId] = incomingRecord;
              applied++;
            } else {
              conflicts++;
            }
          }
          break;

        case SyncEntityType.expense:
          final existing = room.expenses[item.entityId];
          if (existing == null) {
            room.expenses[item.entityId] = incomingRecord;
            applied++;
          } else {
            if (item.operation == SyncOperationType.delete) {
              room.expenses[item.entityId] = existing.copyWith(
                isDeleted: true,
                version: existing.version + 1,
                updatedAt: item.updatedAt,
              );
              applied++;
            } else {
              final winner = _resolver.resolveWinner(
                local: existing,
                remote: incomingRecord,
              );
              if (winner == ConflictWinner.remote) {
                room.expenses[item.entityId] = incomingRecord;
                applied++;
              } else {
                conflicts++;
              }
            }
          }
          break;

        case SyncEntityType.categoryAllocation:
          // Handled within tripRecord
          applied++;
          break;
      }
    }

    return SyncReport(
      success: true,
      message: 'Pushed $applied changes ($conflicts conflicts)',
      itemsPushed: applied,
      conflictsResolved: conflicts,
      timestamp: DateTime.now().toUtc(),
    );
  }

  @override
  Future<List<SyncEntityRecord>> pullChanges({
    required String inviteCode,
    DateTime? since,
  }) async {
    if (!_isOnline) {
      throw Exception('Cannot pull changes: device is offline');
    }

    final normalizedCode = inviteCode.trim().toUpperCase();
    final room = _roomsByCode[normalizedCode];
    if (room == null) return [];

    final List<SyncEntityRecord> changes = [];

    // Trip check
    if (since == null || !room.tripRecord.updatedAt.isBefore(since)) {
      changes.add(room.tripRecord);
    }

    // Travelers
    for (final t in room.travelers.values) {
      if (since == null || !t.updatedAt.isBefore(since)) {
        changes.add(t);
      }
    }

    // Expenses
    for (final e in room.expenses.values) {
      if (since == null || !e.updatedAt.isBefore(since)) {
        changes.add(e);
      }
    }

    return changes;
  }
}

class _MockCloudRoom {
  final String inviteCode;
  final String tripId;
  SyncEntityRecord tripRecord;
  final Map<String, SyncEntityRecord> travelers = {};
  final Map<String, SyncEntityRecord> expenses = {};

  _MockCloudRoom({
    required this.inviteCode,
    required this.tripId,
    required this.tripRecord,
  });
}
