import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../features/budget/domain/rebalance.dart';
import '../constants/categories.dart';
import '../constants/currencies.dart';
import '../gemini_receipt_scanner_service.dart';
import '../money.dart';

/// Travel comfort tier used to tune AI and offline budget suggestions.
enum TravelBudgetStyle {
  budget('Backpacker', 'Hostels, local transit & street food'),
  balanced('Balanced', 'Mid-range stays, mix of experiences & comfort'),
  luxury('Luxury', 'Resorts, private transfers & fine dining');

  final String label;
  final String subtitle;

  const TravelBudgetStyle(this.label, this.subtitle);
}

/// Structured trip budget recommendation.
class BudgetSuggestion {
  final int totalBudgetMinor;
  final String currencyCode;
  final int dailyPerPersonMinor;
  final Map<String, int> categoryAllocations;
  final String reasoning;
  final List<String> tips;
  final bool isAiGenerated;

  const BudgetSuggestion({
    required this.totalBudgetMinor,
    required this.currencyCode,
    required this.dailyPerPersonMinor,
    required this.categoryAllocations,
    required this.reasoning,
    this.tips = const [],
    this.isAiGenerated = false,
  });
}

/// Exception thrown when Gemini budget generation fails cleanly.
class AiBudgetException implements Exception {
  final String message;
  const AiBudgetException(this.message);

  @override
  String toString() => message;
}

/// Generates trip budget suggestions using Google Gemini (when API key is present)
/// with a fast, deterministic destination-aware offline heuristic engine.
class AiBudgetSuggesterService {
  final String? apiKey;

  const AiBudgetSuggesterService({this.apiKey});

  bool get hasApiKey {
    final k = apiKey?.trim();
    return k != null && k.isNotEmpty;
  }

  /// Suggests a trip budget using Gemini AI when configured and enabled,
  /// or falls back to [suggestOffline].
  Future<BudgetSuggestion> suggestBudget({
    required String destination,
    required int days,
    required int travelerCount,
    required String currencyCode,
    TravelBudgetStyle style = TravelBudgetStyle.balanced,
    bool preferAi = true,
    Future<String> Function(String prompt)? rawGeneratorOverride,
  }) async {
    final normalizedDays = max(1, days);
    final normalizedTravelers = max(1, travelerCount);
    final normalizedCurrency = currencyCode.trim().isEmpty
        ? 'INR'
        : currencyCode.trim().toUpperCase();
    final trimmedDest = destination.trim();

    if (preferAi && (hasApiKey || rawGeneratorOverride != null)) {
      final prompt = buildPrompt(
        destination: trimmedDest.isEmpty ? 'General leisure getaway' : trimmedDest,
        days: normalizedDays,
        travelerCount: normalizedTravelers,
        currencyCode: normalizedCurrency,
        style: style,
      );

      final responseText = rawGeneratorOverride != null
          ? await rawGeneratorOverride(prompt)
          : await _callGemini(prompt);

      return parseGeminiResponse(
        responseText,
        days: normalizedDays,
        travelerCount: normalizedTravelers,
        currencyCode: normalizedCurrency,
      );
    }

    return suggestOffline(
      destination: trimmedDest,
      days: normalizedDays,
      travelerCount: normalizedTravelers,
      currencyCode: normalizedCurrency,
      style: style,
    );
  }

