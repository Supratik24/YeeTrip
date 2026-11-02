import '../constants/categories.dart';

/// The result of an ML category classification on an expense description.
class CategoryPrediction {
  /// The predicted category key (e.g., 'Food', 'Transport', 'Stay', etc.).
  final String categoryKey;

  /// Confidence score between 0.0 (no match) and 1.0 (very strong match).
  final double confidence;

  /// Normalized scores across all categories.
  final Map<String, double> categoryScores;

  /// Keyword tokens that contributed to the classification.
  final List<String> matchedTokens;

  const CategoryPrediction({
    required this.categoryKey,
    required this.confidence,
    required this.categoryScores,
    this.matchedTokens = const [],
  });

  /// Whether the prediction confidence is high enough to auto-suggest or pre-select.
  bool get isHighConfidence => confidence >= 0.50;

  @override
  String toString() {
    return 'CategoryPrediction(category: $categoryKey, confidence: ${(confidence * 100).toStringAsFixed(1)}%, tokens: $matchedTokens)';
  }
}

/// Pure Dart on-device ML categorizer using keyword tokenization and weighted Naive Bayes scoring.
///
/// Pre-trained with Indian travel, dining, transit, accommodation, and shopping terms.
class SmartCategorizer {
  const SmartCategorizer();

  static const Set<String> _stopwords = {
    'the', 'a', 'an', 'at', 'for', 'in', 'on', 'to', 'and', 'of', 'with',
    'by', 'is', 'was', 'we', 'i', 'you', 'my', 'our', 'all', 'from', 'paid',
    'bill', 'total', 'amt', 'rupees', 'rs', 'inr', 'cash', 'upi', 'gpay',
  };

