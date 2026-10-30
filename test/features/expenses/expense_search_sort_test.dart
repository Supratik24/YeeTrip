import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/features/expenses/domain/expense_filter.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';

void main() {
  group('ExpenseFilterCriteria & Sorting Tests', () {
    final now = DateTime(2026, 5, 10, 12, 0);

    final expenses = [
      ExpenseWithSplits(
        id: 'e-1',
        tripId: 'trip-1',
        description: 'Seafood Thali Dinner',
        amountPaise: 240000, // ₹2,400
        category: 'Food',
        paidBy: 't-1',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      ExpenseWithSplits(
        id: 'e-2',
        tripId: 'trip-1',
        description: 'Airport Taxi',
        amountPaise: 150000, // ₹1,500
        category: 'Transport',
        paidBy: 't-2',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      ExpenseWithSplits(
        id: 'e-3',
        tripId: 'trip-1',
        description: 'Luxury Villa Stay',
        amountPaise: 1200000, // ₹12,000
        category: 'Stay',
        paidBy: 't-1',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      ExpenseWithSplits(
        id: 'e-4',
        tripId: 'trip-1',
        description: 'Sunset Cruise Drinks',
        amountPaise: 80000, // ₹800
        category: 'Food',
        paidBy: 't-3',
        createdAt: now,
      ),
    ];

    test('default criteria returns all expenses sorted by dateDesc (newest first)', () {
      const criteria = ExpenseFilterCriteria();
      expect(criteria.hasActiveFilters, isFalse);

      final result = criteria.apply(expenses);
      expect(result.length, equals(4));
      expect(result.map((e) => e.id).toList(), equals(['e-4', 'e-1', 'e-2', 'e-3']));
    });

    test('filters by search query case-insensitively on description', () {
      final criteria = const ExpenseFilterCriteria().copyWith(searchQuery: 'taxi');
      expect(criteria.hasActiveFilters, isTrue);

      final result = criteria.apply(expenses);
      expect(result.length, equals(1));
      expect(result.first.id, equals('e-2'));
    });

    test('filters by search query matching category name', () {
      final criteria = const ExpenseFilterCriteria().copyWith(searchQuery: 'stay');
      final result = criteria.apply(expenses);
      expect(result.length, equals(1));
      expect(result.first.id, equals('e-3'));
    });

    test('filters by category', () {
      final criteria = const ExpenseFilterCriteria().copyWith(category: 'Food');
      final result = criteria.apply(expenses);
      expect(result.length, equals(2));
      expect(result.map((e) => e.id).toList(), equals(['e-4', 'e-1']));
    });

    test('filters by payer traveler id', () {
      final criteria = const ExpenseFilterCriteria().copyWith(paidByTravelerId: 't-1');
      final result = criteria.apply(expenses);
      expect(result.length, equals(2));
      expect(result.map((e) => e.id).toList(), equals(['e-1', 'e-3']));
    });

    test('sorts by dateAsc (oldest first)', () {
      final criteria = const ExpenseFilterCriteria().copyWith(
        sortOption: ExpenseSortOption.dateAsc,
      );
      final result = criteria.apply(expenses);
      expect(result.map((e) => e.id).toList(), equals(['e-3', 'e-2', 'e-1', 'e-4']));
    });

    test('sorts by amountDesc (highest first)', () {
      final criteria = const ExpenseFilterCriteria().copyWith(
        sortOption: ExpenseSortOption.amountDesc,
      );
      final result = criteria.apply(expenses);
      expect(result.map((e) => e.id).toList(), equals(['e-3', 'e-1', 'e-2', 'e-4']));
    });

    test('sorts by amountAsc (lowest first)', () {
      final criteria = const ExpenseFilterCriteria().copyWith(
        sortOption: ExpenseSortOption.amountAsc,
      );
      final result = criteria.apply(expenses);
      expect(result.map((e) => e.id).toList(), equals(['e-4', 'e-2', 'e-1', 'e-3']));
    });

    test('combines search, category, payer, and sort', () {
      final criteria = const ExpenseFilterCriteria(
        searchQuery: 'dinner',
        category: 'Food',
        paidByTravelerId: 't-1',
        sortOption: ExpenseSortOption.amountDesc,
      );
      final result = criteria.apply(expenses);
      expect(result.length, equals(1));
      expect(result.first.id, equals('e-1'));
    });

    test('returns empty when no expenses match query', () {
      final criteria = const ExpenseFilterCriteria(searchQuery: 'scuba diving');
      final result = criteria.apply(expenses);
      expect(result, isEmpty);
    });
  });
}
