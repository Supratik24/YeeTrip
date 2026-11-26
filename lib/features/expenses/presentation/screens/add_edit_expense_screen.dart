import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/categories.dart';
import '../../../../core/constants/currencies.dart';
import '../../../../core/ml/ml_providers.dart';
import '../../../../core/ml/smart_categorizer.dart';
import '../../../../core/money.dart';
import '../../../../core/notifications/notification_providers.dart';
import '../../../../core/services/local_image_store.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../data/providers.dart';
import '../../../trips/domain/trip_model.dart';
import '../../domain/expense_model.dart';
import '../../domain/split_calculator.dart';
import '../widgets/expense_comments_sheet.dart';
import '../widgets/receipt_preview_dialog.dart';
import '../widgets/receipt_scanner_sheet.dart';

/// Screen to add or edit an expense with 4 split modes, tags, notes, multi-currency conversion, and comments.
class AddEditExpenseScreen extends ConsumerStatefulWidget {
  final String tripId;
  final String? expenseId;
  final String? initialDescription;
  final String? initialCategory;
  final String? initialAmountDecimal;
  final String? initialNotes;

  const AddEditExpenseScreen({
    super.key,
    required this.tripId,
    this.expenseId,
    this.initialDescription,
    this.initialCategory,
    this.initialAmountDecimal,
    this.initialNotes,
  });

  @override
  ConsumerState<AddEditExpenseScreen> createState() =>
      _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends ConsumerState<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _customTagController = TextEditingController();
  final _foreignAmountController = TextEditingController();
  final _exchangeRateController = TextEditingController();

  static const List<String> _presetTags = [
    'lunch',
    'dinner',
    'breakfast',
    'optional',
    'reimbursable',
    'shared',
    'cash',
    'ticket',
  ];

  String _selectedCategory = TripCategory.stay.key;
  String? _paidByTravelerId;
  DateTime _selectedDate = DateTime.now();
  SplitMode _splitMode = SplitMode.equal;
  final List<String> _selectedTags = [];

  // Optional foreign currency conversion state
  bool _useForeignCurrency = false;
  String _foreignCurrencyCode = 'USD';

  // Split state per traveler
  final Set<String> _equalIncludedTravelers = {};
  final Map<String, TextEditingController> _exactControllers = {};
  final Map<String, TextEditingController> _percentControllers = {};
  final Map<String, int> _sharesWeights = {};

