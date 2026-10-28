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
import '../../domain/split_calculator.dart';

/// Screen to add or edit an expense with 4 split modes.
class AddEditExpenseScreen extends ConsumerStatefulWidget {
  final String tripId;
  final String? expenseId;

  const AddEditExpenseScreen({
    super.key,
    required this.tripId,
    this.expenseId,
  });

  @override
  ConsumerState<AddEditExpenseScreen> createState() =>
      _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends ConsumerState<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedCategory = TripCategory.stay.key;
  String? _paidByTravelerId;
  DateTime _selectedDate = DateTime.now();
  SplitMode _splitMode = SplitMode.equal;

  // Split state per traveler
  final Set<String> _equalIncludedTravelers = {};
  final Map<String, TextEditingController> _exactControllers = {};
  final Map<String, TextEditingController> _percentControllers = {};
  final Map<String, int> _sharesWeights = {};

  String? _splitError;
  bool _isSaving = false;
  bool _initializedFromExisting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    for (final c in _exactControllers.values) {
      c.dispose();
    }
    for (final c in _percentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initTravelers(List<Traveler> travelers, [ExpenseWithSplits? existing]) {
    if (travelers.isEmpty) return;

    _paidByTravelerId ??= existing?.paidBy ?? travelers.first.id;

    if (!_initializedFromExisting) {
      if (existing != null) {
        _descriptionController.text = existing.description;
        _amountController.text =
            Money.paiseToDecimalString(existing.amountPaise);
        _selectedCategory = existing.category;
        _selectedDate = existing.createdAt;
        _paidByTravelerId = existing.paidBy;

        // Populate splits
        for (final split in existing.splits) {
          _equalIncludedTravelers.add(split.travelerId);
        }
      } else {
        _equalIncludedTravelers.addAll(travelers.map((t) => t.id));
      }

      for (final t in travelers) {
        _exactControllers.putIfAbsent(
          t.id,
          () => TextEditingController(
            text: existing != null
                ? Money.paiseToDecimalString(
                    existing.splits
                        .firstWhere(
                          (s) => s.travelerId == t.id,
                          orElse: () => ExpenseSplitModel(
                            expenseId: '',
                            travelerId: t.id,
                            sharePaise: 0,
                          ),
                        )
                        .sharePaise,
                  )
                : '0',
          ),
        );

        final equalP = (100.0 / travelers.length).toStringAsFixed(1);
        _percentControllers.putIfAbsent(
          t.id,
          () => TextEditingController(text: equalP),
        );

        _sharesWeights.putIfAbsent(t.id, () => 1);
      }
      _initializedFromExisting = true;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  List<ExpenseSplitModel> _calculateSplits(int totalPaise) {
    switch (_splitMode) {
      case SplitMode.equal:
        if (_equalIncludedTravelers.isEmpty) {
          throw ArgumentError('Select at least one person to split with');
        }
        final splitMap = SplitCalculator.calculateEqualSplit(
          totalPaise: totalPaise,
          travelerIds: _equalIncludedTravelers.toList(),
        );
        return splitMap.entries
            .map((e) => ExpenseSplitModel(
                  expenseId: widget.expenseId ?? '',
                  travelerId: e.key,
                  sharePaise: e.value,
                ))
            .toList();

      case SplitMode.exact:
        final exactMap = <String, int>{};
        for (final entry in _exactControllers.entries) {
          final text = entry.value.text.trim();
          exactMap[entry.key] =
              text.isEmpty ? 0 : Money.decimalStringToPaise(text);
        }
        final validationErr = SplitCalculator.validateExactSplit(
          totalPaise: totalPaise,
          exactSharesPaise: exactMap,
        );
        if (validationErr != null) {
          throw ArgumentError(validationErr);
        }
        return exactMap.entries
            .where((e) => e.value > 0)
            .map((e) => ExpenseSplitModel(
                  expenseId: widget.expenseId ?? '',
                  travelerId: e.key,
                  sharePaise: e.value,
                ))
            .toList();

      case SplitMode.percentage:
        final percentMap = <String, double>{};
        for (final entry in _percentControllers.entries) {
          percentMap[entry.key] = double.tryParse(entry.value.text.trim()) ?? 0;
        }
        final sumP = percentMap.values.fold<double>(0, (s, v) => s + v);
        if ((sumP - 100.0).abs() > 0.01) {
          throw ArgumentError(
            'Percentages sum to ${sumP.toStringAsFixed(1)}%, but must equal 100%',
          );
        }
        final splitMap = SplitCalculator.calculatePercentageSplit(
          totalPaise: totalPaise,
          percentages: percentMap,
        );
        return splitMap.entries
            .where((e) => e.value > 0)
            .map((e) => ExpenseSplitModel(
                  expenseId: widget.expenseId ?? '',
                  travelerId: e.key,
                  sharePaise: e.value,
                ))
            .toList();

      case SplitMode.shares:
        final splitMap = SplitCalculator.calculateSharesSplit(
          totalPaise: totalPaise,
          weights: _sharesWeights,
        );
        return splitMap.entries
            .where((e) => e.value > 0)
            .map((e) => ExpenseSplitModel(
                  expenseId: widget.expenseId ?? '',
                  travelerId: e.key,
                  sharePaise: e.value,
                ))
            .toList();
    }
  }

  Future<void> _save() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk) return;

    setState(() {
      _splitError = null;
      _isSaving = true;
    });

    try {
      final amountPaise = Money.decimalStringToPaise(_amountController.text);
      final splits = _calculateSplits(amountPaise);

      final expenseRepo = ref.read(expenseRepositoryProvider);

      if (widget.expenseId == null) {
        await expenseRepo.addExpense(
          tripId: widget.tripId,
          description: _descriptionController.text.trim(),
          amountPaise: amountPaise,
          category: _selectedCategory,
          paidBy: _paidByTravelerId!,
          createdAt: _selectedDate,
          splits: splits,
        );
      } else {
        await expenseRepo.updateExpense(
          expenseId: widget.expenseId!,
          description: _descriptionController.text.trim(),
          amountPaise: amountPaise,
          category: _selectedCategory,
          paidBy: _paidByTravelerId!,
          createdAt: _selectedDate,
          splits: splits,
        );
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      setState(() {
        _splitError = e.toString().replaceFirst('ArgumentError: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _delete() async {
    if (widget.expenseId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete expense?'),
        content: const Text('This will permanently delete this expense.'),
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
      await ref
          .read(expenseRepositoryProvider)
          .deleteExpense(widget.expenseId!);
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final theme = Theme.of(context);

    return tripAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Expense')),
        body: Center(child: Text('Error: $err')),
      ),
      data: (trip) {
        if (trip == null) {
          return const Scaffold(body: Center(child: Text('Trip not found')));
        }

        final travelers = trip.travelers;

        // If editing, find existing expense
        ExpenseWithSplits? existingExpense;
        if (widget.expenseId != null) {
          final expensesAsync =
              ref.watch(tripExpensesProvider(widget.tripId));
          existingExpense = expensesAsync.asData?.value.firstWhere(
            (e) => e.id == widget.expenseId,
            orElse: () => ExpenseWithSplits(
              id: '',
              tripId: '',
              description: '',
              amountPaise: 0,
              category: '',
              paidBy: '',
              createdAt: DateTime.now(),
            ),
          );
        }

        _initTravelers(travelers, existingExpense);

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.expenseId == null ? 'Add expense' : 'Edit expense'),
            actions: [
              if (widget.expenseId != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _delete,
                  tooltip: 'Delete expense',
                ),
            ],
          ),
          body: ResponsiveCenter(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
              children: [
                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g. Seafood lunch, Taxi fare',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Amount & Date
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount (₹)',
                          hintText: 'e.g. 2,400.50',
                          prefixText: '₹ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Amount is required';
                          }
                          try {
                            final paise = Money.decimalStringToPaise(val);
                            if (paise <= 0) {
                              return 'Must be greater than zero';
                            }
                          } catch (_) {
                            return 'Invalid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(8),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            suffixIcon: Icon(Icons.calendar_today, size: 16),
                          ),
                          child: Text(
                            DateFormat('dd MMM').format(_selectedDate),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Category selector
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  items: TripCategory.all.map((cat) {
                    return DropdownMenuItem(
                      value: cat.key,
                      child: Text(cat.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Paid by selector
                DropdownButtonFormField<String>(
                  initialValue: _paidByTravelerId,
                  decoration: const InputDecoration(
                    labelText: 'Paid by',
                  ),
                  items: travelers.map((t) {
                    return DropdownMenuItem(
                      value: t.id,
                      child: Text(t.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _paidByTravelerId = val);
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Split Mode Tabs
                Text(
                  'Split method',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<SplitMode>(
                  segments: const [
                    ButtonSegment(
                      value: SplitMode.equal,
                      label: Text('Equal'),
                    ),
                    ButtonSegment(
                      value: SplitMode.exact,
                      label: Text('Exact'),
                    ),
                    ButtonSegment(
                      value: SplitMode.percentage,
                      label: Text('%'),
                    ),
                    ButtonSegment(
                      value: SplitMode.shares,
                      label: Text('Shares'),
                    ),
                  ],
                  selected: {_splitMode},
                  onSelectionChanged: (set) {
                    setState(() {
                      _splitMode = set.first;
                      _splitError = null;
                    });
                  },
                ),
                const SizedBox(height: 16),

                if (_splitError != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _splitError!,
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Split mode specific inputs
                _buildSplitSection(travelers),

                const SizedBox(height: 24),

                // Submit button
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.expenseId == null ? 'Add expense' : 'Save changes'),
                ),
              ],
            ),
          ),
        ),
      );
      },
    );
  }

  Widget _buildSplitSection(List<Traveler> travelers) {
    switch (_splitMode) {
      case SplitMode.equal:
        return Column(
          children: travelers.map((t) {
            final isIncluded = _equalIncludedTravelers.contains(t.id);
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.name),
              value: isIncluded,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _equalIncludedTravelers.add(t.id);
                  } else {
                    if (_equalIncludedTravelers.length > 1) {
                      _equalIncludedTravelers.remove(t.id);
                    }
                  }
                });
              },
            );
          }).toList(),
        );

      case SplitMode.exact:
        return Column(
          children: travelers.map((t) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(t.name, style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _exactControllers[t.id],
                      decoration: const InputDecoration(
                        prefixText: '₹ ',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case SplitMode.percentage:
        return Column(
          children: travelers.map((t) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(t.name, style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _percentControllers[t.id],
                      decoration: const InputDecoration(
                        suffixText: '%',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case SplitMode.shares:
        return Column(
          children: travelers.map((t) {
            final weight = _sharesWeights[t.id] ?? 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(t.name, style: const TextStyle(fontSize: 14)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: weight > 1
                        ? () => setState(
                            () => _sharesWeights[t.id] = weight - 1)
                        : null,
                  ),
                  Text(
                    '$weight',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () =>
                        setState(() => _sharesWeights[t.id] = weight + 1),
                  ),
                ],
              ),
            );
          }).toList(),
        );
    }
  }
}
