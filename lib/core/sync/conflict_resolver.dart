import 'sync_models.dart';

/// Conflict resolution outcome.
enum ConflictWinner {
  local,
  remote,
}

/// Pure Dart Last-Write-Wins (LWW) conflict resolver for YeeTrip entities.
class ConflictResolver {
  const ConflictResolver();

  /// Resolves two conflicting versions of an entity using Last-Write-Wins with Lamport timestamps.
  ConflictWinner resolveWinner({
    required SyncEntityRecord local,
    required SyncEntityRecord remote,
  }) {
    // 1. Primary rule: Greater updatedAt timestamp wins (LWW)
    if (remote.updatedAt.isAfter(local.updatedAt)) {
      return ConflictWinner.remote;
    }
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      return ConflictWinner.local;
    }

    // 2. Secondary rule: Higher monotonic version number wins
    if (remote.version > local.version) {
      return ConflictWinner.remote;
    }
    if (local.version > remote.version) {
      return ConflictWinner.local;
    }

    // 3. Deterministic tie-breaker: Lexicographical comparison of entity JSON
    final localStr = local.toJson().toString();
    final remoteStr = remote.toJson().toString();
    return remoteStr.compareTo(localStr) >= 0
        ? ConflictWinner.remote
        : ConflictWinner.local;
  }

  /// Merges local and remote entity records, returning the winning record.
  SyncEntityRecord merge({
    required SyncEntityRecord local,
    required SyncEntityRecord remote,
  }) {
    final winner = resolveWinner(local: local, remote: remote);
    final base = winner == ConflictWinner.remote ? remote : local;

    // Highest version + 1 when merging
    final nextVersion = (remote.version > local.version ? remote.version : local.version) + 1;
    final latestTime = remote.updatedAt.isAfter(local.updatedAt)
        ? remote.updatedAt
        : local.updatedAt;

    return base.copyWith(
      version: nextVersion,
      updatedAt: latestTime,
    );
  }

  /// Reconciles expense splits to strictly ensure sum(splits) == amountPaise.
  /// If splits do not sum to total amount, adjusts the remaining paise to the payer or first traveler.
  static List<Map<String, dynamic>> reconcileExpenseSplits({
    required int amountPaise,
    required String paidByTravelerId,
    required List<Map<String, dynamic>> splits,
  }) {
    if (splits.isEmpty) {
      return [
        {
          'travelerId': paidByTravelerId,
          'sharePaise': amountPaise,
        }
      ];
    }

    final totalShare = splits.fold<int>(
      0,
      (sum, s) => sum + (s['sharePaise'] as int? ?? 0),
    );

    final diff = amountPaise - totalShare;
    if (diff == 0) {
      return splits;
    }

    // Adjust diff onto payer's split if present, otherwise first split
    final updatedSplits = List<Map<String, dynamic>>.from(
      splits.map((s) => Map<String, dynamic>.from(s)),
    );

    final payerIndex = updatedSplits.indexWhere(
      (s) => s['travelerId'] == paidByTravelerId,
    );

    final targetIndex = payerIndex != -1 ? payerIndex : 0;
    final currentShare = updatedSplits[targetIndex]['sharePaise'] as int? ?? 0;
    updatedSplits[targetIndex]['sharePaise'] = currentShare + diff;

    return updatedSplits;
  }

  /// Validates and normalizes category allocations to sum to exactly 100%.
  static Map<String, int> normalizeAllocations(Map<String, int> allocations) {
    if (allocations.isEmpty) {
      return const {
        'Stay': 30,
        'Food': 25,
        'Transport': 20,
        'Activities': 15,
        'Shopping': 5,
        'Buffer': 5,
      };
    }

    final total = allocations.values.fold<int>(0, (a, b) => a + b);
    if (total == 100) return allocations;

    // Rebalance proportionally
    final result = <String, int>{};
    int runningSum = 0;
    final entries = allocations.entries.toList();

    for (int i = 0; i < entries.length - 1; i++) {
      final allocated = ((entries[i].value / total) * 100).round();
      result[entries[i].key] = allocated;
      runningSum += allocated;
    }

    // Last category gets the remainder to guarantee 100%
    result[entries.last.key] = 100 - runningSum;
    return result;
  }
}