  /// Token-to-category associations with positive indicator weights.
  static const Map<String, Map<String, double>> _tokenWeights = {
    // ----------------- FOOD -----------------
    'biryani': {'Food': 4.0},
    'dosa': {'Food': 3.5},
    'idli': {'Food': 3.5},
    'chai': {'Food': 3.5},
    'tea': {'Food': 3.0},
    'coffee': {'Food': 3.0},
    'cafe': {'Food': 3.5},
    'restaurant': {'Food': 4.0},
    'dhaba': {'Food': 4.0},
    'kitchen': {'Food': 3.0},
    'bar': {'Food': 3.0},
    'pub': {'Food': 3.0},
    'brewery': {'Food': 3.5},
    'breakfast': {'Food': 4.0},
    'lunch': {'Food': 4.0},
    'dinner': {'Food': 4.0},
    'meals': {'Food': 3.5},
    'thali': {'Food': 4.0},
    'snacks': {'Food': 3.5},
    'sweets': {'Food': 3.5},
    'bakery': {'Food': 3.5},
    'cake': {'Food': 3.0},
    'pizza': {'Food': 3.5},
    'burger': {'Food': 3.5},
    'sandwich': {'Food': 3.0},
    'swiggy': {'Food': 4.0},
    'zomato': {'Food': 4.0},
    'mcdonalds': {'Food': 4.0},
    'mcdonald': {'Food': 4.0},
    'kfc': {'Food': 4.0},
    'starbucks': {'Food': 4.0},
    'dominos': {'Food': 4.0},
    'subway': {'Food': 4.0},
    'haldiram': {'Food': 4.0},
    'curry': {'Food': 3.0},
    'prawns': {'Food': 3.5},
    'fish': {'Food': 3.0},
    'chicken': {'Food': 3.0},
    'paneer': {'Food': 3.0},
    'roti': {'Food': 3.0},
    'naan': {'Food': 3.0},
    'icecream': {'Food': 3.0},
    'juice': {'Food': 3.0},
    'shake': {'Food': 3.0},
    'beer': {'Food': 2.5, 'Shopping': 1.5},
    'wine': {'Food': 2.5, 'Shopping': 1.5},
    'cocktail': {'Food': 3.0},
    'drinks': {'Food': 3.0},

    // ----------------- TRANSPORT -----------------
    'petrol': {'Transport': 4.5},
    'diesel': {'Transport': 4.5},
    'fuel': {'Transport': 4.5},
    'cng': {'Transport': 4.5},
    'hpcl': {'Transport': 4.5},
    'bpcl': {'Transport': 4.5},
    'iocl': {'Transport': 4.5},
    'indian oil': {'Transport': 4.5},
    'uber': {'Transport': 4.5},
    'ola': {'Transport': 4.5},
    'rapido': {'Transport': 4.5},
    'cab': {'Transport': 4.0},
    'taxi': {'Transport': 4.0},
    'auto': {'Transport': 3.5},
    'rickshaw': {'Transport': 3.5},
    'toll': {'Transport': 4.5},
    'fastag': {'Transport': 4.5},
    'flight': {'Transport': 4.5},
    'airfare': {'Transport': 4.5},
    'indigo': {'Transport': 4.0},
    'vistara': {'Transport': 4.0},
    'air india': {'Transport': 4.0},
    'spicejet': {'Transport': 4.0},
    'train': {'Transport': 4.0},
    'irctc': {'Transport': 4.5},
    'railway': {'Transport': 4.0},
    'bus': {'Transport': 4.0},
    'redbus': {'Transport': 4.5},
    'metro': {'Transport': 4.0},
    'parking': {'Transport': 3.5},
    'driver': {'Transport': 3.0},
    'scooter': {'Transport': 3.5},
    'scooty': {'Transport': 3.5},
    'bike': {'Transport': 3.0},
    'rental': {'Transport': 2.5, 'Stay': 1.0},
    'ferry': {'Transport': 3.5, 'Activities': 1.5},

    // ----------------- STAY -----------------
    'hotel': {'Stay': 4.5},
    'resort': {'Stay': 4.5},
    'oyo': {'Stay': 4.5},
    'airbnb': {'Stay': 4.5},
    'homestay': {'Stay': 4.5},
    'hostel': {'Stay': 4.0},
    'villa': {'Stay': 4.0},
    'cottage': {'Stay': 4.0},
    'lodge': {'Stay': 4.0},
    'inn': {'Stay': 3.5},
    'suites': {'Stay': 3.5},
    'room': {'Stay': 3.0},
    'tent': {'Stay': 3.5},
    'camp': {'Stay': 3.0, 'Activities': 1.5},
    'taj': {'Stay': 3.5, 'Food': 1.0},
    'marriott': {'Stay': 4.0},
    'hyatt': {'Stay': 4.0},
    'radisson': {'Stay': 4.0},
    'booking': {'Stay': 3.0},
    'agoda': {'Stay': 3.5},
    'makemytrip': {'Stay': 2.5, 'Transport': 2.0},
    'checkin': {'Stay': 3.5},
    'checkout': {'Stay': 3.5},
    'accommodation': {'Stay': 4.5},

    // ----------------- ACTIVITIES -----------------
    'scuba': {'Activities': 4.5},
    'snorkeling': {'Activities': 4.5},
    'diving': {'Activities': 4.5},
    'trek': {'Activities': 4.5},
    'trekking': {'Activities': 4.5},
    'safari': {'Activities': 4.5},
    'museum': {'Activities': 4.0},
    'fort': {'Activities': 3.5},
    'entry': {'Activities': 3.5},
    'ticket': {'Activities': 3.0, 'Transport': 1.5},
    'tickets': {'Activities': 3.0, 'Transport': 1.5},
    'pass': {'Activities': 2.5},
    'monument': {'Activities': 4.0},
    'temple': {'Activities': 3.0},
    'church': {'Activities': 3.0},
    'palace': {'Activities': 3.5},
    'parasailing': {'Activities': 4.5},
    'jetski': {'Activities': 4.5},
    'banana ride': {'Activities': 4.5},
    'cruise': {'Activities': 4.0},
    'boat': {'Activities': 3.5},
    'kayaking': {'Activities': 4.5},
    'rafting': {'Activities': 4.5},
    'bungee': {'Activities': 4.5},
    'zipline': {'Activities': 4.5},
    'club': {'Activities': 3.0, 'Food': 1.5},
    'casino': {'Activities': 4.0},
    'cinema': {'Activities': 3.5},
    'movie': {'Activities': 3.5},
    'waterpark': {'Activities': 4.0},
    'amusement': {'Activities': 4.0},

    // ----------------- SHOPPING -----------------
    'dmart': {'Shopping': 4.5},
    'supermarket': {'Shopping': 4.0},
    'grocery': {'Shopping': 4.0},
    'groceries': {'Shopping': 4.0},
    'decathlon': {'Shopping': 4.5},
    'mall': {'Shopping': 3.5},
    'market': {'Shopping': 3.0},
    'bazaar': {'Shopping': 3.5},
    'clothes': {'Shopping': 4.0},
    'clothing': {'Shopping': 4.0},
    'dress': {'Shopping': 3.5},
    'tshirt': {'Shopping': 3.5},
    'shirt': {'Shopping': 3.0},
    'shoes': {'Shopping': 3.5},
    'footwear': {'Shopping': 3.5},
    'slippers': {'Shopping': 3.0},
    'souvenir': {'Shopping': 4.5},
    'souvenirs': {'Shopping': 4.5},
    'spices': {'Shopping': 3.5},
    'cashew': {'Shopping': 3.5},
    'cashews': {'Shopping': 3.5},
    'feni': {'Shopping': 3.0, 'Food': 1.5},
    'liquor': {'Shopping': 3.0, 'Food': 1.5},
    'wine shop': {'Shopping': 3.5},
    'store': {'Shopping': 3.0},
    'shop': {'Shopping': 2.5},
    'gifts': {'Shopping': 3.5},
    'handicrafts': {'Shopping': 4.0},

    // ----------------- BUFFER -----------------
    'medicine': {'Buffer': 4.5},
    'medical': {'Buffer': 4.0},
    'pharmacy': {'Buffer': 4.5},
    'hospital': {'Buffer': 4.5},
    'clinic': {'Buffer': 4.0},
    'doctor': {'Buffer': 4.0},
    'firstaid': {'Buffer': 4.0},
    'emergency': {'Buffer': 4.5},
    'tip': {'Buffer': 4.0, 'Food': 1.0},
    'tips': {'Buffer': 4.0, 'Food': 1.0},
    'gratuity': {'Buffer': 4.5},
    'fine': {'Buffer': 4.0},
    'penalty': {'Buffer': 4.0},
    'challan': {'Buffer': 4.5},
    'sim': {'Buffer': 3.5},
    'recharge': {'Buffer': 3.5},
    'laundry': {'Buffer': 3.0},
    'misc': {'Buffer': 3.0},
  };

