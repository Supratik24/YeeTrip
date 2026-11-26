import '../../../../core/money.dart';
import '../../../../core/receipt_parser.dart';

/// Pure Dart split calculation and validation engine.
///
/// NON-NEGOTIABLE RULES:
/// 1. Business logic lives in pure Dart functions with NO Flutter imports.
/// 2. Splits for an expense must always sum EXACTLY to the expense amount in paise.
/// 3. Largest-remainder method used for percentages and shares.
class SplitCalculator {
  SplitCalculator._();

  /// Calculates equal split among [travelerIds].
  ///
  /// Leftover paise (amount % n) are distributed one each to the first travelers
  /// in fixed order (sorted by traveler ID) so shares sum exactly to [totalPaise].
  ///
  /// Example: ₹100 (10000 paise) among 3 -> 3334, 3333, 3333 paise.
  static Map<String, int> calculateEqualSplit({
    required int totalPaise,
    required List<String> travelerIds,
  }) {
    if (travelerIds.isEmpty) {
      throw ArgumentError('At least one traveler is required for equal split');
    }
    if (totalPaise < 0) {
      throw ArgumentError('Total amount cannot be negative');
    }

    // Sort travelers in fixed deterministic order by ID
    final sortedIds = List<String>.from(travelerIds)..sort();
    final n = sortedIds.length;
    final baseShare = totalPaise ~/ n;
    final remainder = totalPaise % n;

    final result = <String, int>{};
    for (int i = 0; i < n; i++) {
      result[sortedIds[i]] = baseShare + (i < remainder ? 1 : 0);
    }

    assert(
      result.values.fold<int>(0, (s, v) => s + v) == totalPaise,
      'Equal split must sum to totalPaise',
    );
    return result;
  }

  /// Calculates percentage split using the largest-remainder method.
  ///
  /// [percentages] contains the percentage (as integer or double) for each traveler ID.
  /// The sum of percentages should equal 100.
  static Map<String, int> calculatePercentageSplit({
    required int totalPaise,
    required Map<String, num> percentages,
  }) {
    if (percentages.isEmpty) {
      throw ArgumentError('Percentages cannot be empty');
    }
    if (totalPaise < 0) {
      throw ArgumentError('Total amount cannot be negative');
    }

    final sortedKeys = List<String>.from(percentages.keys)..sort();

    final floorShares = <String, int>{};
    final remainders = <String, double>{};
    var floorSum = 0;

    for (final id in sortedKeys) {
      final p = percentages[id] ?? 0;
      // Exact share in paise: (totalPaise * p) / 100
      final exactPaise = (totalPaise * p) / 100.0;
      final floorVal = exactPaise.floor();
      final rem = exactPaise - floorVal;

      floorShares[id] = floorVal;
      remainders[id] = rem;
      floorSum += floorVal;
    }

    var leftoverPaise = totalPaise - floorSum;

    // Distribute leftover paise to travelers with the largest remainders
    final rankedKeys = List<String>.from(sortedKeys)
      ..sort((a, b) {
        final remCmp = remainders[b]!.compareTo(remainders[a]!);
        if (remCmp != 0) return remCmp;
        return a.compareTo(b); // Deterministic tie-breaker
      });

    final result = Map<String, int>.from(floorShares);
    for (int i = 0; i < leftoverPaise && i < rankedKeys.length; i++) {
      final id = rankedKeys[i];
      result[id] = result[id]! + 1;
    }

    assert(
      result.values.fold<int>(0, (s, v) => s + v) == totalPaise,
      'Percentage split must sum to totalPaise',
    );
    return result;
  }

  /// Calculates shares (weights) split using the largest-remainder method.
  ///
  /// [weights] contains integer weights (e.g. 1, 2, 3) for each traveler ID.
  static Map<String, int> calculateSharesSplit({
    required int totalPaise,
    required Map<String, int> weights,
  }) {
    if (weights.isEmpty) {
      throw ArgumentError('Weights cannot be empty');
    }
    if (totalPaise < 0) {
      throw ArgumentError('Total amount cannot be negative');
    }

    final totalWeight = weights.values.fold<int>(0, (sum, w) => sum + w);
    if (totalWeight <= 0) {
      throw ArgumentError('Total weight must be positive');
    }

    final sortedKeys = List<String>.from(weights.keys)..sort();

    final floorShares = <String, int>{};
    final remainders = <String, int>{};
    var floorSum = 0;

    for (final id in sortedKeys) {
      final w = weights[id] ?? 0;
      final scaled = totalPaise * w;
      final floorVal = scaled ~/ totalWeight;
      final rem = scaled % totalWeight;

      floorShares[id] = floorVal;
      remainders[id] = rem;
      floorSum += floorVal;
    }

    var leftoverPaise = totalPaise - floorSum;

    // Distribute leftover paise to travelers with the largest remainder
    final rankedKeys = List<String>.from(sortedKeys)
      ..sort((a, b) {
        final remCmp = remainders[b]!.compareTo(remainders[a]!);
        if (remCmp != 0) return remCmp;
        return a.compareTo(b);
      });

    final result = Map<String, int>.from(floorShares);
    for (int i = 0; i < leftoverPaise && i < rankedKeys.length; i++) {
      final id = rankedKeys[i];
      result[id] = result[id]! + 1;
    }

    assert(
      result.values.fold<int>(0, (s, v) => s + v) == totalPaise,
      'Shares split must sum to totalPaise',
    );
    return result;
  }

