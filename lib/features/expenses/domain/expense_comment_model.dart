/// Domain model for a comment or dispute flag attached to an expense.
class ExpenseCommentModel {
  final String id;
  final String expenseId;
  final String tripId;
  final String? authorTravelerId;
  final String authorName;
  final String body;
  final bool isDispute;
  final bool isResolved;
  final DateTime createdAt;

  const ExpenseCommentModel({
    required this.id,
    required this.expenseId,
    required this.tripId,
    this.authorTravelerId,
    required this.authorName,
    required this.body,
    this.isDispute = false,
    this.isResolved = false,
    required this.createdAt,
  });

  ExpenseCommentModel copyWith({
    String? id,
    String? expenseId,
    String? tripId,
    String? authorTravelerId,
    String? authorName,
    String? body,
    bool? isDispute,
    bool? isResolved,
    DateTime? createdAt,
  }) {
    return ExpenseCommentModel(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      tripId: tripId ?? this.tripId,
      authorTravelerId: authorTravelerId ?? this.authorTravelerId,
      authorName: authorName ?? this.authorName,
      body: body ?? this.body,
      isDispute: isDispute ?? this.isDispute,
      isResolved: isResolved ?? this.isResolved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCommentModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          expenseId == other.expenseId &&
          tripId == other.tripId &&
          authorTravelerId == other.authorTravelerId &&
          authorName == other.authorName &&
          body == other.body &&
          isDispute == other.isDispute &&
          isResolved == other.isResolved &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        expenseId,
        tripId,
        authorTravelerId,
        authorName,
        body,
        isDispute,
        isResolved,
        createdAt,
      );
}

/// Per-expense comment and open-dispute summary counts.
class ExpenseCommentStats {
  final int totalCount;
  final int openDisputeCount;

  const ExpenseCommentStats({
    this.totalCount = 0,
    this.openDisputeCount = 0,
  });
}
