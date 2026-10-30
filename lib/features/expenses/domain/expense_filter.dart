import 'expense_model.dart';

/// Available sorting options for expense listings.
enum ExpenseSortOption {
  dateDesc,
  dateAsc,
  amountDesc,
  amountAsc,
}

extension ExpenseSortOptionLabel on ExpenseSortOption {
  String get label {
    switch (this) {
      case ExpenseSortOption.dateDesc:
        return 'Date: Newest first';
      case ExpenseSortOption.dateAsc:
        return 'Date: Oldest first';
      case ExpenseSortOption.amountDesc:
        return 'Amount: Highest first';
      case ExpenseSortOption.amountAsc:
        return 'Amount: Lowest first';
    }
  }
}

/// Pure Dart filtering and sorting logic for expenses.
/// Adheres strictly to Non-negotiable Rule #4 (no Flutter imports).
class ExpenseFilterCriteria {
  final String searchQuery;
  final String category;
  final String paidByTravelerId;
  final ExpenseSortOption sortOption;

  const ExpenseFilterCriteria({
    this.searchQuery = '',
    this.category = 'All',
    this.paidByTravelerId = 'All',
    this.sortOption = ExpenseSortOption.dateDesc,
  });

  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      category != 'All' ||
      paidByTravelerId != 'All' ||
      sortOption != ExpenseSortOption.dateDesc;

  ExpenseFilterCriteria copyWith({
    String? searchQuery,
    String? category,
    String? paidByTravelerId,
    ExpenseSortOption? sortOption,
  }) {
    return ExpenseFilterCriteria(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      paidByTravelerId: paidByTravelerId ?? this.paidByTravelerId,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  /// Filters and sorts the provided expenses according to the criteria.
  List<ExpenseWithSplits> apply(List<ExpenseWithSplits> expenses) {
    final query = searchQuery.trim().toLowerCase();

    final filtered = expenses.where((e) {
      // 1. Category check
      if (category != 'All' && e.category != category) {
        return false;
      }

      // 2. Payer check
      if (paidByTravelerId != 'All' && e.paidBy != paidByTravelerId) {
        return false;
      }

      // 3. Search query check (matches description or category)
      if (query.isNotEmpty) {
        final matchesDesc = e.description.toLowerCase().contains(query);
        final matchesCat = e.category.toLowerCase().contains(query);
        if (!matchesDesc && !matchesCat) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sorting
    switch (sortOption) {
      case ExpenseSortOption.dateDesc:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ExpenseSortOption.dateAsc:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case ExpenseSortOption.amountDesc:
        filtered.sort((a, b) => b.amountPaise.compareTo(a.amountPaise));
        break;
      case ExpenseSortOption.amountAsc:
        filtered.sort((a, b) => a.amountPaise.compareTo(b.amountPaise));
        break;
    }

    return filtered;
  }
}
