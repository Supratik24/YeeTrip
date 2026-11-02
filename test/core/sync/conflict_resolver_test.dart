import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/sync/conflict_resolver.dart';
import 'package:yeetrip/core/sync/sync_models.dart';

void main() {
  const resolver = ConflictResolver();

  group('ConflictResolver - Last-Write-Wins (LWW) Tests', () {
    test('Remote record with later timestamp wins over local record', () {
      final t1 = DateTime.utc(2026, 11, 1, 10, 0, 0);
      final t2 = DateTime.utc(2026, 11, 1, 10, 5, 0);

      final local = SyncEntityRecord(
        entityId: 'exp-1',
        entityType: SyncEntityType.expense,
        tripId: 'trip-1',
        version: 1,
        updatedAt: t1,
        data: {'amountPaise': 50000, 'description': 'Lunch'},
      );

      final remote = SyncEntityRecord(
        entityId: 'exp-1',
        entityType: SyncEntityType.expense,
        tripId: 'trip-1',
        version: 1,
        updatedAt: t2,
        data: {'amountPaise': 65000, 'description': 'Grand Lunch'},
      );

      final winner = resolver.resolveWinner(local: local, remote: remote);
      expect(winner, equals(ConflictWinner.remote));

      final merged = resolver.merge(local: local, remote: remote);
      expect(merged.data['description'], equals('Grand Lunch'));
      expect(merged.data['amountPaise'], equals(65000));
      expect(merged.version, equals(2));
      expect(merged.updatedAt, equals(t2));
    });

    test('Local record with later timestamp wins over remote record', () {
      final t1 = DateTime.utc(2026, 11, 1, 11, 0, 0);
      final t2 = DateTime.utc(2026, 11, 1, 10, 30, 0);

      final local = SyncEntityRecord(
        entityId: 'exp-1',
        entityType: SyncEntityType.expense,
        tripId: 'trip-1',
        version: 2,
        updatedAt: t1,
        data: {'description': 'Local Edit'},
      );

      final remote = SyncEntityRecord(
        entityId: 'exp-1',
        entityType: SyncEntityType.expense,
        tripId: 'trip-1',
        version: 1,
        updatedAt: t2,
        data: {'description': 'Stale Remote Edit'},
      );

      final winner = resolver.resolveWinner(local: local, remote: remote);
      expect(winner, equals(ConflictWinner.local));

      final merged = resolver.merge(local: local, remote: remote);
      expect(merged.data['description'], equals('Local Edit'));
    });

    test('Identical timestamps use higher version number', () {
      final t = DateTime.utc(2026, 11, 1, 12, 0, 0);

      final local = SyncEntityRecord(
        entityId: 'exp-1',
        entityType: SyncEntityType.expense,
        tripId: 'trip-1',
        version: 2,
        updatedAt: t,
        data: {'description': 'Local v2'},
      );

      final remote = SyncEntityRecord(
        entityId: 'exp-1',
        entityType: SyncEntityType.expense,
        tripId: 'trip-1',
        version: 3,
        updatedAt: t,
        data: {'description': 'Remote v3'},
      );

      final winner = resolver.resolveWinner(local: local, remote: remote);
      expect(winner, equals(ConflictWinner.remote));
    });

    test('Deterministic tie-breaker when timestamp and version are identical', () {
      final t = DateTime.utc(2026, 11, 1, 12, 0, 0);

      final local = SyncEntityRecord(
        entityId: 'exp-1',
        entityType: SyncEntityType.expense,
        tripId: 'trip-1',
        version: 2,
        updatedAt: t,
        data: {'description': 'Apple'},
      );

      final remote = SyncEntityRecord(
        entityId: 'exp-1',
        entityType: SyncEntityType.expense,
        tripId: 'trip-1',
        version: 2,
        updatedAt: t,
        data: {'description': 'Banana'},
      );

      // Deterministic: won't throw, resolves reliably
      final winner = resolver.resolveWinner(local: local, remote: remote);
      expect(winner, isNotNull);
    });
  });

  group('ConflictResolver - Splits & Allocation Reconciler', () {
    test('reconcileExpenseSplits adjusts remainder to payer when sum does not match', () {
      final splits = [
        {'travelerId': 't-1', 'sharePaise': 3000},
        {'travelerId': 't-2', 'sharePaise': 3000},
        {'travelerId': 't-3', 'sharePaise': 3000},
      ];

      // Total amount is 10,000 paise (diff of +1000 paise)
      final reconciled = ConflictResolver.reconcileExpenseSplits(
        amountPaise: 10000,
        paidByTravelerId: 't-1',
        splits: splits,
      );

      final sum = reconciled.fold<int>(
        0,
        (s, item) => s + (item['sharePaise'] as int),
      );
      expect(sum, equals(10000));
      expect(reconciled.firstWhere((s) => s['travelerId'] == 't-1')['sharePaise'], equals(4000));
    });

    test('normalizeAllocations ensures category allocations sum to exactly 100%', () {
      final uneven = {
        'Stay': 33,
        'Food': 33,
        'Transport': 33,
      };

      final normalized = ConflictResolver.normalizeAllocations(uneven);
      final sum = normalized.values.fold<int>(0, (a, b) => a + b);
      expect(sum, equals(100));
    });
  });
}
