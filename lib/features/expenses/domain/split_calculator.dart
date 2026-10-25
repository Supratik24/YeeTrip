import '../../../../core/money.dart';

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
  }) {
    if (exactSharesPaise.values.any((s) => s < 0)) {
      return 'Individual shares cannot be negative';
    }

    final sumPaise = exactSharesPaise.values.fold<int>(0, (s, v) => s + v);
    if (sumPaise != totalPaise) {
      final diff = (totalPaise - sumPaise).abs();
      final diffFormatted = Money.formatRupees(diff);
      final sumFormatted = Money.formatRupees(sumPaise);
      final totalFormatted = Money.formatRupees(totalPaise);

      if (sumPaise < totalPaise) {
        return 'Shares sum to $sumFormatted, which is $diffFormatted short of $totalFormatted';
      } else {
        return 'Shares sum to $sumFormatted, which is $diffFormatted more than $totalFormatted';
      }
    }

    return null;
  }
}