  /// Validates an exact-amount split.
  ///
  /// Returns null if valid, or a clear error message describing the difference.
  static String? validateExactSplit({
    required int totalPaise,
    required Map<String, int> exactSharesPaise,
    String currencyCode = 'INR',
  }) {
    if (exactSharesPaise.values.any((s) => s < 0)) {
      return 'Individual shares cannot be negative';
    }

    final sumPaise = exactSharesPaise.values.fold<int>(0, (s, v) => s + v);
    if (sumPaise != totalPaise) {
      final diff = (totalPaise - sumPaise).abs();
      final diffFormatted = Money.formatAmount(diff, currencyCode: currencyCode);
      final sumFormatted = Money.formatAmount(sumPaise, currencyCode: currencyCode);
      final totalFormatted = Money.formatAmount(totalPaise, currencyCode: currencyCode);

      if (sumPaise < totalPaise) {
        return 'Shares sum to $sumFormatted, which is $diffFormatted short of $totalFormatted';
      } else {
        return 'Shares sum to $sumFormatted, which is $diffFormatted more than $totalFormatted';
      }
    }

    return null;
  }

  /// Calculates an itemized bill split by assigning each line item to one or more travelers.
  ///
  /// - Assigned non-tax items are split equally among their assigned travelers.
  /// - Any positive remainder (taxes, GST, service charge, tip, round-off, or
  ///   unassigned fee items) is distributed proportionally to each traveler's
  ///   itemized subtotal using the largest-remainder method.
  /// - If a discount makes [totalPaise] smaller than the itemized subtotal,
  ///   shares are scaled down proportionally so the sum ALWAYS equals [totalPaise].
  static Map<String, int> calculateItemizedSplit({
    required int totalPaise,
    required List<ReceiptLineItem> items,
    required Map<String, Set<String>> itemAssignees,
    required List<String> allTravelerIds,
  }) {
    if (totalPaise < 0) {
      throw ArgumentError('Total amount cannot be negative');
    }
    if (allTravelerIds.isEmpty) {
      throw ArgumentError('At least one traveler is required');
    }

    final splitableItems = items.where((i) => !i.isTaxOrFee).toList();
    if (splitableItems.isEmpty) {
      throw ArgumentError('Add at least one bill item to split by items');
    }

    final subtotalByTraveler = <String, int>{
      for (final id in allTravelerIds) id: 0,
    };

    var assignedSum = 0;
    for (final item in splitableItems) {
      if (item.amountPaise <= 0) {
        throw ArgumentError('Item "${item.name}" must have a positive amount');
      }
      final assignees = (itemAssignees[item.id] ?? const <String>{})
          .where((id) => subtotalByTraveler.containsKey(id))
          .toList();
      if (assignees.isEmpty) {
        throw ArgumentError(
          'Assign "${item.name}" to at least one traveler',
        );
      }
      final itemSplits = calculateEqualSplit(
        totalPaise: item.amountPaise,
        travelerIds: assignees,
      );
      for (final entry in itemSplits.entries) {
        subtotalByTraveler[entry.key] =
            (subtotalByTraveler[entry.key] ?? 0) + entry.value;
      }
      assignedSum += item.amountPaise;
    }

    if (totalPaise == 0) {
      return subtotalByTraveler.map((k, _) => MapEntry(k, 0));
    }

    if (assignedSum == totalPaise) {
      assert(
        subtotalByTraveler.values.fold<int>(0, (s, v) => s + v) == totalPaise,
      );
      return subtotalByTraveler;
    }

    // If subtotal exceeds total (e.g., coupon/discount), scale down proportionally.
    if (assignedSum > totalPaise) {
      final positiveWeights = <String, int>{
        for (final entry in subtotalByTraveler.entries)
          if (entry.value > 0) entry.key: entry.value,
      };
      final scaled = calculateSharesSplit(
        totalPaise: totalPaise,
        weights: positiveWeights.isNotEmpty
            ? positiveWeights
            : {for (final id in allTravelerIds) id: 1},
      );
      return {
        for (final id in allTravelerIds) id: scaled[id] ?? 0,
      };
    }

    // Otherwise distribute remaining taxes/fees/tip/unassigned delta proportionally.
    final taxAndFeeDelta = totalPaise - assignedSum;
    final positiveWeights = <String, int>{
      for (final entry in subtotalByTraveler.entries)
        if (entry.value > 0) entry.key: entry.value,
    };
    final distributedDelta = calculateSharesSplit(
      totalPaise: taxAndFeeDelta,
      weights: positiveWeights.isNotEmpty
          ? positiveWeights
          : {for (final id in allTravelerIds) id: 1},
    );

    final result = <String, int>{
      for (final id in allTravelerIds)
        id: (subtotalByTraveler[id] ?? 0) + (distributedDelta[id] ?? 0),
    };

    assert(
      result.values.fold<int>(0, (s, v) => s + v) == totalPaise,
      'Itemized split must sum exactly to totalPaise',
    );
    return result;
  }
}
