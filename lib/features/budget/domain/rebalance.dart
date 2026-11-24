import '../../../core/constants/categories.dart';

/// Pure Dart budget allocation rebalancing logic.
///
/// RULES:
/// 1. Sliders always total exactly 100.
/// 2. When one slider changes, scale others proportionally to fill the remainder.
/// 3. If others were all 0, spread remainder equally.
/// 4. Round to integers, then put any rounding difference on the largest other category.
/// 5. Never make any value negative.
/// 6. All categories are normalized to canonical [TripCategory.all] keys.
class BudgetRebalancer {
  BudgetRebalancer._();

  /// Normalizes any allocations map to strictly contain all 6 canonical
  /// [TripCategory.key] keys with case-insensitive matching.
  static Map<String, int> normalizeAllocations(Map<String, int> allocations) {
    final normalized = <String, int>{};
    for (final cat in TripCategory.all) {
      normalized[cat.key] = cat.defaultPercent;
    }
    for (final entry in allocations.entries) {
      final canonicalCat = TripCategory.fromKey(entry.key);
      normalized[canonicalCat.key] = entry.value;
    }
    return normalized;
  }

  /// Rebalances allocations when [changedCategory] changes to [newPercent].
  static Map<String, int> rebalance({
    required Map<String, int> currentAllocations,
    required String changedCategory,
    required int newPercent,
  }) {
    final canonicalChanged = TripCategory.fromKey(changedCategory).key;
    final normalizedCurrent = normalizeAllocations(currentAllocations);

    // 1. Clamp newPercent between 0 and 100
    final targetPercent = newPercent.clamp(0, 100);

    final otherKeys = TripCategory.all
        .map((c) => c.key)
        .where((k) => k != canonicalChanged)
        .toList();

    // If there are no other categories, the changed category takes 100%
    if (otherKeys.isEmpty) {
      return {canonicalChanged: 100};
    }

    final remainder = 100 - targetPercent;

    // Edge case: target is 100 -> all others are 0
    if (remainder == 0) {
      final result = <String, int>{canonicalChanged: 100};
      for (final k in otherKeys) {
        result[k] = 0;
      }
      return result;
    }

    final oldOthersSum = otherKeys.fold<int>(
      0,
      (sum, k) => sum + (normalizedCurrent[k] ?? 0),
    );

    final newAllocations = <String, int>{};

    if (oldOthersSum == 0) {
      // If the others were all 0, spread the remainder equally.
      final baseShare = remainder ~/ otherKeys.length;
      final diff = remainder - (baseShare * otherKeys.length);

      for (int i = 0; i < otherKeys.length; i++) {
        // Distribute the small rounding difference to the first categories
        final extra = i < diff ? 1 : 0;
        newAllocations[otherKeys[i]] = baseShare + extra;
      }
    } else {
      // Scale others proportionally to fill the remainder
      for (final k in otherKeys) {
        final oldVal = normalizedCurrent[k] ?? 0;
        final scaled = ((oldVal * remainder) / oldOthersSum).round();
        newAllocations[k] = scaled.clamp(0, 100);
      }

      // Check sum and apply rounding difference
      final currentScaledSum =
          newAllocations.values.fold<int>(0, (sum, v) => sum + v);
      var diff = remainder - currentScaledSum;

      if (diff != 0) {
        // Sort others by their current allocation descending to find the largest
        final sortedKeys = List<String>.from(otherKeys)
          ..sort((a, b) => newAllocations[b]!.compareTo(newAllocations[a]!));

        if (diff > 0) {
          // Add difference to the largest category
          final largest = sortedKeys.first;
          newAllocations[largest] = newAllocations[largest]! + diff;
        } else {
          // diff < 0: Subtract difference from largest without making negative
          var remainingToSubtract = -diff;
          for (final key in sortedKeys) {
            final currentVal = newAllocations[key]!;
            final deduct = currentVal >= remainingToSubtract
                ? remainingToSubtract
                : currentVal;
            newAllocations[key] = currentVal - deduct;
            remainingToSubtract -= deduct;
            if (remainingToSubtract == 0) break;
          }
        }
      }
    }

    newAllocations[canonicalChanged] = targetPercent;

    // Safety assert: sum must be exactly 100 and no values negative
    assert(
      newAllocations.values.fold<int>(0, (s, v) => s + v) == 100,
      'Allocations sum must be 100',
    );
    assert(
      newAllocations.values.every((v) => v >= 0),
      'Allocations cannot be negative',
    );

    return newAllocations;
  }
}