  String? _receiptImagePath;
  bool _clearReceiptImage = false;
  String? _splitError;
  bool _isSaving = false;
  bool _initializedFromExisting = false;
  bool _hasManuallyChangedCategory = false;
  CategoryPrediction? _smartPrediction;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_onDescriptionChanged);
    if (widget.expenseId == null) {
      if (widget.initialDescription != null &&
          widget.initialDescription!.isNotEmpty) {
        _descriptionController.text = widget.initialDescription!;
      }
      if (widget.initialCategory != null &&
          TripCategory.all.any((c) => c.key == widget.initialCategory)) {
        _selectedCategory = widget.initialCategory!;
        _hasManuallyChangedCategory = true;
      }
      if (widget.initialAmountDecimal != null &&
          widget.initialAmountDecimal!.isNotEmpty) {
        _amountController.text = widget.initialAmountDecimal!;
      }
      if (widget.initialNotes != null && widget.initialNotes!.isNotEmpty) {
        _notesController.text = widget.initialNotes!;
      }
    }
  }

  void _onDescriptionChanged() {
    final text = _descriptionController.text.trim();
    if (text.isEmpty) {
      if (_smartPrediction != null) {
        setState(() => _smartPrediction = null);
      }
      return;
    }

    final categorizer = ref.read(smartCategorizerProvider);
    final prediction = categorizer.predict(text);

    setState(() {
      _smartPrediction = prediction.confidence >= 0.40 ? prediction : null;
      if (!_hasManuallyChangedCategory &&
          prediction.isHighConfidence &&
          widget.expenseId == null) {
        _selectedCategory = prediction.categoryKey;
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_onDescriptionChanged);
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _customTagController.dispose();
    _foreignAmountController.dispose();
    _exchangeRateController.dispose();
    for (final c in _exactControllers.values) {
      c.dispose();
    }
    for (final c in _percentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initTravelers(
    TripWithDetails trip,
    List<Traveler> travelers, [
    ExpenseWithSplits? existing,
  ]) {
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
        _receiptImagePath = existing.receiptImagePath;
        _notesController.text = existing.notes ?? '';
        _selectedTags
          ..clear()
          ..addAll(existing.tags);
        if (existing.originalCurrency != null &&
            existing.originalAmountPaise != null &&
            existing.exchangeRate != null) {
          _useForeignCurrency = true;
          _foreignCurrencyCode = existing.originalCurrency!;
          _foreignAmountController.text =
              Money.paiseToDecimalString(existing.originalAmountPaise!);
          _exchangeRateController.text = existing.exchangeRate.toString();
        }

        // Populate splits
        for (final split in existing.splits) {
          _equalIncludedTravelers.add(split.travelerId);
        }
      } else {
        _equalIncludedTravelers.addAll(travelers.map((t) => t.id));
        _foreignCurrencyCode = trip.currency == 'INR' ? 'USD' : 'INR';
        _exchangeRateController.text = TripCurrency.suggestedRate(
          _foreignCurrencyCode,
          trip.currency,
        ).toString();
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

  void _recalculateForeignConversion(String tripCurrency) {
    if (!_useForeignCurrency) return;
    try {
      final rawAmt = _foreignAmountController.text.trim();
      final rate = double.tryParse(_exchangeRateController.text.trim());
      if (rawAmt.isEmpty || rate == null || rate <= 0) return;
      final sourceMinor = Money.decimalStringToPaise(rawAmt);
      final converted = Money.convertAmount(sourceMinor, exchangeRate: rate);
      _amountController.text = Money.paiseToDecimalString(converted);
    } catch (_) {}
  }

  void _addCustomTag() {
    var tag = _customTagController.text.trim();
    while (tag.startsWith('#')) {
      tag = tag.substring(1).trim();
    }
    if (tag.isEmpty) return;
    if (!_selectedTags.any((t) => t.toLowerCase() == tag.toLowerCase())) {
      setState(() => _selectedTags.add(tag));
    }
    _customTagController.clear();
  }

  void _toggleTag(String tag) {
    setState(() {
      final idx = _selectedTags.indexWhere(
        (t) => t.toLowerCase() == tag.toLowerCase(),
      );
      if (idx >= 0) {
        _selectedTags.removeAt(idx);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  List<ExpenseSplitModel> _calculateSplits(
    int totalPaise, {
    String currencyCode = 'INR',
  }) {
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
          currencyCode: currencyCode,
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

  Future<void> _save(TripWithDetails trip) async {
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk) return;

    setState(() {
      _splitError = null;
      _isSaving = true;
    });

    try {
      final amountPaise = Money.decimalStringToPaise(_amountController.text);
      final splits = _calculateSplits(amountPaise, currencyCode: trip.currency);

      String? origCurr;
      int? origAmt;
      double? exRate;
      if (_useForeignCurrency && _foreignCurrencyCode != trip.currency) {
        final rawForeign = _foreignAmountController.text.trim();
        final parsedRate =
            double.tryParse(_exchangeRateController.text.trim());
        if (rawForeign.isNotEmpty && parsedRate != null && parsedRate > 0) {
          origCurr = _foreignCurrencyCode;
          origAmt = Money.decimalStringToPaise(rawForeign);
          exRate = parsedRate;
        }
      }

      final notesText = _notesController.text.trim();
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
          receiptImagePath: _receiptImagePath,
          notes: notesText.isNotEmpty ? notesText : null,
          tags: List<String>.from(_selectedTags),
          originalCurrency: origCurr,
          originalAmountPaise: origAmt,
          exchangeRate: exRate,
        );

        // Fire instant budget threshold alert if enabled and budget crosses 80% / 100%
        final prefs = ref.read(notificationPreferencesProvider);
        if (prefs.budgetBurnAlerts && trip.totalBudgetPaise > 0) {
          final prevSpent = trip.totalSpentPaise;
          final nextSpent = prevSpent + amountPaise;
          final prevRatio = prevSpent / trip.totalBudgetPaise;
          final nextRatio = nextSpent / trip.totalBudgetPaise;
          if (nextRatio > 1.0 && prevRatio <= 1.0) {
            await ref.read(tripNotificationServiceProvider).sendInstantAlert(
                  title: 'Budget exceeded in ${trip.name}',
                  body:
                      'Total spent reached ${Money.formatAmount(nextSpent, currencyCode: trip.currency)} against ${Money.formatAmount(trip.totalBudgetPaise, currencyCode: trip.currency)} budget.',
                  payload: '/trips/${trip.id}',
                );
          } else if (nextRatio >= 0.8 && prevRatio < 0.8) {
            await ref.read(tripNotificationServiceProvider).sendInstantAlert(
                  title: '80% budget alert • ${trip.name}',
                  body:
                      '${Money.formatAmount(trip.totalBudgetPaise - nextSpent, currencyCode: trip.currency)} remaining across ${trip.days} days.',
                  payload: '/trips/${trip.id}',
                );
          }
        }
      } else {
        await expenseRepo.updateExpense(
          expenseId: widget.expenseId!,
          description: _descriptionController.text.trim(),
          amountPaise: amountPaise,
          category: _selectedCategory,
          paidBy: _paidByTravelerId!,
          createdAt: _selectedDate,
          splits: splits,
          receiptImagePath: _receiptImagePath,
          clearReceiptImage: _clearReceiptImage && _receiptImagePath == null,
          notes: notesText,
          clearNotes: notesText.isEmpty,
          tags: List<String>.from(_selectedTags),
          originalCurrency: origCurr,
          originalAmountPaise: origAmt,
          exchangeRate: exRate,
          clearOriginalCurrency: origCurr == null,
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

  Future<void> _attachBillPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 88,
      );
      if (file == null) return;
      final saved = await LocalImageStore.persistImage(
        file.path,
        folder: 'receipts',
      );
      if (mounted) {
        setState(() {
          _receiptImagePath = saved;
          _clearReceiptImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not attach photo: $e')),
        );
      }
    }
  }

  Widget _buildReceiptAttachmentCard(ThemeData theme) {
    final hasFile = _receiptImagePath != null &&
        _receiptImagePath!.isNotEmpty &&
        File(_receiptImagePath!).existsSync();

    return Container(
      key: const Key('receipt_attachment_card'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          if (hasFile)
            GestureDetector(
              onTap: () => ReceiptPreviewDialog.show(
                context,
                imagePath: _receiptImagePath!,
                title: _descriptionController.text.trim().isNotEmpty
                    ? _descriptionController.text.trim()
                    : 'Attached Bill',
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_receiptImagePath!),
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.receipt_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hasFile ? 'Bill photo attached' : 'Attach bill proof (optional)',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  hasFile
                      ? 'Tap thumbnail to zoom & inspect'
                      : 'Keep a photo with this expense',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (hasFile) ...[
            IconButton(
              key: const Key('view_attached_receipt_btn'),
              icon: const Icon(Icons.visibility_outlined),
              tooltip: 'View bill photo',
              onPressed: () => ReceiptPreviewDialog.show(
                context,
                imagePath: _receiptImagePath!,
                title: _descriptionController.text.trim().isNotEmpty
                    ? _descriptionController.text.trim()
                    : 'Attached Bill',
              ),
            ),
            IconButton(
              key: const Key('remove_attached_receipt_btn'),
              icon: const Icon(Icons.close),
              tooltip: 'Remove bill photo',
              onPressed: () => setState(() {
                _receiptImagePath = null;
                _clearReceiptImage = true;
              }),
            ),
          ] else ...[
            IconButton(
              key: const Key('attach_receipt_camera_btn'),
              icon: const Icon(Icons.camera_alt_outlined),
              tooltip: 'Take bill photo',
              onPressed: () => _attachBillPhoto(ImageSource.camera),
            ),
            IconButton(
              key: const Key('attach_receipt_gallery_btn'),
              icon: const Icon(Icons.photo_library_outlined),
              tooltip: 'Pick bill from gallery',
              onPressed: () => _attachBillPhoto(ImageSource.gallery),
            ),
          ],
        ],
      ),
    );
  }

  void _openReceiptScanner(BuildContext context) {
    ReceiptScannerSheet.show(
      context,
      onReceiptApplied: (receipt) {
        setState(() {
          if (receipt.merchantName != null && receipt.merchantName!.isNotEmpty) {
            _descriptionController.text = receipt.merchantName!;
          }
          if (receipt.amountPaise != null) {
            _amountController.text = Money.paiseToDecimalString(receipt.amountPaise!);
          }
          if (receipt.date != null) {
            _selectedDate = receipt.date!;
          }
          if (receipt.suggestedCategory.isNotEmpty) {
            _selectedCategory = receipt.suggestedCategory;
          }
          if (receipt.imagePath != null && receipt.imagePath!.isNotEmpty) {
            _receiptImagePath = receipt.imagePath;
            _clearReceiptImage = false;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Applied receipt: ${receipt.merchantName ?? "Bill"} (${receipt.amountPaise != null ? Money.formatRupees(receipt.amountPaise!) : ""})',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
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

        _initTravelers(trip, travelers, existingExpense);
        final sym = Money.symbolFor(trip.currency).trim();

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.expenseId == null ? 'Add expense' : 'Edit expense'),
            actions: [
              IconButton(
                key: const Key('appbar_scan_receipt_button'),
                icon: const Icon(Icons.document_scanner_outlined),
                onPressed: () => _openReceiptScanner(context),
                tooltip: 'Scan Receipt / Bill',
              ),
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
                // Scan Receipt Banner
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Have a bill or receipt?',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Scan to auto-fill amount & details',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonalIcon(
                        key: const Key('scan_bill_banner_button'),
                        onPressed: () => _openReceiptScanner(context),
                        icon: const Icon(Icons.document_scanner, size: 16),
                        label: const Text('Scan Bill'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ),

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
                if (_smartPrediction != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ActionChip(
                        key: const Key('smart_category_suggestion_chip'),
                        avatar: const Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: Colors.purple,
                        ),
                        label: Text(
                          'Suggested: ${_smartPrediction!.categoryKey} (${(_smartPrediction!.confidence * 100).toInt()}%)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedCategory = _smartPrediction!.categoryKey;
                            _hasManuallyChangedCategory = true;
                          });
                        },
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Amount & Date
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount ($sym)',
                          hintText: 'e.g. 2,400.50',
                          prefixText: '$sym ',
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
                const SizedBox(height: 10),

                // Optional paid-in-foreign-currency converter
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChip(
                    key: const Key('toggle_foreign_currency_chip'),
                    avatar: const Icon(Icons.currency_exchange, size: 16),
                    label: Text(
                      _useForeignCurrency
                          ? 'Converting from $_foreignCurrencyCode → ${trip.currency}'
                          : 'Paid in another currency?',
                    ),
                    selected: _useForeignCurrency,
                    onSelected: (selected) {
                      setState(() {
                        _useForeignCurrency = selected;
                        if (selected) {
                          if (_foreignCurrencyCode == trip.currency) {
                            _foreignCurrencyCode =
                                trip.currency == 'INR' ? 'USD' : 'INR';
                          }
                          if (_exchangeRateController.text.trim().isEmpty) {
                            _exchangeRateController.text =
                                TripCurrency.suggestedRate(
                              _foreignCurrencyCode,
                              trip.currency,
                            ).toString();
                          }
                          _recalculateForeignConversion(trip.currency);
                        }
                      });
                    },
                  ),
                ),
                if (_useForeignCurrency) ...[
                  const SizedBox(height: 10),
                  Container(
                    key: const Key('foreign_currency_box'),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          key: const Key('foreign_currency_dropdown'),
                          initialValue: _foreignCurrencyCode,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Paid currency',
                            isDense: true,
                          ),
                          items: TripCurrency.all
                              .where((c) => c.code != trip.currency)
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.code,
                                  child: Text(
                                    '${c.flag} ${c.code} (${c.symbol.trim()}) — ${c.name}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _foreignCurrencyCode = val;
                                _exchangeRateController.text =
                                    TripCurrency.suggestedRate(
                                  val,
                                  trip.currency,
                                ).toString();
                                _recalculateForeignConversion(trip.currency);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                key: const Key('foreign_amount_field'),
                                controller: _foreignAmountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Original amount',
                                  prefixText:
                                      '${Money.symbolFor(_foreignCurrencyCode).trim()} ',
                                  isDense: true,
                                ),
                                onChanged: (_) =>
                                    _recalculateForeignConversion(trip.currency),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                key: const Key('foreign_rate_field'),
                                controller: _exchangeRateController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  labelText:
                                      '1 $_foreignCurrencyCode = ${trip.currency}',
                                  isDense: true,
                                ),
                                onChanged: (_) =>
                                    _recalculateForeignConversion(trip.currency),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Category selector
                DropdownButtonFormField<String>(
                  key: ValueKey(_selectedCategory),
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
                      setState(() {
                        _selectedCategory = val;
                        _hasManuallyChangedCategory = true;
                      });
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
                const SizedBox(height: 16),

                // Receipt photo attachment
                _buildReceiptAttachmentCard(theme),
                const SizedBox(height: 16),

                // Tags section
                Text(
                  'Tags (optional)',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ..._presetTags.map((tag) {
                      final selected = _selectedTags
                          .any((t) => t.toLowerCase() == tag.toLowerCase());
                      return FilterChip(
                        key: Key('tag_chip_$tag'),
                        label: Text('#$tag'),
                        selected: selected,
                        onSelected: (_) => _toggleTag(tag),
                        visualDensity: VisualDensity.compact,
                      );
                    }),
                    ..._selectedTags
                        .where((t) => !_presetTags.contains(t.toLowerCase()))
                        .map(
                          (custom) => InputChip(
                            label: Text('#$custom'),
                            selected: true,
                            onDeleted: () => _toggleTag(custom),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('custom_tag_field'),
                        controller: _customTagController,
                        decoration: const InputDecoration(
                          labelText: 'Add custom tag',
                          hintText: 'e.g. beach-shack, cab',
                          prefixText: '#',
                          isDense: true,
                        ),
                        onSubmitted: (_) => _addCustomTag(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      key: const Key('add_custom_tag_btn'),
                      onPressed: _addCustomTag,
                      icon: const Icon(Icons.add),
                      tooltip: 'Add tag',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Free-text Notes
                TextFormField(
                  key: const Key('expense_notes_field'),
                  controller: _notesController,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Add details, coupon used, or split reason...',
                    prefixIcon: Icon(Icons.notes_outlined, size: 20),
                  ),
                ),

                if (existingExpense != null && existingExpense.id.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    key: const Key('open_expense_comments_btn'),
                    onPressed: () => ExpenseCommentsSheet.show(
                      context,
                      trip: trip,
                      expense: existingExpense!,
                    ),
                    icon: Icon(
                      existingExpense.openDisputeCount > 0
                          ? Icons.flag
                          : Icons.forum_outlined,
                      color: existingExpense.openDisputeCount > 0
                          ? theme.colorScheme.error
                          : null,
                    ),
                    label: Text(
                      existingExpense.openDisputeCount > 0
                          ? 'Comments & Disputes (${existingExpense.commentCount} • ${existingExpense.openDisputeCount} open)'
                          : existingExpense.commentCount > 0
                              ? 'Comments (${existingExpense.commentCount})'
                              : 'Comments & Disputes',
                    ),
                  ),
                ],
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
                _buildSplitSection(travelers, sym),

                const SizedBox(height: 24),

                // Submit button
                FilledButton(
                  onPressed: _isSaving ? null : () => _save(trip),
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

  Widget _buildSplitSection(List<Traveler> travelers, String currencySymbol) {
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
                      decoration: InputDecoration(
                        prefixText: '$currencySymbol ',
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
