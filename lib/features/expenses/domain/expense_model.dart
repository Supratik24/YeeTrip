/// Supported split modes for YeeTrip expenses.
enum SplitMode {
  equal,
  exact,
  percentage,
  shares,
}

/// Domain model for an expense split entry.
class ExpenseSplitModel {
  final String expenseId;
  final String travelerId;
  final int sharePaise;

  const ExpenseSplitModel({
    required this.expenseId,
    required this.travelerId,
    required this.sharePaise,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseSplitModel &&
          runtimeType == other.runtimeType &&
          expenseId == other.expenseId &&
          travelerId == other.travelerId &&
          sharePaise == other.sharePaise;

  @override
  int get hashCode => Object.hash(expenseId, travelerId, sharePaise);
}

/// Domain model for an expense with full details and split allocations.
class ExpenseWithSplits {
  final String id;
  final String tripId;
  final String description;
  final int amountPaise;
  final String category;
  final String paidBy; // travelerId
  final String source; // 'manual', 'upi'
  final String? upiTxnId;
  final bool confirmed;
  final DateTime createdAt;
  final List<ExpenseSplitModel> splits;

  const ExpenseWithSplits({
    required this.id,
    required this.tripId,
    required this.description,
    required this.amountPaise,
    required this.category,
    required this.paidBy,
    this.source = 'manual',
    this.upiTxnId,
    this.confirmed = true,
    required this.createdAt,
    this.splits = const [],
  });

  ExpenseWithSplits copyWith({
    String? id,
    String? tripId,
    String? description,
    int? amountPaise,
    String? category,
    String? paidBy,
    String? source,
    String? upiTxnId,
    bool? confirmed,
    DateTime? createdAt,
    List<ExpenseSplitModel>? splits,
  }) {
    return ExpenseWithSplits(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      description: description ?? this.description,
      amountPaise: amountPaise ?? this.amountPaise,
      category: category ?? this.category,
      paidBy: paidBy ?? this.paidBy,
      source: source ?? this.source,
      upiTxnId: upiTxnId ?? this.upiTxnId,
      confirmed: confirmed ?? this.confirmed,
      createdAt: createdAt ?? this.createdAt,
      splits: splits ?? this.splits,
    );
  }
}
