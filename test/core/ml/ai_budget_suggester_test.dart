import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/ml/ai_budget_suggester.dart';

void main() {
  group('AiBudgetSuggesterService', () {
    test('suggestOffline scales by destination, duration, travelers, style, and currency', () {
      final goaBudget = AiBudgetSuggesterService.suggestOffline(
        destination: 'Goa',
        days: 4,
        travelerCount: 4,
        currencyCode: 'INR',
        style: TravelBudgetStyle.balanced,
      );
      final europeLuxury = AiBudgetSuggesterService.suggestOffline(
        destination: 'Paris & Europe',
        days: 7,
        travelerCount: 2,
        currencyCode: 'EUR',
        style: TravelBudgetStyle.luxury,
      );

      expect(goaBudget.totalBudgetMinor, greaterThan(0));
      expect(goaBudget.currencyCode, equals('INR'));
      expect(goaBudget.isAiGenerated, isFalse);
      expect(
        goaBudget.categoryAllocations.values.fold<int>(0, (s, v) => s + v),
        equals(100),
      );

      expect(europeLuxury.currencyCode, equals('EUR'));
      expect(
        europeLuxury.categoryAllocations.values.fold<int>(0, (s, v) => s + v),
        equals(100),
      );
      expect(
        europeLuxury.categoryAllocations['Stay']!,
        greaterThan(goaBudget.categoryAllocations['Stay']!),
      );
    });

    test('suggestBudget parses Gemini JSON response cleanly when generator is available', () async {
      const service = AiBudgetSuggesterService(apiKey: 'fake-key');
      final suggestion = await service.suggestBudget(
        destination: 'Manali',
        days: 5,
        travelerCount: 3,
        currencyCode: 'INR',
        rawGeneratorOverride: (_) async => '''
```json
{
  "totalBudget": 48000,
  "categoryAllocations": {
    "Stay": 35,
    "Food": 25,
    "Transport": 20,
    "Activities": 10,
    "Shopping": 5,
    "Buffer": 5
  },
  "reasoning": "Covers cottages, Volvo buses, and Solang Valley activities.",
  "tips": ["Book overnight HRTC buses early", "Travel in shoulder season"]
}
```''',
      );

      expect(suggestion.isAiGenerated, isTrue);
      expect(suggestion.totalBudgetMinor, equals(4800000));
      expect(suggestion.dailyPerPersonMinor, equals(4800000 ~/ 15));
      expect(
        suggestion.categoryAllocations.values.fold<int>(0, (s, v) => s + v),
        equals(100),
      );
      expect(suggestion.tips.length, equals(2));
    });
  });
}
