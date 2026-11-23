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

  /// All distinct valid currency amounts detected on the receipt (in paise), sorted descending.
  final List<int> candidateAmountsPaise;

  /// Detected item lines or description.
  final List<String> items;

  /// Optional parser notes or status explanations.
  final String? notes;

  const ReceiptData({
    this.amountPaise,
    this.merchantName,
    this.date,
    this.suggestedCategory = 'Food',
    this.confidence = 0.0,
    required this.rawText,
    this.candidateAmountsPaise = const [],
    this.items = const [],
    this.notes,
  });

  ReceiptData copyWith({
    int? amountPaise,
    String? merchantName,
    DateTime? date,
    String? suggestedCategory,
    double? confidence,
    String? rawText,
    List<int>? candidateAmountsPaise,
    List<String>? items,
    String? notes,
  }) {
    return ReceiptData(
      amountPaise: amountPaise ?? this.amountPaise,
      merchantName: merchantName ?? this.merchantName,
      date: date ?? this.date,
      suggestedCategory: suggestedCategory ?? this.suggestedCategory,
      confidence: confidence ?? this.confidence,
      rawText: rawText ?? this.rawText,
      candidateAmountsPaise: candidateAmountsPaise ?? this.candidateAmountsPaise,
      items: items ?? this.items,
      notes: notes ?? this.notes,
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
          rawText == other.rawText &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(
        amountPaise,
        merchantName,
        date,
        suggestedCategory,
        confidence,
        rawText,
        notes,
      );

  @override
  String toString() {
    return 'ReceiptData(merchant: $merchantName, amountPaise: $amountPaise, date: $date, category: $suggestedCategory, candidates: ${candidateAmountsPaise.length}, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}

/// Pure Dart parsing engine for Indian receipts, bills, and tax invoices.
class ReceiptParser {
  ReceiptParser._();

  static const List<List<String>> _totalKeywordTiers = [
    // Tier 1: Highest priority explicit grand total / final payable
    [
      'grand total',
      'net payable',
      'amount payable',
      'net amount',
      'final total',
      'bill total',
      'total due',
      'total paid',
      'total sale',
      'amount paid',
      'paid amount',
      'net total',
      'invoice total',
      'total charge',
      'upi paid',
      'cash paid',
      'card paid',
      'paid via upi',
    ],
    // Tier 2: General total phrases
    [
      'total amount',
      'total bill',
      'total inr',
      'total rs',
      'amt payable',
      'bill amt',
      'balance due',
      'total',
      'amt',
      'amount',
    ],
    // Tier 3: Subtotal fallback
    [
      'subtotal',
      'sub total',
      'sub-total',
    ],
  ];

  static const List<String> _taxKeywords = [
    'cgst',
    'sgst',
    'igst',
    'vat',
    'service charge',
    'service tax',
    'round off',
    'discount',
    'gstin',
    'gst no',
    'fssai',
    'table #',
    'order #',
    'invoice #',
  ];

  static const List<String> _headerSkipKeywords = [
    'tax invoice',
    'retail invoice',
    'cash receipt',
    'cash memo',
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
    'original copy',
    'duplicate copy',
    'customer copy',
    'merchant copy',
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
    final candidateAmounts = _extractAllCandidateAmounts(lines);
    if (amountPaise != null && !candidateAmounts.contains(amountPaise)) {
      candidateAmounts.insert(0, amountPaise);
    }
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
      candidateAmountsPaise: candidateAmounts,
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

  static bool _isItemCountLine(String lower) {
    if (lower.contains('total item') ||
        lower.contains('total qty') ||
        lower.contains('total pcs') ||
        lower.contains('total count') ||
        lower.contains('items count') ||
        lower.contains('total quantity')) {
      if (!lower.contains('₹') && !lower.contains('rs') && !lower.contains('inr') && !lower.contains('.')) {
        return true;
      }
    }
    return false;
  }

  /// Extracts total amount in paise and indicates if found on an explicit total line.
  static (int? amountPaise, bool onExplicitTotal) _extractAmount(List<String> lines) {
    // 1. Scan tiered keywords (Tier 1 explicit grand totals -> Tier 2 totals -> Tier 3 subtotal)
    for (final tier in _totalKeywordTiers) {
      for (final keyword in tier) {
        // Traverse backwards so later summary lines take priority over earlier lines
        for (int i = lines.length - 1; i >= 0; i--) {
          final line = lines[i];
          final lower = line.toLowerCase();

          if (lower.contains(keyword)) {
            // Ignore item-count lines like "TOTAL ITEMS: 15"
            if (_isItemCountLine(lower)) continue;

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
    }

    // 2. Fallback: inspect the last 10 lines for any rupee amount formatted cleanly
    for (int i = lines.length - 1; i >= (lines.length - 10).clamp(0, lines.length); i--) {
      final line = lines[i];
      final lower = line.toLowerCase();

      // Avoid tax/item number lines
      if (_taxKeywords.any((taxKw) => lower.contains(taxKw))) continue;
      if (_isItemCountLine(lower)) continue;

      final paise = _findAmountInString(line);
      if (paise != null && paise > 0) {
        return (paise, false);
      }
    }

    return (null, false);
  }

  /// Extracts numeric currency value from a string and converts to paise.
  static int? _findAmountInString(String text) {
    // 1. Strip item count / quantity fragments so numbers like "items: 4" don't become ₹4
    var cleaned = text.replaceAll(
      RegExp(r'\b(?:items?|qty|quantity|pcs|pieces|count)\s*[:\-]?\s*\d+\b', caseSensitive: false),
      ' ',
    );

    // 2. Strip phone numbers (10 digits starting with 6-9)
    cleaned = cleaned.replaceAll(RegExp(r'\b[6-9]\d{9}\b'), ' ');

    // 3. Strip dates (DD/MM/YYYY or YYYY-MM-DD)
    cleaned = cleaned.replaceAll(RegExp(r'\b\d{1,4}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4}\b'), ' ');

    // 4. Strip times (e.g. 14:30 or 20:45:10)
    cleaned = cleaned.replaceAll(RegExp(r'\b\d{1,2}:\d{2}(?::\d{2})?\b'), ' ');

    // Priority 1: Currency symbols (₹, Rs, INR)
    final currencyPattern = RegExp(
      r'(?:₹|Rs\.?|INR)\s*([0-9][0-9,]*(?:\.[0-9]{1,2})?)',
      caseSensitive: false,
    );
    final currencyMatches = currencyPattern.allMatches(cleaned);
    if (currencyMatches.isNotEmpty) {
      final rawNum = currencyMatches.last.group(1);
      if (rawNum != null) {
        try {
          final paise = Money.decimalStringToPaise(rawNum);
          if (paise >= 10 && paise <= 500000000) return paise;
        } catch (_) {}
      }
    }

    // Priority 2: Decimal currency values (e.g. 1,480.00 or 250.50)
    final decimalPattern = RegExp(r'\b([0-9]{1,3}(?:,[0-9]{2,3})*\.[0-9]{2})\b');
    final decimalMatches = decimalPattern.allMatches(cleaned);
    if (decimalMatches.isNotEmpty) {
      final rawNum = decimalMatches.last.group(1);
      if (rawNum != null) {
        try {
          final paise = Money.decimalStringToPaise(rawNum);
          if (paise >= 10 && paise <= 500000000) return paise;
        } catch (_) {}
      }
    }

    // Priority 3: Slash-dash currency values (e.g. 950/- or 1200/-)
    final dashPattern = RegExp(r'\b([0-9][0-9,]*)\s*/-');
    final dashMatches = dashPattern.allMatches(cleaned);
    if (dashMatches.isNotEmpty) {
      final rawNum = dashMatches.last.group(1);
      if (rawNum != null) {
        try {
          final paise = Money.decimalStringToPaise(rawNum);
          if (paise >= 10 && paise <= 500000000) return paise;
        } catch (_) {}
      }
    }

    // Priority 4: Plain integer numbers (e.g. 1450)
    final intPattern = RegExp(r'\b([0-9]{2,6})\b');
    final intMatches = intPattern.allMatches(cleaned);
    if (intMatches.isNotEmpty) {
      final rawNum = intMatches.last.group(1);
      if (rawNum != null) {
        try {
          final paise = Money.decimalStringToPaise(rawNum);
          if (paise >= 10 && paise <= 500000000) return paise;
        } catch (_) {}
      }
    }

    return null;
  }

  /// Extracts all distinct candidate amounts found across the receipt lines, sorted descending.
  static List<int> _extractAllCandidateAmounts(List<String> lines) {
    final amounts = <int>{};
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (_isItemCountLine(lower)) continue;
      if (lower.contains('gstin') ||
          lower.contains('fssai') ||
          lower.contains('cin') ||
          lower.contains('phone') ||
          lower.contains('tel:') ||
          lower.contains('mob:')) {
        continue;
      }
      final found = _findAllAmountsInString(line);
      amounts.addAll(found);
    }
    final sorted = amounts.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  /// Finds all monetary values within a single string line.
  static List<int> _findAllAmountsInString(String text) {
    var cleaned = text.replaceAll(
      RegExp(r'\b(?:items?|qty|quantity|pcs|pieces|count)\s*[:\-]?\s*\d+\b', caseSensitive: false),
      ' ',
    );
    cleaned = cleaned.replaceAll(RegExp(r'\b[6-9]\d{9}\b'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\b\d{1,4}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4}\b'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\b\d{1,2}:\d{2}(?::\d{2})?\b'), ' ');

    final results = <int>{};

    // 1. Currency symbols
    final currencyPattern = RegExp(
      r'(?:₹|Rs\.?|INR)\s*([0-9][0-9,]*(?:\.[0-9]{1,2})?)',
      caseSensitive: false,
    );
    for (final match in currencyPattern.allMatches(cleaned)) {
      final rawNum = match.group(1);
      if (rawNum != null) {
        try {
          final paise = Money.decimalStringToPaise(rawNum);
          if (paise >= 100 && paise <= 500000000) results.add(paise);
        } catch (_) {}
      }
    }

    // 2. Decimal values (e.g. 1,480.00)
    final decimalPattern = RegExp(r'\b([0-9]{1,3}(?:,[0-9]{2,3})*\.[0-9]{2})\b');
    for (final match in decimalPattern.allMatches(cleaned)) {
      final rawNum = match.group(1);
      if (rawNum != null) {
        try {
          final paise = Money.decimalStringToPaise(rawNum);
          if (paise >= 100 && paise <= 500000000) results.add(paise);
        } catch (_) {}
      }
    }

    // 3. Slash-dash (e.g. 950/-)
    final dashPattern = RegExp(r'\b([0-9][0-9,]*)\s*/-');
    for (final match in dashPattern.allMatches(cleaned)) {
      final rawNum = match.group(1);
      if (rawNum != null) {
        try {
          final paise = Money.decimalStringToPaise(rawNum);
          if (paise >= 100 && paise <= 500000000) results.add(paise);
        } catch (_) {}
      }
    }

    return results.toList();
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
