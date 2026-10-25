/// Pure Dart money utilities for YeeTrip.
///
/// NON-NEGOTIABLE RULES:
/// 1. All money is stored and calculated as integer paise. Never use double.
/// 2. Display amounts in Indian numbering grouping (e.g. ₹1,25,000 and ₹2,400.50).
class Money {
  Money._();

  /// Converts integer paise to a standard decimal string (e.g., 240050 -> "2400.50", 5 -> "0.05").
  static String paiseToDecimalString(int paise) {
    final isNegative = paise < 0;
    final absPaise = paise.abs();
    final rupees = absPaise ~/ 100;
    final p = absPaise % 100;
    final sign = isNegative ? '-' : '';
    final paiseStr = p.toString().padLeft(2, '0');
    return '$sign$rupees.$paiseStr';
  }

  /// Parses a decimal string (in rupees) into integer paise.
  ///
  /// Accepts:
  /// - "2400" -> 240000
  /// - "2,400.5" -> 240050
  /// - "2400.50" -> 240050
  /// - "0" -> 0
  /// - "0.05" -> 5
  ///
  /// Rejects (throws [FormatException]):
  /// - Negatives (e.g., "-2400", "-0.5")
  /// - More than 2 decimal places (e.g., "2400.505")
  /// - Letters or invalid symbols (e.g., "abc", "₹2400")
  /// - Multiple decimals or empty strings
  static int decimalStringToPaise(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Amount cannot be empty');
    }

    if (trimmed.startsWith('-')) {
      throw const FormatException('Negative amounts are not allowed');
    }

    // Strip Indian/Western commas
    final clean = trimmed.replaceAll(',', '');

    // Check for negative sign after removing commas
    if (clean.contains('-')) {
      throw const FormatException('Negative amounts are not allowed');
    }

    // Match digits optionally followed by dot and 0-2 digits
    final regex = RegExp(r'^(\d+)(\.(\d*))?$');
    final match = regex.firstMatch(clean);
    if (match == null) {
      throw FormatException('Invalid amount format: "$input"');
    }

    final rupeesPart = match.group(1)!;
    final decimalPart = match.group(3) ?? '';

    if (decimalPart.length > 2) {
      throw const FormatException('Cannot have more than 2 decimal places');
    }

    final rupees = int.parse(rupeesPart);
    final paise = decimalPart.isEmpty
        ? 0
        : (decimalPart.length == 1
            ? int.parse(decimalPart) * 10
            : int.parse(decimalPart));

    // Guard against integer overflow
    return rupees * 100 + paise;
  }

  /// Formats integer paise in the Indian numbering system with ₹ symbol.
  ///
  /// Examples:
  /// - 12500000 paise -> "₹1,25,000"
  /// - 240050 paise   -> "₹2,400.50"
  /// - 240000 paise with [alwaysShowPaise] true -> "₹2,400.00"
  /// - -240050 paise  -> "-₹2,400.50"
  static String formatRupees(
    int paise, {
    bool alwaysShowPaise = false,
    bool includeSymbol = true,
  }) {
    final isNegative = paise < 0;
    final absPaise = paise.abs();
    final rupees = absPaise ~/ 100;
    final p = absPaise % 100;

    final formattedRupees = _formatIndianGrouping(rupees);
    final sign = isNegative ? '-' : '';
    final sym = includeSymbol ? '₹' : '';

    if (alwaysShowPaise || p != 0) {
      final paiseStr = p.toString().padLeft(2, '0');
      return '$sign$sym$formattedRupees.$paiseStr';
    } else {
      return '$sign$sym$formattedRupees';
    }
  }

  /// Formats an integer using Indian numbering grouping:
  /// The rightmost 3 digits form the first group, then groups of 2 digits.
  /// e.g. 1000000 -> "10,00,000"
  static String _formatIndianGrouping(int number) {
    final str = number.toString();
    if (str.length <= 3) {
      return str;
    }

    // Last 3 digits
    final last3 = str.substring(str.length - 3);
    final remaining = str.substring(0, str.length - 3);

    // Group remaining into pairs of 2 from right to left
    final parts = <String>[];
    var current = remaining;
    while (current.length > 2) {
      parts.insert(0, current.substring(current.length - 2));
      current = current.substring(0, current.length - 2);
    }
    if (current.isNotEmpty) {
      parts.insert(0, current);
    }

    return '${parts.join(',')},$last3';
  }
}
