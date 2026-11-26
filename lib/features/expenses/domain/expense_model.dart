/// Supported split modes for YeeTrip expenses.
enum SplitMode {
  equal,
  exact,
  percentage,
  shares,
  itemized,
}

/// Split share for a single traveler.
class ExpenseSplitModel {
  final String expenseId;
  final String travelerId;
  final int sharePaise;

  const ExpenseSplitModel({
    required this.expenseId,
    required this.travelerId,
    required this.sharePaise,
  });

  ExpenseSplitModel copyWith({
    String? expenseId,
    String? travelerId,
    int? sharePaise,
  }) {
    return ExpenseSplitModel(
      expenseId: expenseId ?? this.expenseId,
      travelerId: travelerId ?? this.travelerId,
      sharePaise: sharePaise ?? this.sharePaise,
    );
  }

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

/// Domain model for an expense including all its splits, tags, notes, comments count, and optional origin currency.
class ExpenseWithSplits {
  final String id;
  final String tripId;
  final String description;
  final int amountPaise;
  final String category;
  final String paidBy; // travelerId
  final String source; // 'manual', 'upi', 'settlement'
  final String? upiTxnId;
  final bool confirmed;
  final DateTime createdAt;
  final List<ExpenseSplitModel> splits;
  final String? receiptImagePath;
  final String? notes;
  final List<String> tags;
  final String? originalCurrency;
  final int? originalAmountPaise;
  final double? exchangeRate;
  final int commentCount;
  final int openDisputeCount;

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
    this.receiptImagePath,
    this.notes,
    this.tags = const [],
    this.originalCurrency,
    this.originalAmountPaise,
    this.exchangeRate,
    this.commentCount = 0,
    this.openDisputeCount = 0,
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
    String? receiptImagePath,
    String? notes,
    List<String>? tags,
    String? originalCurrency,
    int? originalAmountPaise,
    double? exchangeRate,
    int? commentCount,
    int? openDisputeCount,
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
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      originalAmountPaise: originalAmountPaise ?? this.originalAmountPaise,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      commentCount: commentCount ?? this.commentCount,
      openDisputeCount: openDisputeCount ?? this.openDisputeCount,
    );
  }
}
