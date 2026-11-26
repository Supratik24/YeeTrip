/// Domain model for a Traveler in a trip.
class Traveler {
  final String id;
  final String tripId;
  final String name;
  final String? upiVpa;
  final String? avatarPath;
  final String? phone;

  const Traveler({
    required this.id,
    required this.tripId,
    required this.name,
    this.upiVpa,
    this.avatarPath,
    this.phone,
  });

  Traveler copyWith({
    String? id,
    String? tripId,
    String? name,
    String? upiVpa,
    String? avatarPath,
    String? phone,
  }) {
    return Traveler(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      upiVpa: upiVpa ?? this.upiVpa,
      avatarPath: avatarPath ?? this.avatarPath,
      phone: phone ?? this.phone,
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
          upiVpa == other.upiVpa &&
          avatarPath == other.avatarPath &&
          phone == other.phone;

  @override
  int get hashCode =>
      Object.hash(id, tripId, name, upiVpa, avatarPath, phone);
}

/// Domain model for a Trip with its travelers, allocations, spent summary, and itinerary summary.
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

  // Modern 2026 trip enhancements
  final String? destination;
  final String? coverPhotoPath;
  final String status; // 'active', 'completed', 'archived'
  final DateTime? startDate;
  final DateTime? endDate;

  // Itinerary & photo gallery progress summary for Dashboard & Notifications
  final int itineraryTotalCount;
  final int itineraryCompletedCount;
  final String? nextItineraryTitle;
  final int photoCount;

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
    this.destination,
    this.coverPhotoPath,
    this.status = 'active',
    this.startDate,
    this.endDate,
    this.itineraryTotalCount = 0,
    this.itineraryCompletedCount = 0,
    this.nextItineraryTitle,
    this.photoCount = 0,
  });

  int get remainingBudgetPaise => totalBudgetPaise - totalSpentPaise;

  int get budgetPerPersonPaise =>
      travelers.isEmpty ? 0 : totalBudgetPaise ~/ travelers.length;

  int get budgetPerDayPaise => days <= 0 ? 0 : totalBudgetPaise ~/ days;

  bool get isCompleted => status == 'completed';

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
    String? destination,
    String? coverPhotoPath,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? itineraryTotalCount,
    int? itineraryCompletedCount,
    String? nextItineraryTitle,
    int? photoCount,
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
      destination: destination ?? this.destination,
      coverPhotoPath: coverPhotoPath ?? this.coverPhotoPath,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      itineraryTotalCount: itineraryTotalCount ?? this.itineraryTotalCount,
      itineraryCompletedCount:
          itineraryCompletedCount ?? this.itineraryCompletedCount,
      nextItineraryTitle: nextItineraryTitle ?? this.nextItineraryTitle,
      photoCount: photoCount ?? this.photoCount,
    );
  }
}
