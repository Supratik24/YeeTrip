import 'package:flutter/foundation.dart';

/// Sync status of a trip.
enum SyncStatus {
  synced,
  syncing,
  offline,
  error,
}

/// Operation type for a sync change.
enum SyncOperationType {
  create,
  update,
  delete,
}

/// Entity types that participate in sync.
enum SyncEntityType {
  trip,
  traveler,
  categoryAllocation,
  expense,
}

/// A serialized record of an entity with sync metadata.
@immutable
class SyncEntityRecord {
  final String entityId;
  final SyncEntityType entityType;
  final String tripId;
  final int version;
  final DateTime updatedAt;
  final bool isDeleted;
  final Map<String, dynamic> data;

  const SyncEntityRecord({
    required this.entityId,
    required this.entityType,
    required this.tripId,
    required this.version,
    required this.updatedAt,
    this.isDeleted = false,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        'entityType': entityType.name,
        'tripId': tripId,
        'version': version,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'isDeleted': isDeleted,
        'data': data,
      };

  factory SyncEntityRecord.fromJson(Map<String, dynamic> json) {
    return SyncEntityRecord(
      entityId: json['entityId'] as String,
      entityType: SyncEntityType.values.firstWhere(
        (e) => e.name == json['entityType'],
        orElse: () => SyncEntityType.trip,
      ),
      tripId: json['tripId'] as String,
      version: json['version'] as int? ?? 1,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
      data: Map<String, dynamic>.from(json['data'] as Map),
    );
  }

  SyncEntityRecord copyWith({
    String? entityId,
    SyncEntityType? entityType,
    String? tripId,
    int? version,
    DateTime? updatedAt,
    bool? isDeleted,
    Map<String, dynamic>? data,
  }) {
    return SyncEntityRecord(
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      tripId: tripId ?? this.tripId,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      data: data ?? this.data,
    );
  }
}

/// Cloud sync room linking a local trip to a 6-character invite code.
@immutable
class TripSyncRoom {
  final String tripId;
  final String inviteCode; // e.g. "GOA-782"
  final DateTime createdAt;
  final DateTime? lastSyncedAt;
  final SyncStatus status;
  final int pendingChangesCount;

  const TripSyncRoom({
    required this.tripId,
    required this.inviteCode,
    required this.createdAt,
    this.lastSyncedAt,
    this.status = SyncStatus.synced,
    this.pendingChangesCount = 0,
  });

  TripSyncRoom copyWith({
    String? tripId,
    String? inviteCode,
    DateTime? createdAt,
    DateTime? lastSyncedAt,
    SyncStatus? status,
    int? pendingChangesCount,
  }) {
    return TripSyncRoom(
      tripId: tripId ?? this.tripId,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      status: status ?? this.status,
      pendingChangesCount:
          pendingChangesCount ?? this.pendingChangesCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'tripId': tripId,
        'inviteCode': inviteCode,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'lastSyncedAt': lastSyncedAt?.toUtc().toIso8601String(),
        'status': status.name,
        'pendingChangesCount': pendingChangesCount,
      };

  factory TripSyncRoom.fromJson(Map<String, dynamic> json) {
    return TripSyncRoom(
      tripId: json['tripId'] as String,
      inviteCode: json['inviteCode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
      status: SyncStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => SyncStatus.synced,
      ),
      pendingChangesCount: json['pendingChangesCount'] as int? ?? 0,
    );
  }
}

/// An operation in the local offline sync queue.
@immutable
class SyncQueueItem {
  final String id;
  final String tripId;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperationType operation;
  final int version;
  final DateTime updatedAt;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  const SyncQueueItem({
    required this.id,
    required this.tripId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.version,
    required this.updatedAt,
    required this.payload,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'entityType': entityType.name,
        'entityId': entityId,
        'operation': operation.name,
        'version': version,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'payload': payload,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      entityType: SyncEntityType.values.firstWhere(
        (e) => e.name == json['entityType'],
      ),
      entityId: json['entityId'] as String,
      operation: SyncOperationType.values.firstWhere(
        (o) => o.name == json['operation'],
      ),
      version: json['version'] as int? ?? 1,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Result of an attempted push/pull sync cycle.
@immutable
class SyncReport {
  final bool success;
  final String message;
  final int itemsPushed;
  final int itemsPulled;
  final int conflictsResolved;
  final DateTime timestamp;

  const SyncReport({
    required this.success,
    required this.message,
    this.itemsPushed = 0,
    this.itemsPulled = 0,
    this.conflictsResolved = 0,
    required this.timestamp,
  });

  factory SyncReport.offline({String message = 'Device is currently offline'}) {
    return SyncReport(
      success: false,
      message: message,
      timestamp: DateTime.now().toUtc(),
    );
  }
}
