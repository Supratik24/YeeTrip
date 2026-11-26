/// Currencies supported across trips and multi-currency expenses in YeeTrip.
class TripCurrency {
  final String code;
  final String symbol;
  final String name;
  final String flag;
  final bool usesIndianGrouping;

  /// Approximate offline reference rate (1 unit of this currency in INR).
  /// Users can override the live exchange rate per expense.
  final double approxInrRate;

  const TripCurrency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
    this.usesIndianGrouping = false,
    required this.approxInrRate,
  });

  static const inr = TripCurrency(
    code: 'INR',
    symbol: '₹',
    name: 'Indian Rupee',
    flag: '🇮🇳',
    usesIndianGrouping: true,
    approxInrRate: 1.0,
  );

  static const usd = TripCurrency(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
    flag: '🇺🇸',
    approxInrRate: 84.5,
  );

  static const eur = TripCurrency(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    flag: '🇪🇺',
    approxInrRate: 91.0,
  );

  static const gbp = TripCurrency(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
    flag: '🇬🇧',
    approxInrRate: 107.0,
  );

  static const aed = TripCurrency(
    code: 'AED',
    symbol: 'AED ',
    name: 'UAE Dirham',
    flag: '🇦🇪',
    approxInrRate: 23.0,
  );

  static const thb = TripCurrency(
    code: 'THB',
    symbol: '฿',
    name: 'Thai Baht',
    flag: '🇹🇭',
    approxInrRate: 2.45,
  );

  static const sgd = TripCurrency(
    code: 'SGD',
    symbol: 'S\$',
    name: 'Singapore Dollar',
    flag: '🇸🇬',
    approxInrRate: 63.0,
  );

  static const jpy = TripCurrency(
    code: 'JPY',
    symbol: '¥',
    name: 'Japanese Yen',
    flag: '🇯🇵',
    approxInrRate: 0.56,
  );

  static const aud = TripCurrency(
    code: 'AUD',
    symbol: 'A\$',
    name: 'Australian Dollar',
    flag: '🇦🇺',
    approxInrRate: 55.0,
  );

  static const myr = TripCurrency(
    code: 'MYR',
    symbol: 'RM ',
    name: 'Malaysian Ringgit',
    flag: '🇲🇾',
    approxInrRate: 19.0,
  );

  static const List<TripCurrency> all = [
    inr,
    usd,
    eur,
    gbp,
    aed,
    thb,
    sgd,
    jpy,
    aud,
    myr,
  ];

  static TripCurrency fromCode(String? code) {
    if (code == null || code.trim().isEmpty) return inr;
    final normalized = code.trim().toUpperCase();
    return all.firstWhere(
      (c) => c.code == normalized,
      orElse: () => inr,
    );
  }

  /// Suggested default exchange rate from [fromCode] -> [toCode].
  /// i.e. 1 unit of [fromCode] equals `rate` units of [toCode].
  static double suggestedRate(String fromCodeStr, String toCodeStr) {
    final from = fromCode(fromCodeStr);
    final to = fromCode(toCodeStr);
    if (from.code == to.code) return 1.0;
    final raw = from.approxInrRate / to.approxInrRate;
    return double.parse(raw.toStringAsFixed(4));
  }
}
