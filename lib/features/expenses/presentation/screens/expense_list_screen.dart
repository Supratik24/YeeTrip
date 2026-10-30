import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/categories.dart';
import '../../../../core/money.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../data/providers.dart';
import '../../../trips/domain/trip_model.dart';
import '../../domain/expense_filter.dart';
import '../../domain/expense_model.dart';

/// Screen listing all trip expenses with search, sort, and category/payer filters.
class ExpenseListScreen extends ConsumerStatefulWidget {
  final TripWithDetails trip;

  const ExpenseListScreen({
    super.key,
    required this.trip,
  });

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  ExpenseFilterCriteria _criteria = const ExpenseFilterCriteria();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _categoryColor(String key) {
    switch (key.toLowerCase()) {
      case 'stay':
        return Colors.blue.shade600;
      case 'food':
        return Colors.orange.shade600;
      case 'transport':
        return Colors.green.shade600;
      case 'activities':
        return Colors.purple.shade600;
      case 'shopping':
        return Colors.pink.shade500;
      case 'buffer':
      default:
        return Colors.teal.shade600;
    }
  }

  Future<void> _deleteExpense(ExpenseWithSplits expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('Are you sure you want to delete "${expense.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(expenseRepositoryProvider).deleteExpense(expense.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${expense.description}"')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(tripExpensesProvider(widget.trip.id));
    final theme = Theme.of(context);
    final travelersMap = {
      for (final t in widget.trip.travelers) t.id: t.name,
    };

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                key: const Key('expense_search_field'),
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search description, category...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                ),
                onChanged: (val) {
                  setState(() {
                    _criteria = _criteria.copyWith(searchQuery: val);
                  });
                },
              )
            : const Text('Expenses'),
        actions: [
          if (_isSearching)
            IconButton(
              key: const Key('clear_search_btn'),
              icon: const Icon(Icons.close),
              tooltip: 'Close search',
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _criteria = _criteria.copyWith(searchQuery: '');
                  _isSearching = false;
                });
              },
            )
          else ...[
            IconButton(
              key: const Key('open_search_btn'),
              icon: const Icon(Icons.search),
              tooltip: 'Search expenses',
              onPressed: () => setState(() => _isSearching = true),
            ),
            PopupMenuButton<ExpenseSortOption>(
              key: const Key('sort_expenses_menu_btn'),
              icon: const Icon(Icons.sort),
              tooltip: 'Sort by',
              initialValue: _criteria.sortOption,
              onSelected: (option) {
                setState(() {
                  _criteria = _criteria.copyWith(sortOption: option);
                });
              },
              itemBuilder: (context) => ExpenseSortOption.values.map((option) {
                final isSelected = option == _criteria.sortOption;
                return PopupMenuItem(
                  value: option,
                  child: Row(
                    children: [
                      if (isSelected)
                        Icon(Icons.check, size: 18, color: theme.colorScheme.primary)
                      else
                        const SizedBox(width: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          option.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_expense_fab'),
        onPressed: () => context.push('/trips/${widget.trip.id}/expenses/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
      body: ResponsiveCenter(
        child: Column(
          children: [
            // Filter & Sort Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Active Sort chip (shown if not default)
                  if (_criteria.sortOption != ExpenseSortOption.dateDesc) ...[
                    InputChip(
                      avatar: const Icon(Icons.sort, size: 16),
                      label: Text(_criteria.sortOption.label),
                      selected: true,
                      onDeleted: () {
                        setState(() {
                          _criteria = _criteria.copyWith(
                            sortOption: ExpenseSortOption.dateDesc,
                          );
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Category Filter
                  FilterChip(
                    label: Text('Category: ${_criteria.category}'),
                    selected: _criteria.category != 'All',
                    onSelected: (_) {
                      _showCategoryFilterSheet();
                    },
                  ),
                  const SizedBox(width: 8),

                  // Payer Filter
                  FilterChip(
                    label: Text(
                      _criteria.paidByTravelerId == 'All'
                          ? 'Paid by: All'
                          : 'Paid by: ${travelersMap[_criteria.paidByTravelerId] ?? "Traveler"}',
                    ),
                    selected: _criteria.paidByTravelerId != 'All',
                    onSelected: (_) {
                      _showPayerFilterSheet(travelersMap);
                    },
                  ),

                  // Active Search Query chip (shown when search bar is closed)
                  if (!_isSearching && _criteria.searchQuery.trim().isNotEmpty) ...[
                    const SizedBox(width: 8),
                    InputChip(
                      avatar: const Icon(Icons.search, size: 16),
                      label: Text('"${_criteria.searchQuery.trim()}"'),
                      onDeleted: () {
                        setState(() {
                          _searchController.clear();
                          _criteria = _criteria.copyWith(searchQuery: '');
                        });
                      },
                    ),
                  ],

                  if (_criteria.hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    ActionChip(
                      label: const Text('Reset filters'),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _criteria = const ExpenseFilterCriteria();
                          _isSearching = false;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),

            // Expenses List
            Expanded(
              child: expensesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (expenses) {
                  // Apply search, filters and sorting
                  final filtered = _criteria.apply(expenses);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              expenses.isEmpty
                                  ? 'No expenses recorded yet'
                                  : 'No matching expenses found',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              expenses.isEmpty
                                  ? 'Tap "+ Add expense" below to log the first one.'
                                  : 'Try adjusting your search query or filters.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            if (_criteria.hasActiveFilters) ...[
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.filter_alt_off),
                                label: const Text('Reset search & filters'),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _criteria = const ExpenseFilterCriteria();
                                    _isSearching = false;
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final exp = filtered[index];
                    final payerName = travelersMap[exp.paidBy] ?? 'Unknown';
                    final color = _categoryColor(exp.category);

                    return Dismissible(
                      key: Key('expense_${exp.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (_) async {
                        await _deleteExpense(exp);
                        return false;
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => context.push(
                            '/trips/${widget.trip.id}/expenses/${exp.id}/edit',
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                // Category color bar
                                Container(
                                  width: 4,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Details
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exp.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          if (exp.source == 'settlement') ...[
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              margin: const EdgeInsets.only(right: 6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF10B981)
                                                    .withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'Settlement',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF10B981),
                                                ),
                                              ),
                                            ),
                                          ],
                                          Expanded(
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: DateFormat('dd MMM').format(exp.createdAt),
                                                    style: TextStyle(color: Colors.grey.shade600),
                                                  ),
                                                  const TextSpan(text: ' • '),
                                                  TextSpan(
                                                    text: exp.category,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      color: color,
                                                    ),
                                                  ),
                                                  const TextSpan(text: ' • '),
                                                  TextSpan(
                                                    text: 'Paid by $payerName',
                                                    style: TextStyle(color: Colors.grey.shade600),
                                                  ),
                                                ],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Amount & Split info
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      Money.formatRupees(exp.amountPaise),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${exp.splits.length} split',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
  }

  void _showCategoryFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All categories'),
                selected: _criteria.category == 'All',
                onTap: () {
                  setState(() {
                    _criteria = _criteria.copyWith(category: 'All');
                  });
                  Navigator.of(ctx).pop();
                },
              ),
              ...TripCategory.all.map((c) => ListTile(
                    title: Text(c.displayName),
                    selected: _criteria.category == c.key,
                    onTap: () {
                      setState(() {
                        _criteria = _criteria.copyWith(category: c.key);
                      });
                      Navigator.of(ctx).pop();
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showPayerFilterSheet(Map<String, String> travelersMap) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All payers'),
                selected: _criteria.paidByTravelerId == 'All',
                onTap: () {
                  setState(() {
                    _criteria = _criteria.copyWith(paidByTravelerId: 'All');
                  });
                  Navigator.of(ctx).pop();
                },
              ),
              ...widget.trip.travelers.map((t) => ListTile(
                    title: Text(t.name),
                    selected: _criteria.paidByTravelerId == t.id,
                    onTap: () {
                      setState(() {
                        _criteria = _criteria.copyWith(paidByTravelerId: t.id);
                      });
                      Navigator.of(ctx).pop();
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
