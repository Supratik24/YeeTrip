import 'sync_models.dart';

/// Manages offline-first operation queue for changes waiting to be synced to cloud.
class SyncQueue {
  final List<SyncQueueItem> _items = [];

  List<SyncQueueItem> get allItems => List.unmodifiable(_items);

  /// Enqueues a new sync operation.
  void enqueue(SyncQueueItem item) {
    // If an earlier update/create exists for the exact same entity and trip,
    // consolidate if the new operation supersedes it.
    if (item.operation == SyncOperationType.delete) {
      // If we're deleting something that was only created in the local queue and not synced yet,
      // we can remove all pending operations for this entity.
      final existingIndex = _items.indexWhere(
        (i) => i.entityId == item.entityId && i.operation == SyncOperationType.create,
      );
      if (existingIndex != -1) {
        _items.removeWhere((i) => i.entityId == item.entityId);
        return;
      }
    }

    _items.add(item);
  }

  /// Returns all queued operations for a specific trip, ordered by creation time.
  List<SyncQueueItem> getItemsForTrip(String tripId) {
    return _items.where((i) => i.tripId == tripId).toList();
  }

  /// Returns total count of pending operations for a trip.
  int countForTrip(String tripId) {
    return _items.where((i) => i.tripId == tripId).length;
  }

  /// Removes successfully synced items by their IDs.
  void removeItems(List<String> itemIds) {
    final idsSet = itemIds.toSet();
    _items.removeWhere((i) => idsSet.contains(i.id));
  }

  /// Clears all queue items for a trip.
  void clearTrip(String tripId) {
    _items.removeWhere((i) => i.tripId == tripId);
  }

  /// Clears the entire queue.
  void clearAll() {
    _items.clear();
  }
}
