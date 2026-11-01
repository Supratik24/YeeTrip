import 'constants/categories.dart';
import 'money.dart';

/// Structured information extracted from a scanned or photographed receipt.
class ReceiptData {
  /// Extracted total amount in paise (never double).
  final int? amountPaise;

  /// Extracted business / merchant name.
  final String? merchantName;

  /// Extracted transaction or bill date.
  final DateTime? date;

  /// Suggested YeeTrip category matching [TripCategory.key].
  final String suggestedCategory;

  /// Confidence score between 0.0 and 1.0.
  final double confidence;

  /// Raw input text that was parsed.
  final String rawText;

  const ReceiptData({
    this.amountPaise,
    this.merchantName,
    this.date,
    this.suggestedCategory = 'Food',
    this.confidence = 0.0,
    required this.rawText,
  });

  ReceiptData copyWith({
    int? amountPaise,
    String? merchantName,
    DateTime? date,
    String? suggestedCategory,
    double? confidence,
    String? rawText,
  }) {
    return ReceiptData(
      amountPaise: amountPaise ?? this.amountPaise,
      merchantName: merchantName ?? this.merchantName,
      date: date ?? this.date,
      suggestedCategory: suggestedCategory ?? this.suggestedCategory,
      confidence: confidence ?? this.confidence,
      rawText: rawText ?? this.rawText,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptData &&
          runtimeType == other.runtimeType &&
          amountPaise == other.amountPaise &&
          merchantName == other.merchantName &&
          date == other.date &&
          suggestedCategory == other.suggestedCategory &&
          confidence == other.confidence &&
          rawText == other.rawText;

  @override
  int get hashCode => Object.hash(
        amountPaise,
        merchantName,
        date,
        suggestedCategory,
        confidence,
        rawText,
      );

  @override
  String toString() {
    return 'ReceiptData(merchant: $merchantName, amountPaise: $amountPaise, date: $date, category: $suggestedCategory, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}

/// Pure Dart parsing engine for Indian receipts, bills, and tax invoices.
class ReceiptParser {
  ReceiptParser._();

  static const List<String> _totalKeywords = [
    'grand total',
    'total amount',
    'net payable',
    'net amount',
    'amount payable',
    'bill total',
    'total due',
    'total bill',
    'total paid',
    'final total',
    'total',
    'amt payable',
    'subtotal',
    'sub total',
    'amount',
    'amt',
  ];

  static const List<String> _taxKeywords = [
    'cgst',
    'sgst',
    'igst',
    'vat',
    'tax',
    'service charge',
    'round off',
    'discount',
    'rate',
    'qty',
    'table',
    'gstin',
  ];

  static const List<String> _headerSkipKeywords = [
    'tax invoice',
    'retail invoice',
    'cash receipt',
    'estimate',
    'bill of supply',
    'order #',
    'invoice #',
    'bill #',
    'token #',
    'gstin',
    'gst no',
    'fssai',
    'pan no',
    'cin',
    'tel',
    'ph:',
    'mob',
    'phone',
    'contact',
    'email',
    'welcome',
    'thank you',
  ];

  /// Parses OCR/scanned text into structured [ReceiptData].
  static ReceiptData parse(String rawText) {
    if (rawText.trim().isEmpty) {
      return ReceiptData(
        rawText: rawText,
        confidence: 0.0,
        suggestedCategory: TripCategory.food.key,
      );
    }

    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final merchantName = _extractMerchant(lines);
    final (amountPaise, amountFoundOnExplicitTotal) = _extractAmount(lines);
    final date = _extractDate(lines);
    final category = _inferCategory(lines, merchantName);

    // Compute confidence
    double confidence = 0.0;
    if (amountPaise != null && amountPaise > 0) {
      confidence += amountFoundOnExplicitTotal ? 0.50 : 0.30;
    }
    if (date != null) {
      confidence += 0.20;
    }
    if (merchantName != null && merchantName.isNotEmpty) {
      confidence += 0.20;
    }
    if (category != TripCategory.buffer.key) {
      confidence += 0.10;
    }

    return ReceiptData(
      amountPaise: amountPaise,
      merchantName: merchantName,
      date: date,
      suggestedCategory: category,
      confidence: confidence.clamp(0.0, 1.0),
      rawText: rawText,
    );
  }

  /// Extracts the most likely business or merchant name from header lines.
  static String? _extractMerchant(List<String> lines) {
    for (final line in lines.take(6)) {
      final lower = line.toLowerCase();

      // Skip common non-merchant header lines
      if (_headerSkipKeywords.any((kw) => lower.contains(kw))) {
        continue;
      }

      // Skip lines that are purely dates or times or phone numbers or website/email
      if (RegExp(r'^[\d\s\-\/\:\,\.\+]+$').hasMatch(line)) {
        continue;
      }
      if (lower.contains('@') || lower.contains('.com') || lower.contains('www.')) {
        continue;
      }

      // Clean the candidate string
      final cleaned = line
          .replaceAll(RegExp(r'^[#\*\-=\.\s]+'), '')
          .replaceAll(RegExp(r'[#\*\-=\.\s]+$'), '')
          .trim();

      if (cleaned.length >= 3) {
        return cleaned;
      }
    }
    return null;
  }

  /// Extracts total amount in paise and indicates if found on an explicit total line.
  static (int? amountPaise, bool onExplicitTotal) _extractAmount(List<String> lines) {
    // 1. Scan for lines containing total keywords (highest priority)
    for (final keyword in _totalKeywords) {
      // Traverse backwards so later summary lines take priority over earlier lines
      for (int i = lines.length - 1; i >= 0; i--) {
        final line = lines[i];
        final lower = line.toLowerCase();

        if (lower.contains(keyword)) {
          // Check that this is not a tax breakdown line (e.g. CGST Total or SGST Rate)
          final isTaxLine = _taxKeywords.any(
            (taxKw) => lower.contains(taxKw) && !lower.contains('grand') && !lower.contains('payable'),
          );
          if (isTaxLine) continue;

          final paise = _findAmountInString(line);
          if (paise != null && paise > 0) {
            return (paise, true);
          }
        }
      }
    }

    // 2. Fallback: inspect the last 10 lines for any rupee amount formatted cleanly
    for (int i = lines.length - 1; i >= (lines.length - 10).clamp(0, lines.length); i--) {
      final line = lines[i];
      final lower = line.toLowerCase();

      // Avoid tax/item number lines
      if (_taxKeywords.any((taxKw) => lower.contains(taxKw))) continue;

      final paise = _findAmountInString(line);
      if (paise != null && paise > 0) {
        return (paise, false);
      }
    }

    return (null, false);
  }

  /// Extracts numeric currency value from a string and converts to paise.
  static int? _findAmountInString(String text) {
    // Matches patterns like:
    // ₹ 1,450.50
    // Rs. 2500.00
    // 1,280.00
    // 950/-
    final patterns = [
      RegExp(r'(?:₹|Rs\.?|INR)\s*([0-9][0-9,]*(?:\.[0-9]{1,2})?)', caseSensitive: false),
      RegExp(r'\b([0-9][0-9,]*(?:\.[0-9]{2}))\b'),
      RegExp(r'\b([0-9][0-9,]*)\s*/-'),
      RegExp(r'\b([0-9]{2,7}\.[0-9]{2})\b'),
      RegExp(r'\b([0-9]{2,6})\b'),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      // Take the last match on the line, as amounts are typically placed on the right
      if (matches.isNotEmpty) {
        final match = matches.last;
        final rawNum = match.group(1) ?? match.group(0);
        if (rawNum != null) {
          try {
            final paise = Money.decimalStringToPaise(rawNum);
            // Basic sanity bounds (10 paise to 50 lakh rupees)
            if (paise >= 10 && paise <= 500000000) {
              return paise;
            }
          } catch (_) {
            // Ignore parse errors from regex fragments
          }
        }
      }
    }
    return null;
  }

  /// Extracts date from receipt text lines.
  static DateTime? _extractDate(List<String> lines) {
    // Pattern 1: DD/MM/YYYY or DD-MM-YYYY or DD.MM.YYYY
    final numericPattern = RegExp(r'\b([0-3]?[0-9])[\/\-\.]([0-1]?[0-9])[\/\-\.](20\d{2}|\d{2})\b');

    // Pattern 2: DD Mon YYYY (e.g. 15 Oct 2026 or 05-Nov-26)
    final textPattern = RegExp(
      r'\b([0-3]?[0-9])[\s\-\/\.](Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*[\s\-\/\.](20\d{2}|\d{2})\b',
      caseSensitive: false,
    );

    // Pattern 3: YYYY-MM-DD
    final isoPattern = RegExp(r'\b(20\d{2})[\/\-\.]([0-1]?[0-9])[\/\-\.]([0-3]?[0-9])\b');

    const monthMap = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };

    for (final line in lines) {
      // Check ISO pattern first
      final isoMatch = isoPattern.firstMatch(line);
      if (isoMatch != null) {
        final year = int.parse(isoMatch.group(1)!);
        final month = int.parse(isoMatch.group(2)!);
        final day = int.parse(isoMatch.group(3)!);
        if (_isValidDate(year, month, day)) {
          return DateTime(year, month, day);
        }
      }

      // Check text pattern (e.g. 15 Oct 2026)
      final textMatch = textPattern.firstMatch(line);
      if (textMatch != null) {
        final day = int.parse(textMatch.group(1)!);
        final monthStr = textMatch.group(2)!.toLowerCase();
        final month = monthMap[monthStr.substring(0, 3)] ?? 1;
        var year = int.parse(textMatch.group(3)!);
        if (year < 100) year += 2000;
        if (_isValidDate(year, month, day)) {
          return DateTime(year, month, day);
        }
      }

      // Check numeric pattern (DD/MM/YYYY)
      final numMatch = numericPattern.firstMatch(line);
      if (numMatch != null) {
        final day = int.parse(numMatch.group(1)!);
        final month = int.parse(numMatch.group(2)!);
        var year = int.parse(numMatch.group(3)!);
        if (year < 100) year += 2000;
        if (_isValidDate(year, month, day)) {
          return DateTime(year, month, day);
        }
      }
    }

    return null;
  }

  static bool _isValidDate(int year, int month, int day) {
    if (year < 2000 || year > 2100) return false;
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    return true;
  }

  /// Infers one of YeeTrip's 6 category keys from receipt content.
  static String _inferCategory(List<String> lines, String? merchantName) {
    // 1. First inspect the merchant name specifically, if available
    if (merchantName != null && merchantName.isNotEmpty) {
      final merchantLower = merchantName.toLowerCase();
      if (['dmart', 'mart', 'supermarket', 'retail', 'decathlon', 'bazaar', 'store', 'shop'].any((kw) => merchantLower.contains(kw))) {
        return TripCategory.shopping.key;
      }
      if (['hotel', 'resort', 'inn', 'suites', 'homestay', 'lodge', 'oyo', 'airbnb', 'villa'].any((kw) => merchantLower.contains(kw))) {
        return TripCategory.stay.key;
      }
      if (['petrol', 'petroleum', 'fuel', 'diesel', 'hpcl', 'bpcl', 'iocl', 'uber', 'ola', 'cab', 'taxi'].any((kw) => merchantLower.contains(kw))) {
        return TripCategory.transport.key;
      }
      if (['water sports', 'scuba', 'safari', 'adventure', 'museum', 'tour', 'park'].any((kw) => merchantLower.contains(kw))) {
        return TripCategory.activities.key;
      }
      if (['restaurant', 'cafe', 'kitchen', 'dhaba', 'bar', 'bistro', 'bakery', 'biryani', 'grill', 'diner'].any((kw) => merchantLower.contains(kw))) {
        return TripCategory.food.key;
      }
    }

    final fullText = '${merchantName ?? ""} ${lines.join(" ")}'.toLowerCase();

    // Food
    const foodKeywords = [
      'restaurant', 'cafe', 'kitchen', 'dhaba', 'bar', 'food', 'bites',
      'bakery', 'biryani', 'burger', 'pizza', 'swiggy', 'zomato', 'chai',
      'tea', 'coffee', 'ice cream', 'dining', 'sweets', 'hotel & restaurant',
      'tandoori', 'curry', 'grill', 'bistro', 'diner', 'canteen', 'pub',
      'shake', 'juice', 'dessert', 'meals', 'snack', 'thali',
    ];
    if (foodKeywords.any((kw) => fullText.contains(kw))) {
      return TripCategory.food.key;
    }

    // Transport
    const transportKeywords = [
      'petrol', 'fuel', 'diesel', 'hpcl', 'bpcl', 'iocl', 'uber', 'ola',
      'rapido', 'toll', 'fastag', 'taxi', 'auto', 'cab', 'parking',
      'railway', 'irctc', 'flight', 'indigo', 'air india', 'bus', 'fare',
      'gas station', 'transport', 'ticket', 'train',
    ];
    if (transportKeywords.any((kw) => fullText.contains(kw))) {
      return TripCategory.transport.key;
    }

    // Stay
    const stayKeywords = [
      'hotel', 'resort', 'inn', 'suites', 'homestay', 'room', 'lodge',
      'oyo', 'airbnb', 'stay', 'villa', 'hostel', 'cottage', 'check in',
      'check out', 'room service', 'accommodation',
    ];
    if (stayKeywords.any((kw) => fullText.contains(kw))) {
      return TripCategory.stay.key;
    }

    // Activities
    const activityKeywords = [
      'entry', 'ticket', 'museum', 'safari', 'park', 'tour', 'guide',
      'scuba', 'beach', 'boat', 'water sports', 'cinema', 'movie',
      'theatre', 'adventure', 'trek', 'amusement', 'monument', 'temple',
    ];
    if (activityKeywords.any((kw) => fullText.contains(kw))) {
      return TripCategory.activities.key;
    }

    // Shopping
    const shoppingKeywords = [
      'mart', 'store', 'supermarket', 'bazaar', 'decathlon', 'retail',
      'mall', 'clothing', 'apparel', 'footwear', 'gift', 'souvenir',
      'dmart', 'reliance', 'shop', 'fashion', 'handicrafts',
    ];
    if (shoppingKeywords.any((kw) => fullText.contains(kw))) {
      return TripCategory.shopping.key;
    }

    // Default to Food if unclear, or Buffer if completely ambiguous
    return TripCategory.food.key;
  }
}