  Future<String> _callGemini(String prompt) async {
    final key = apiKey?.trim();
    if (key == null || key.isEmpty) {
      throw const AiBudgetException('Gemini API key is missing.');
    }
    try {
      final model = GenerativeModel(
        model: GeminiReceiptScannerService.defaultModelName,
        apiKey: key,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.2,
        ),
      );
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        throw const AiBudgetException('Gemini returned an empty budget response.');
      }
      return text;
    } on AiBudgetException {
      rethrow;
    } catch (e) {
      throw AiBudgetException('Gemini request failed: $e');
    }
  }

  static String buildPrompt({
    required String destination,
    required int days,
    required int travelerCount,
    required String currencyCode,
    required TravelBudgetStyle style,
  }) {
    return '''
You are an expert travel budget planner.
Estimate a realistic total group trip budget in $currencyCode (major units, e.g. 60000 for ₹60,000 or 2400 for \$2,400).

Trip parameters:
- Destination: $destination
- Duration: $days day(s)
- Travelers: $travelerCount person(s)
- Comfort level: ${style.label} (${style.subtitle})
- Target currency: $currencyCode

Return ONLY a valid JSON object matching this exact schema:
{
  "totalBudget": 60000,
  "categoryAllocations": {
    "Stay": 30,
    "Food": 25,
    "Transport": 20,
    "Activities": 15,
    "Shopping": 5,
    "Buffer": 5
  },
  "reasoning": "Concise 1-2 sentence explanation covering lodging, meals, and transport.",
  "tips": [
    "Actionable money-saving tip 1",
    "Actionable money-saving tip 2"
  ]
}

Rules:
- "totalBudget" must be a positive number for the ENTIRE group across all $days day(s).
- "categoryAllocations" must contain integer percentages for Stay, Food, Transport, Activities, Shopping, Buffer summing to 100.
''';
  }

  /// Parses structured JSON output from Gemini into a [BudgetSuggestion].
  static BudgetSuggestion parseGeminiResponse(
    String rawJson, {
    required int days,
    required int travelerCount,
    required String currencyCode,
  }) {
    var cleaned = rawJson.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    final decoded = jsonDecode(cleaned);
    if (decoded is! Map<String, dynamic>) {
      throw const AiBudgetException('Expected JSON object from Gemini.');
    }

    final rawTotal = decoded['totalBudget'];
    if (rawTotal == null) {
      throw const AiBudgetException('Gemini response missing totalBudget.');
    }
    final totalMinor = Money.decimalStringToPaise(rawTotal.toString());
    if (totalMinor <= 0) {
      throw const AiBudgetException('Suggested budget must be positive.');
    }

    final rawAlloc = decoded['categoryAllocations'];
    final allocMap = <String, int>{};
    if (rawAlloc is Map) {
      for (final cat in TripCategory.all) {
        final v = rawAlloc[cat.key];
        if (v is num) {
          allocMap[cat.key] = max(0, v.round());
        } else {
          allocMap[cat.key] = TripCategory.defaultPercentages[cat.key] ?? 0;
        }
      }
    } else {
      allocMap.addAll(TripCategory.defaultPercentages);
    }

    final normalizedAlloc = BudgetRebalancer.normalizeAllocations(allocMap);
    final reasoning = (decoded['reasoning'] as String?)?.trim();
    final rawTips = decoded['tips'];
    final tips = <String>[
      if (rawTips is List)
        for (final t in rawTips)
          if (t.toString().trim().isNotEmpty) t.toString().trim(),
    ];

    final denom = max(1, days) * max(1, travelerCount);
    final dailyPerPersonMinor = totalMinor ~/ denom;

    return BudgetSuggestion(
      totalBudgetMinor: totalMinor,
      currencyCode: currencyCode.toUpperCase(),
      dailyPerPersonMinor: dailyPerPersonMinor,
      categoryAllocations: normalizedAlloc,
      reasoning: (reasoning != null && reasoning.isNotEmpty)
          ? reasoning
          : 'AI estimate tailored for $travelerCount traveler(s) over $days day(s).',
      tips: tips,
      isAiGenerated: true,
    );
  }

  /// Deterministic, destination-aware offline budget estimator.
  static BudgetSuggestion suggestOffline({
    required String destination,
    required int days,
    required int travelerCount,
    required String currencyCode,
    TravelBudgetStyle style = TravelBudgetStyle.balanced,
  }) {
    final normalizedDays = max(1, days);
    final normalizedTravelers = max(1, travelerCount);
    final normalizedCurrency = currencyCode.trim().isEmpty
        ? 'INR'
        : currencyCode.trim().toUpperCase();
    final destLower = destination.trim().toLowerCase();

    // Base daily spend per person in INR major units
    int baseDailyInr = 2500;
    String regionTag = 'domestic getaway';

    const highTierIntl = [
      'europe',
      'paris',
      'london',
      'uk',
      'swiss',
      'switzerland',
      'italy',
      'rome',
      'spain',
      'usa',
      'new york',
      'san francisco',
      'japan',
      'tokyo',
      'kyoto',
      'australia',
      'sydney',
      'melbourne',
    ];
    const midIntl = [
      'dubai',
      'uae',
      'abu dhabi',
      'singapore',
      'maldives',
      'bali',
      'korea',
      'seoul',
    ];
    const valueIntl = [
      'thailand',
      'bangkok',
      'phuket',
      'krabi',
      'vietnam',
      'hanoi',
      'sri lanka',
      'nepal',
      'kathmandu',
      'malaysia',
      'kuala lumpur',
      'bhutan',
    ];
    const hillAndHeritageIndia = [
      'ladakh',
      'leh',
      'kashmir',
      'srinagar',
      'manali',
      'shimla',
      'udaipur',
      'jaipur',
      'rajasthan',
      'mumbai',
      'delhi',
      'bengaluru',
      'coorg',
      'ooty',
      'andaman',
      'sikkim',
      'gangtok',
    ];
    const beachAndChillIndia = [
      'goa',
      'pondicherry',
      'puducherry',
      'kerala',
      'kochi',
      'munnar',
      'rishikesh',
      'gokarna',
      'varkala',
      'hampi',
      'kasol',
    ];

    if (highTierIntl.any((k) => destLower.contains(k))) {
      baseDailyInr = 12000;
      regionTag = 'international destination';
    } else if (midIntl.any((k) => destLower.contains(k))) {
      baseDailyInr = 8000;
      regionTag = 'international hub';
    } else if (valueIntl.any((k) => destLower.contains(k))) {
      baseDailyInr = 4500;
      regionTag = 'Southeast/South Asia destination';
    } else if (hillAndHeritageIndia.any((k) => destLower.contains(k))) {
      baseDailyInr = 3200;
      regionTag = 'popular metro/mountain destination';
    } else if (beachAndChillIndia.any((k) => destLower.contains(k))) {
      baseDailyInr = 2800;
      regionTag = 'coastal/backpacker favorite';
    }

    final styleMultiplier = switch (style) {
      TravelBudgetStyle.budget => 0.65,
      TravelBudgetStyle.balanced => 1.0,
      TravelBudgetStyle.luxury => 1.65,
    };

    // Group sharing efficiency for rooms & cabs
    final groupScale = switch (normalizedTravelers) {
      1 => 1.15,
      2 => 1.0,
      <= 4 => 0.88,
      _ => 0.80,
    };

    final rawTotalInr =
        baseDailyInr * normalizedDays * normalizedTravelers * styleMultiplier * groupScale;

    final inrToTargetRate = normalizedCurrency == 'INR'
        ? 1.0
        : TripCurrency.suggestedRate('INR', normalizedCurrency);

    final rawTotalTargetMajor = rawTotalInr * inrToTargetRate;
    final roundedTargetMajor = _roundFriendlyMajor(
      rawTotalTargetMajor,
      normalizedCurrency,
    );
    final totalMinor = roundedTargetMajor * 100;
    final dailyPerPersonMinor =
        totalMinor ~/ (normalizedDays * normalizedTravelers);

    final allocations = switch (style) {
      TravelBudgetStyle.budget => <String, int>{
          'Stay': 25,
          'Food': 25,
          'Transport': 25,
          'Activities': 15,
          'Shopping': 5,
          'Buffer': 5,
        },
      TravelBudgetStyle.balanced => <String, int>{
          'Stay': 30,
          'Food': 25,
          'Transport': 20,
          'Activities': 15,
          'Shopping': 5,
          'Buffer': 5,
        },
      TravelBudgetStyle.luxury => <String, int>{
          'Stay': 40,
          'Food': 22,
          'Transport': 13,
          'Activities': 15,
          'Shopping': 5,
          'Buffer': 5,
        },
    };

    final destLabel = destination.trim().isEmpty
        ? regionTag
        : '${destination.trim()} ($regionTag)';

    return BudgetSuggestion(
      totalBudgetMinor: totalMinor,
      currencyCode: normalizedCurrency,
      dailyPerPersonMinor: dailyPerPersonMinor,
      categoryAllocations: allocations,
      reasoning:
          'Smart ${style.label.toLowerCase()} estimate for $destLabel across $normalizedDays day(s) & $normalizedTravelers traveler(s), factoring shared room/cab savings.',
      tips: [
        'Keep 5–10% in Buffer for unexpected weather or transit changes.',
        if (normalizedTravelers >= 2)
          'Split shared cabs and accommodation early to stay ~12–20% under solo costs.',
        'Pre-book peak-day stays & intercity tickets to lock lower rates.',
      ],
      isAiGenerated: false,
    );
  }

  static int _roundFriendlyMajor(double value, String currencyCode) {
    final step = switch (currencyCode) {
      'INR' || 'JPY' => value >= 10000 ? 500 : 100,
      'THB' || 'AED' || 'MYR' => 50,
      _ => value >= 500 ? 50 : 10,
    };
    final rounded = ((value / step).round() * step);
    return max(step, rounded);
  }
}

/// Riverpod provider for [AiBudgetSuggesterService].
final aiBudgetSuggesterServiceProvider = Provider<AiBudgetSuggesterService>((ref) {
  final apiKey = ref.watch(geminiApiKeyProvider);
  return AiBudgetSuggesterService(apiKey: apiKey);
});
