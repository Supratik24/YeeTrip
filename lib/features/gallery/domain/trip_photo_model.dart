/// Domain model representing a photo memory inside a trip's shared gallery.
class TripPhotoModel {
  final String id;
  final String tripId;
  final String imagePath;
  final String? caption;
  final int dayNumber;
  final String? uploadedByTravelerId;
  final String uploadedByName;
  final DateTime createdAt;

  /// True when synthesized from an attached expense receipt rather than a gallery upload.
  final bool isReceipt;
  final String? sourceExpenseId;

  const TripPhotoModel({
    required this.id,
    required this.tripId,
    required this.imagePath,
    this.caption,
    this.dayNumber = 1,
    this.uploadedByTravelerId,
    this.uploadedByName = 'You',
    required this.createdAt,
    this.isReceipt = false,
    this.sourceExpenseId,
  });

  TripPhotoModel copyWith({
    String? id,
    String? tripId,
    String? imagePath,
    String? caption,
    bool clearCaption = false,
    int? dayNumber,
    String? uploadedByTravelerId,
    String? uploadedByName,
    DateTime? createdAt,
    bool? isReceipt,
    String? sourceExpenseId,
  }) {
    return TripPhotoModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      imagePath: imagePath ?? this.imagePath,
      caption: clearCaption ? null : (caption ?? this.caption),
      dayNumber: dayNumber ?? this.dayNumber,
      uploadedByTravelerId: uploadedByTravelerId ?? this.uploadedByTravelerId,
      uploadedByName: uploadedByName ?? this.uploadedByName,
      createdAt: createdAt ?? this.createdAt,
      isReceipt: isReceipt ?? this.isReceipt,
      sourceExpenseId: sourceExpenseId ?? this.sourceExpenseId,
    );
  }
}
