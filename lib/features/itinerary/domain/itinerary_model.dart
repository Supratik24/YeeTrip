/// Domain model for a single planned activity or reservation in a trip's day-by-day itinerary.
class ItineraryItemModel {
  final String id;
  final String tripId;
  final int dayNumber;
  final String title;
  final String? location;
  final String? timeSlot;
  final int? startTimeMinutes;
  final String category;
  final int estimatedCostPaise;
  final String? notes;
  final bool isCompleted;
  final int sortOrder;
  final DateTime createdAt;

  const ItineraryItemModel({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    required this.title,
    this.location,
    this.timeSlot,
    this.startTimeMinutes,
    this.category = 'Activities',
    this.estimatedCostPaise = 0,
    this.notes,
    this.isCompleted = false,
    this.sortOrder = 0,
    required this.createdAt,
  });

  /// Formats [startTimeMinutes] as e.g. `09:30 AM`, falling back to [timeSlot].
  String get displayTime {
    if (startTimeMinutes != null) {
      final totalMins = startTimeMinutes!.clamp(0, 1439);
      final hour24 = totalMins ~/ 60;
      final minute = totalMins % 60;
      final period = hour24 >= 12 ? 'PM' : 'AM';
      final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
      final hStr = hour12.toString().padLeft(2, '0');
      final mStr = minute.toString().padLeft(2, '0');
      return '$hStr:$mStr $period';
    }
    if (timeSlot != null && timeSlot!.trim().isNotEmpty) {
      return timeSlot!.trim();
    }
    return 'Anytime';
  }

  ItineraryItemModel copyWith({
    String? id,
    String? tripId,
    int? dayNumber,
    String? title,
    String? location,
    String? timeSlot,
    int? startTimeMinutes,
    String? category,
    int? estimatedCostPaise,
    String? notes,
    bool? isCompleted,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return ItineraryItemModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      location: location ?? this.location,
      timeSlot: timeSlot ?? this.timeSlot,
      startTimeMinutes: startTimeMinutes ?? this.startTimeMinutes,
      category: category ?? this.category,
      estimatedCostPaise: estimatedCostPaise ?? this.estimatedCostPaise,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItineraryItemModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tripId == other.tripId &&
          dayNumber == other.dayNumber &&
          title == other.title &&
          location == other.location &&
          timeSlot == other.timeSlot &&
          startTimeMinutes == other.startTimeMinutes &&
          category == other.category &&
          estimatedCostPaise == other.estimatedCostPaise &&
          notes == other.notes &&
          isCompleted == other.isCompleted &&
          sortOrder == other.sortOrder &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        tripId,
        dayNumber,
        title,
        location,
        timeSlot,
        startTimeMinutes,
        category,
        estimatedCostPaise,
        notes,
        isCompleted,
        sortOrder,
        createdAt,
      );
}
