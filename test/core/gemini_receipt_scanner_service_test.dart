import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/constants/categories.dart';
import 'package:yeetrip/core/gemini_receipt_scanner_service.dart';

void main() {
  group('GeminiReceiptScannerService Tests', () {
    test('parses clean Gemini JSON response accurately', () {
      const jsonStr = '''
{
  "merchantName": "Cafe Alchemia",
  "totalAmount": 945.50,
  "date": "2026-11-20",
  "category": "Food",
  "candidateAmounts": [945.50, 800.00, 145.50],
  "items": ["Cold Brew Coffee - 180.00", "Avocado Toast - 350.00", "Pasta Primavera - 415.50"],
  "rawTextSummary": "Cafe Alchemia Tax Invoice Total: 945.50"
}
''';

      final result = GeminiReceiptScannerService.parseGeminiJsonResponse(jsonStr);

      expect(result.merchantName, equals('Cafe Alchemia'));
      expect(result.amountPaise, equals(94550));
      expect(result.date, equals(DateTime(2026, 11, 20)));
      expect(result.suggestedCategory, equals(TripCategory.food.key));
      expect(result.candidateAmountsPaise, containsAll([94550, 80000, 14550]));
      expect(result.items.length, equals(3));
      expect(result.confidence, equals(0.95));
      expect(result.notes, contains('Gemini Vision AI'));
    });

    test('strips markdown ```json code blocks from Gemini response', () {
      const markdownJson = '''
```json
{
  "merchantName": "Indian Oil Fuel Station",
  "totalAmount": 2000.00,
  "date": "15/11/2026",
  "category": "Transport",
  "candidateAmounts": [2000.00],
  "items": ["Petrol 19.14L"],
  "rawTextSummary": "Indian Oil Fuel Station Total 2000"
}
```
''';

      final result = GeminiReceiptScannerService.parseGeminiJsonResponse(markdownJson);

      expect(result.merchantName, equals('Indian Oil Fuel Station'));
      expect(result.amountPaise, equals(200000));
      expect(result.suggestedCategory, equals(TripCategory.transport.key));
      expect(result.date, equals(DateTime(2026, 11, 15)));
    });

    test('throws GeminiReceiptException on malformed JSON', () {
      expect(
        () => GeminiReceiptScannerService.parseGeminiJsonResponse('Not valid JSON'),
        throwsA(isA<GeminiReceiptException>()),
      );
    });

    test('handles missing or null fields gracefully', () {
      const sparseJson = '''
{
  "merchantName": null,
  "totalAmount": null,
  "date": null,
  "category": null
}
''';

      final result = GeminiReceiptScannerService.parseGeminiJsonResponse(sparseJson);

      expect(result.merchantName, isNull);
      expect(result.amountPaise, isNull);
      expect(result.date, isNull);
      expect(result.suggestedCategory, equals(TripCategory.food.key));
      expect(result.confidence, equals(0.60));
    });
  });
}
