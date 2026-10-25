/// Domain model for a Traveler in a trip.
class Traveler {
  final String id;
  final String tripId;
  final String name;
  final String? upiVpa;

  const Traveler({
    required this.id,
    required this.tripId,
    required this.name,
    this.upiVpa,
  });

  Traveler copyWith({
    String? id,
    String? tripId,
    String? name,
    String? upiVpa,
  }) {
    return Traveler(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      upiVpa: upiVpa ?? this.upiVpa,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Traveler &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tripId == other.tripId &&
          name == other.name &&
          upiVpa == other.upiVpa;

  @override
  int get hashCode => Object.hash(id, tripId, name, upiVpa);
}

/// Domain model for a Trip with its travelers, allocations, and spent summary.
class TripWithDetails {
  final String id;
  final String name;
  final int totalBudgetPaise;
  final int days;
  final String currency;
  final DateTime createdAt;
  final List<Traveler> travelers;
  final Map<String, int> categoryAllocations; // Category -> percent (sum = 100)
  final int totalSpentPaise;

  const TripWithDetails({
    required this.id,
    required this.name,
    required this.totalBudgetPaise,
    required this.days,
    this.currency = 'INR',
    required this.createdAt,
    this.travelers = const [],
    this.categoryAllocations = const {},
    this.totalSpentPaise = 0,
  });

  int get remainingBudgetPaise => totalBudgetPaise - totalSpentPaise;

  int get budgetPerPersonPaise =>
      travelers.isEmpty ? 0 : totalBudgetPaise ~/ travelers.length;

  int get budgetPerDayPaise => days <= 0 ? 0 : totalBudgetPaise ~/ days;

  TripWithDetails copyWith({
    String? id,
    String? name,
    int? totalBudgetPaise,
    int? days,
    String? currency,
    DateTime? createdAt,
    List<Traveler>? travelers,
    Map<String, int>? categoryAllocations,
    int? totalSpentPaise,
  }) {
    return TripWithDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      totalBudgetPaise: totalBudgetPaise ?? this.totalBudgetPaise,
      days: days ?? this.days,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      travelers: travelers ?? this.travelers,
      categoryAllocations: categoryAllocations ?? this.categoryAllocations,
      totalSpentPaise: totalSpentPaise ?? this.totalSpentPaise,
    );
  }
}
