import 'constants/currencies.dart';

/// Pure Dart money utilities for YeeTrip.
///
/// NON-NEGOTIABLE RULES:
/// 1. All money is stored and calculated as integer minor units (e.g. paise/cents). Never use double for accounting sums.
/// 2. Display INR amounts in Indian numbering grouping (e.g. ₹1,25,000 and ₹2,400.50),
///    and foreign currencies in standard international 3-digit grouping (e.g. $125,000).
class Money {
  Money._();

  /// Returns the symbol for a currency code (defaults to ₹ for INR).
  static String symbolFor(String currencyCode) {
    return TripCurrency.fromCode(currencyCode).symbol;
  }

  /// Converts integer minor units (paise/cents) to a standard decimal string (e.g., 240050 -> "2400.50", 5 -> "0.05").
  static String paiseToDecimalString(int paise) {
    final isNegative = paise < 0;
    final absPaise = paise.abs();
    final rupees = absPaise ~/ 100;
    final p = absPaise % 100;
    final sign = isNegative ? '-' : '';
    final paiseStr = p.toString().padLeft(2, '0');
    return '$sign$rupees.$paiseStr';
  }

  /// Parses a decimal string into integer minor units (1 unit = 100 minor units).
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

    return rupees * 100 + paise;
  }

  /// Converts an amount in [sourceMinorUnits] using [exchangeRate] into integer target minor units.
  static int convertAmount(int sourceMinorUnits, {required double exchangeRate}) {
    if (exchangeRate <= 0) {
      throw ArgumentError('Exchange rate must be greater than zero');
    }
    return (sourceMinorUnits * exchangeRate).round();
  }

  /// Formats integer minor units according to [currencyCode] (default `INR`).
  static String formatAmount(
    int minorUnits, {
    String currencyCode = 'INR',
    bool alwaysShowDecimals = false,
    bool includeSymbol = true,
  }) {
    final currency = TripCurrency.fromCode(currencyCode);
    final isNegative = minorUnits < 0;
    final absUnits = minorUnits.abs();
    final major = absUnits ~/ 100;
    final minor = absUnits % 100;

    final formattedMajor = currency.usesIndianGrouping
        ? _formatIndianGrouping(major)
        : _formatWesternGrouping(major);

    final sign = isNegative ? '-' : '';
    final sym = includeSymbol ? currency.symbol : '';

    if (alwaysShowDecimals || minor != 0) {
      final minorStr = minor.toString().padLeft(2, '0');
      return '$sign$sym$formattedMajor.$minorStr';
    } else {
      return '$sign$sym$formattedMajor';
    }
  }

  /// Formats integer paise in the Indian numbering system with ₹ symbol (or custom [currencyCode]).
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
    String currencyCode = 'INR',
  }) {
    return formatAmount(
      paise,
      currencyCode: currencyCode,
      alwaysShowDecimals: alwaysShowPaise,
      includeSymbol: includeSymbol,
    );
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

  /// Formats an integer using standard 3-digit Western grouping: e.g. 1000000 -> "1,000,000".
  static String _formatWesternGrouping(int number) {
    final str = number.toString();
    if (str.length <= 3) {
      return str;
    }

    final parts = <String>[];
    var current = str;
    while (current.length > 3) {
      parts.insert(0, current.substring(current.length - 3));
      current = current.substring(0, current.length - 3);
    }
    if (current.isNotEmpty) {
      parts.insert(0, current);
    }
    return parts.join(',');
  }
}