  /// Multi-word phrases that trigger high-confidence matching.
  static const Map<String, String> _phraseRules = {
    'fast tag': 'Transport',
    'fastag': 'Transport',
    'bike rental': 'Transport',
    'car rental': 'Transport',
    'scooter rental': 'Transport',
    'room service': 'Stay',
    'water sports': 'Activities',
    'entry ticket': 'Activities',
    'entry tickets': 'Activities',
    'entry fee': 'Activities',
    'ice cream': 'Food',
    'wine shop': 'Shopping',
    'liquor shop': 'Shopping',
    'petrol pump': 'Transport',
    'gas station': 'Transport',
    'boat ride': 'Activities',
    'first aid': 'Buffer',
    'toll plaza': 'Transport',
  };

  /// Predicts the most suitable YeeTrip category for the given expense description.
  CategoryPrediction predict(String description) {
    final trimmed = description.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return CategoryPrediction(
        categoryKey: TripCategory.food.key,
        confidence: 0.0,
        categoryScores: {
          for (final c in TripCategory.all) c.key: 0.0,
        },
      );
    }

    final scores = <String, double>{
      for (final c in TripCategory.all) c.key: 0.0,
    };
    final matched = <String>[];

    // 1. Check exact phrase rules first (highest confidence boost)
    for (final entry in _phraseRules.entries) {
      if (trimmed.contains(entry.key)) {
        scores[entry.value] = (scores[entry.value] ?? 0.0) + 5.0;
        matched.add(entry.key);
      }
    }

    // 2. Tokenize words
    final tokens = trimmed
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 1 && !_stopwords.contains(t))
        .toList();

    for (final token in tokens) {
      final weights = _tokenWeights[token];
      if (weights != null) {
        matched.add(token);
        for (final catEntry in weights.entries) {
          scores[catEntry.key] = (scores[catEntry.key] ?? 0.0) + catEntry.value;
        }
      }
    }

    // Find highest score
    String bestCategory = TripCategory.food.key;
    double maxScore = -1.0;
    double sumScores = 0.0;

    for (final entry in scores.entries) {
      sumScores += entry.value;
      if (entry.value > maxScore) {
        maxScore = entry.value;
        bestCategory = entry.key;
      }
    }

    // Calculate normalized confidence
    double confidence = 0.0;
    if (sumScores > 0) {
      confidence = (maxScore / sumScores).clamp(0.0, 1.0);
      // Boost confidence slightly if multiple tokens or strong phrases matched
      if (maxScore >= 4.0 && confidence >= 0.70) {
        confidence = (confidence + 0.15).clamp(0.0, 1.0);
      }
    }

    // Normalize all scores for breakdown
    final normalizedScores = <String, double>{};
    for (final entry in scores.entries) {
      normalizedScores[entry.key] = sumScores > 0
          ? double.parse((entry.value / sumScores).toStringAsFixed(3))
          : 0.0;
    }

    return CategoryPrediction(
      categoryKey: maxScore > 0 ? bestCategory : TripCategory.food.key,
      confidence: maxScore > 0 ? confidence : 0.0,
      categoryScores: normalizedScores,
      matchedTokens: matched.toSet().toList(),
    );
  }
}
