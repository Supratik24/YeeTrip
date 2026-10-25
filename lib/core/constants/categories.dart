/// Categories supported in YeeTrip with their display names and default allocations.
class TripCategory {
  final String key;
  final String displayName;
  final int defaultPercent;

  const TripCategory({
    required this.key,
    required this.displayName,
    required this.defaultPercent,
  });

  static const stay = TripCategory(
    key: 'Stay',
    displayName: 'Stay',
    defaultPercent: 30,
  );

  static const food = TripCategory(
    key: 'Food',
    displayName: 'Food',
    defaultPercent: 25,
  );

  static const transport = TripCategory(
    key: 'Transport',
    displayName: 'Transport',
    defaultPercent: 20,
  );

  static const activities = TripCategory(
    key: 'Activities',
    displayName: 'Activities',
    defaultPercent: 15,
  );

  static const shopping = TripCategory(
    key: 'Shopping',
    displayName: 'Shopping',
    defaultPercent: 5,
  );

  static const buffer = TripCategory(
    key: 'Buffer',
    displayName: 'Buffer',
    defaultPercent: 5,
  );

  static const List<TripCategory> all = [
    stay,
    food,
    transport,
    activities,
    shopping,
    buffer,
  ];

  static Map<String, int> get defaultPercentages => {
        for (final cat in all) cat.key: cat.defaultPercent,
      };

  static TripCategory fromKey(String key) {
    return all.firstWhere(
      (c) => c.key.toLowerCase() == key.toLowerCase(),
      orElse: () => buffer,
    );
  }
}
