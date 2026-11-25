import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'constants/categories.dart';
import 'money.dart';
import 'receipt_parser.dart';

/// Exception thrown when Gemini Vision receipt extraction fails.
class GeminiReceiptException implements Exception {
  final String message;
  const GeminiReceiptException(this.message);

  @override
  String toString() => message;
}

/// Service that leverages Google Gemini Multimodal Vision AI model
/// to analyze, transcribe, and structure physical receipts & tax invoices.
class GeminiReceiptScannerService {
  final String? apiKey;

  const GeminiReceiptScannerService({this.apiKey});

  /// Default model identifier (Gemini 1.5 Flash is fast, multimodal, and cost-effective).
  static const String defaultModelName = 'gemini-1.5-flash';

  /// Whether a valid Gemini API key is configured.
  bool get hasApiKey {
    final k = apiKey;
    return k != null && k.trim().isNotEmpty;
  }

  /// Scans a receipt image file using the Gemini Multimodal Vision API.
  Future<ReceiptData> scanReceiptImage(String imagePath, {String? modelName}) async {
    final key = apiKey?.trim();
    if (key == null || key.isEmpty) {
      throw const GeminiReceiptException(
        'Gemini API key is required. Please set your Gemini API key in settings or the bill scanner.',
      );
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      throw const GeminiReceiptException('Receipt image file not found on device.');
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw const GeminiReceiptException('Receipt image file is empty.');
    }

    // Determine mime type from extension
    final pathLower = imagePath.toLowerCase();
    String mimeType = 'image/jpeg';
    if (pathLower.endsWith('.png')) {
      mimeType = 'image/png';
    } else if (pathLower.endsWith('.webp')) {
      mimeType = 'image/webp';
    }

    try {
      final model = GenerativeModel(
        model: modelName ?? defaultModelName,
        apiKey: key,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.1,
        ),
      );

      final promptText = '''
You are an expert Indian physical receipt and tax invoice transcription engine.
Analyze this receipt image carefully. Read all text, totals, taxes, dates, and item lines.
Extract and return a single valid JSON object strictly matching this schema:
{
  "merchantName": "Store/Restaurant/Business name, or null",
  "totalAmount": 1845.50 (final grand total / net payable amount as a number, or null),
  "date": "YYYY-MM-DD or DD/MM/YYYY string, or null",
  "category": "Food" | "Transport" | "Stay" | "Activities" | "Shopping" | "Buffer",
  "candidateAmounts": [1845.50, 1450.00, 72.50, 36.25],
  "items": ["Item name and price"],
  "rawTextSummary": "Plain text summary of the receipt lines"
}

Important Rules:
- The "totalAmount" MUST be the final Net Payable / Grand Total (do not confuse with Subtotal or tax amounts).
- Collect all valid monetary amounts visible on the receipt in "candidateAmounts" in descending order.
- "category" MUST be one of: Food, Transport, Stay, Activities, Shopping, Buffer.
- Return ONLY the raw JSON object.
''';

      final response = await model.generateContent([
        Content.multi([
          TextPart(promptText),
          DataPart(mimeType, bytes),
        ]),
      ]);

      final responseText = response.text?.trim();
      if (responseText == null || responseText.isEmpty) {
        throw const GeminiReceiptException('Gemini did not return any response for this image.');
      }

      return parseGeminiJsonResponse(responseText).copyWith(imagePath: imagePath);
    } on GeminiReceiptException {
      rethrow;
    } catch (e) {
      debugPrint('Gemini Vision OCR API Error: $e');
      final errorStr = e.toString();
      if (errorStr.contains('API_KEY_INVALID') || errorStr.contains('API key not valid')) {
        throw const GeminiReceiptException('Invalid Gemini API key. Please check your API key.');
      } else if (errorStr.contains('QUOTA_EXCEEDED') || errorStr.contains('Resource has been exhausted')) {
        throw const GeminiReceiptException('Gemini API quota exceeded. Please try again later.');
      } else if (errorStr.contains('SocketException') || errorStr.contains('Network is unreachable')) {
        throw const GeminiReceiptException('Network error. Please check your internet connection.');
      }
      throw GeminiReceiptException('Failed to scan bill with Gemini: $e');
    }
  }

  /// Parses the JSON output from Gemini into a structured [ReceiptData].
  static ReceiptData parseGeminiJsonResponse(String jsonString) {
    var cleaned = jsonString.trim();
    // Strip markdown code fences if present
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    try {
      final map = jsonDecode(cleaned) as Map<String, dynamic>;

      // Merchant
      final merchantName = map['merchantName'] as String?;

      // Total Amount
      int? amountPaise;
      final rawTotal = map['totalAmount'];
      if (rawTotal != null) {
        try {
          amountPaise = Money.decimalStringToPaise(rawTotal.toString());
        } catch (_) {}
      }

      // Date
      DateTime? date;
      final rawDate = map['date'] as String?;
      if (rawDate != null && rawDate.isNotEmpty) {
        date = _tryParseDateString(rawDate);
      }

      // Category
      final rawCat = map['category'] as String?;
      final category = _mapCategory(rawCat);

      // Candidate amounts
      final candidateAmounts = <int>[];
      final rawCandidates = map['candidateAmounts'];
      if (rawCandidates is List) {
        for (final item in rawCandidates) {
          try {
            final paise = Money.decimalStringToPaise(item.toString());
            if (paise >= 100 && !candidateAmounts.contains(paise)) {
              candidateAmounts.add(paise);
            }
          } catch (_) {}
        }
      }
      if (amountPaise != null && !candidateAmounts.contains(amountPaise)) {
        candidateAmounts.insert(0, amountPaise);
      }
      candidateAmounts.sort((a, b) => b.compareTo(a));

      // Items
      final items = <String>[];
      final rawItems = map['items'];
      if (rawItems is List) {
        for (final item in rawItems) {
          final str = item.toString().trim();
          if (str.isNotEmpty) items.add(str);
        }
      }

      final summary = (map['rawTextSummary'] as String?) ?? cleaned;

      return ReceiptData(
        amountPaise: amountPaise,
        merchantName: merchantName,
        date: date,
        suggestedCategory: category,
        confidence: amountPaise != null ? 0.95 : 0.60,
        rawText: summary,
        candidateAmountsPaise: candidateAmounts,
        items: items,
        notes: 'Scanned with Gemini Vision AI model',
      );
    } catch (e) {
      throw GeminiReceiptException('Failed to parse Gemini response JSON: $e');
    }
  }

  static DateTime? _tryParseDateString(String str) {
    final parsed = DateTime.tryParse(str);
    if (parsed != null) return parsed;

    // Check DD/MM/YYYY
    final parts = str.split(RegExp(r'[\/\-\.]'));
    if (parts.length == 3) {
      try {
        if (parts[0].length == 4) {
          return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        } else {
          var y = int.parse(parts[2]);
          if (y < 100) y += 2000;
          return DateTime(y, int.parse(parts[1]), int.parse(parts[0]));
        }
      } catch (_) {}
    }
    return null;
  }

  static String _mapCategory(String? cat) {
    if (cat == null) return TripCategory.food.key;
    final lower = cat.toLowerCase();
    for (final c in TripCategory.all) {
      if (c.key.toLowerCase() == lower) return c.key;
    }
    return TripCategory.food.key;
  }
}

/// Notifier for persistent user-configured Gemini API key.
class GeminiApiKeyNotifier extends Notifier<String?> {
  @override
  String? build() {
    const envKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (envKey.isNotEmpty) return envKey;
    return null;
  }

  void setKey(String? key) {
    state = key;
  }
}

/// Riverpod provider for user-configured Gemini API key.
final geminiApiKeyProvider = NotifierProvider<GeminiApiKeyNotifier, String?>(
  GeminiApiKeyNotifier.new,
);

/// Riverpod provider for [GeminiReceiptScannerService].
final geminiReceiptScannerServiceProvider = Provider<GeminiReceiptScannerService>((ref) {
  final apiKey = ref.watch(geminiApiKeyProvider);
  return GeminiReceiptScannerService(apiKey: apiKey);
});
