import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/categories.dart';
import '../../../../core/money.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../data/providers.dart';
import '../../../trips/domain/trip_model.dart';
import '../../domain/rebalance.dart';

/// Screen with 6 category sliders that rebalance to always sum to 100%.
class BudgetSlidersScreen extends ConsumerStatefulWidget {
  final TripWithDetails trip;

  const BudgetSlidersScreen({
    super.key,
    required this.trip,
  });

  @override
  ConsumerState<BudgetSlidersScreen> createState() =>
      _BudgetSlidersScreenState();
}

class _BudgetSlidersScreenState extends ConsumerState<BudgetSlidersScreen> {
  late Map<String, int> _allocations;
  Map<String, int>? _dragStartAllocations;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initAllocations();
  }

  @override
  void didUpdateWidget(covariant BudgetSlidersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapEquals(oldWidget.trip.categoryAllocations,
            widget.trip.categoryAllocations) &&
        !_hasChanges &&
        _dragStartAllocations == null) {
      _initAllocations();
    }
  }

  void _initAllocations() {
    _allocations = BudgetRebalancer.normalizeAllocations(
      widget.trip.categoryAllocations.isNotEmpty
          ? widget.trip.categoryAllocations
          : TripCategory.defaultPercentages,
    );
    _dragStartAllocations = null;
    _hasChanges = false;
  }

  void _onSliderChangeStart(String category, double value) {
    _dragStartAllocations = Map<String, int>.from(_allocations);
  }

  void _onSliderChanged(String category, double value) {
    final intValue = value.round();
    if (_allocations[category] == intValue) return;

    setState(() {
      _allocations = BudgetRebalancer.rebalance(
        currentAllocations: _dragStartAllocations ?? _allocations,
        changedCategory: category,
        newPercent: intValue,
      );
      _hasChanges = true;
    });
  }

  void _onSliderChangeEnd(String category, double value) {
    _dragStartAllocations = null;
    if (_hasChanges) {
      _saveAllocations(silent: true);
    }
  }

  void _resetToDefaults() {
    setState(() {
      _allocations = Map.from(TripCategory.defaultPercentages);
      _dragStartAllocations = null;
      _hasChanges = true;
    });
    _saveAllocations(silent: true);
  }

  Future<void> _saveAllocations({bool silent = false}) async {
    final snapshot = Map<String, int>.from(_allocations);
    if (!silent) {
      setState(() => _isSaving = true);
    }
    try {
      await ref
          .read(tripRepositoryProvider)
          .updateCategoryAllocations(widget.trip.id, snapshot);
      if (mounted) {
        final stillMatches = mapEquals(_allocations, snapshot);
        setState(() {
          if (stillMatches) {
            _hasChanges = false;
          }
          _isSaving = false;
        });
        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Budget distribution saved')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving: $e')),
          );
        }
      }
    }
  }

  Color _categoryColor(String key, ThemeData theme) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trip = widget.trip;
    final totalBudget = trip.totalBudgetPaise;
    final travelersCount = trip.travelers.isEmpty ? 1 : trip.travelers.length;
    final daysCount = trip.days <= 0 ? 1 : trip.days;

    final totalPercent =
        _allocations.values.fold<int>(0, (sum, val) => sum + val);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget distribution'),
        actions: [
          TextButton(
            onPressed: _resetToDefaults,
            child: const Text('Reset'),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _hasChanges && !_isSaving ? () => _saveAllocations() : null,
            icon: _isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_hasChanges ? Icons.save_outlined : Icons.check_circle_outline),
            label: Text(_hasChanges ? 'Save changes' : 'All changes saved'),
          ),
        ),
      ),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          // Total check header
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total allocation',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Money.formatAmount(
                          totalBudget,
                          currencyCode: trip.currency,
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: totalPercent == 100
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$totalPercent%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: totalPercent == 100
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Six category sliders
          ...TripCategory.all.map((cat) {
            final percent = _allocations[cat.key] ?? 0;
            final catBudget = (totalBudget * percent) ~/ 100;
            final perPerson = catBudget ~/ travelersCount;
            final perDay = catBudget ~/ daysCount;
            final color = _categoryColor(cat.key, theme);

            return Card(
              key: ValueKey(cat.key),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and percent badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cat.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$percent%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: color,
                        thumbColor: color,
                        overlayColor: color.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: percent.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChangeStart: (v) => _onSliderChangeStart(cat.key, v),
                        onChanged: (v) => _onSliderChanged(cat.key, v),
                        onChangeEnd: (v) => _onSliderChangeEnd(cat.key, v),
                      ),
                    ),

                    // Total, per person, per day breakdown
                    Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            label: 'Total',
                            value: Money.formatAmount(
                              catBudget,
                              currencyCode: trip.currency,
                            ),
                            alignment: CrossAxisAlignment.start,
                          ),
                        ),
                        Expanded(
                          child: _StatItem(
                            label: 'Per person',
                            value: Money.formatAmount(
                              perPerson,
                              currencyCode: trip.currency,
                            ),
                            alignment: CrossAxisAlignment.center,
                          ),
                        ),
                        Expanded(
                          child: _StatItem(
                            label: 'Per day',
                            value: Money.formatAmount(
                              perDay,
                              currencyCode: trip.currency,
                            ),
                            alignment: CrossAxisAlignment.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    ),
  );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  const _StatItem({
    required this.label,
    required this.value,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
