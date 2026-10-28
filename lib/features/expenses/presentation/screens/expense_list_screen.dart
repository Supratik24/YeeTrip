import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/categories.dart';
import '../../../../core/money.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../data/providers.dart';
import '../../../trips/domain/trip_model.dart';
import '../../domain/expense_model.dart';

/// Screen listing all trip expenses with category and payer filters.
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
  String _selectedCategoryFilter = 'All';
  String _selectedPayerFilter = 'All';

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
        title: const Text('Expenses'),
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
            // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Category Filter
                FilterChip(
                  label: Text('Category: $_selectedCategoryFilter'),
                  selected: _selectedCategoryFilter != 'All',
                  onSelected: (_) {
                    _showCategoryFilterSheet();
                  },
                ),
                const SizedBox(width: 8),

                // Payer Filter
                FilterChip(
                  label: Text(
                    _selectedPayerFilter == 'All'
                        ? 'Paid by: All'
                        : 'Paid by: ${travelersMap[_selectedPayerFilter] ?? "Traveler"}',
                  ),
                  selected: _selectedPayerFilter != 'All',
                  onSelected: (_) {
                    _showPayerFilterSheet(travelersMap);
                  },
                ),

                if (_selectedCategoryFilter != 'All' ||
                    _selectedPayerFilter != 'All') ...[
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('Clear filters'),
                    onPressed: () {
                      setState(() {
                        _selectedCategoryFilter = 'All';
                        _selectedPayerFilter = 'All';
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
                // Apply filters
                final filtered = expenses.where((e) {
                  if (_selectedCategoryFilter != 'All' &&
                      e.category != _selectedCategoryFilter) {
                    return false;
                  }
                  if (_selectedPayerFilter != 'All' &&
                      e.paidBy != _selectedPayerFilter) {
                    return false;
                  }
                  return true;
                }).toList();

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
                                : 'No expenses match the filters',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            expenses.isEmpty
                                ? 'Tap "+ Add expense" below to log the first one.'
                                : 'Try changing or clearing your filters.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exp.description,
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
                                          Text(
                                            DateFormat('dd MMM').format(exp.createdAt),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const Text(' • '),
                                          Text(
                                            exp.category,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: color,
                                            ),
                                          ),
                                          const Text(' • '),
                                          Expanded(
                                            child: Text(
                                              'Paid by $payerName',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
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
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All categories'),
              selected: _selectedCategoryFilter == 'All',
              onTap: () {
                setState(() => _selectedCategoryFilter = 'All');
                Navigator.of(ctx).pop();
              },
            ),
            ...TripCategory.all.map((c) => ListTile(
                  title: Text(c.displayName),
                  selected: _selectedCategoryFilter == c.key,
                  onTap: () {
                    setState(() => _selectedCategoryFilter = c.key);
                    Navigator.of(ctx).pop();
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showPayerFilterSheet(Map<String, String> travelersMap) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All payers'),
              selected: _selectedPayerFilter == 'All',
              onTap: () {
                setState(() => _selectedPayerFilter = 'All');
                Navigator.of(ctx).pop();
              },
            ),
            ...widget.trip.travelers.map((t) => ListTile(
                  title: Text(t.name),
                  selected: _selectedPayerFilter == t.id,
                  onTap: () {
                    setState(() => _selectedPayerFilter = t.id);
                    Navigator.of(ctx).pop();
                  },
                )),
          ],
        ),
      ),
    );
  }
}
