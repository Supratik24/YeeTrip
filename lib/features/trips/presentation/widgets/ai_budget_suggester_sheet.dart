import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/gemini_receipt_scanner_service.dart';
import '../../../../core/ml/ai_budget_suggester.dart';
import '../../../../core/money.dart';

/// Result returned when the user applies a suggested budget back to [TripSetupScreen].
class AppliedBudgetSuggestion {
  final int totalBudgetMinor;
  final Map<String, int> categoryAllocations;
  final String? updatedDestination;

  const AppliedBudgetSuggestion({
    required this.totalBudgetMinor,
    required this.categoryAllocations,
    this.updatedDestination,
  });
}

/// Bottom sheet allowing users to generate an AI/smart budget based on
/// destination, duration, group size, currency, and travel style.
class AiBudgetSuggesterSheet extends ConsumerStatefulWidget {
  final String initialDestination;
  final int initialDays;
  final int initialTravelerCount;
  final String currencyCode;

  const AiBudgetSuggesterSheet({
    super.key,
    required this.initialDestination,
    required this.initialDays,
    required this.initialTravelerCount,
    required this.currencyCode,
  });

  static Future<AppliedBudgetSuggestion?> show(
    BuildContext context, {
    required String initialDestination,
    required int initialDays,
    required int initialTravelerCount,
    required String currencyCode,
  }) {
    return showModalBottomSheet<AppliedBudgetSuggestion>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiBudgetSuggesterSheet(
        initialDestination: initialDestination,
        initialDays: initialDays,
        initialTravelerCount: initialTravelerCount,
        currencyCode: currencyCode,
      ),
    );
  }

  @override
  ConsumerState<AiBudgetSuggesterSheet> createState() =>
      _AiBudgetSuggesterSheetState();
}

class _AiBudgetSuggesterSheetState
    extends ConsumerState<AiBudgetSuggesterSheet> {
  late final TextEditingController _destController;
  TravelBudgetStyle _style = TravelBudgetStyle.balanced;
  final bool _useGeminiWhenAvailable = true;
  bool _isLoading = false;
  String? _notice;
  BudgetSuggestion? _suggestion;

  @override
  void initState() {
    super.initState();
    _destController = TextEditingController(text: widget.initialDestination);
    // Precompute instant offline suggestion immediately so user gets zero-latency feedback
    _suggestion = AiBudgetSuggesterService.suggestOffline(
      destination: widget.initialDestination,
      days: widget.initialDays,
      travelerCount: widget.initialTravelerCount,
      currencyCode: widget.currencyCode,
      style: _style,
    );
  }

  @override
  void dispose() {
    _destController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final service = ref.read(aiBudgetSuggesterServiceProvider);
    setState(() {
      _isLoading = true;
      _notice = null;
    });

    try {
      final result = await service.suggestBudget(
        destination: _destController.text.trim(),
        days: widget.initialDays,
        travelerCount: widget.initialTravelerCount,
        currencyCode: widget.currencyCode,
        style: _style,
        preferAi: _useGeminiWhenAvailable && service.hasApiKey,
      );
      if (!mounted) return;
      setState(() {
        _suggestion = result;
        _notice = result.isAiGenerated
            ? 'Generated with Gemini AI'
            : null;
      });
    } on AiBudgetException catch (e) {
      if (!mounted) return;
      final fallback = AiBudgetSuggesterService.suggestOffline(
        destination: _destController.text.trim(),
        days: widget.initialDays,
        travelerCount: widget.initialTravelerCount,
        currencyCode: widget.currencyCode,
        style: _style,
      );
      setState(() {
        _suggestion = fallback;
        _notice = 'Gemini unavailable (${e.message}). Showing Smart Estimate.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _configureGeminiKey() async {
    final controller = TextEditingController(
      text: ref.read(geminiApiKeyProvider) ?? '',
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber),
            SizedBox(width: 8),
            Expanded(child: Text('Gemini AI API Key')),
          ],
        ),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Google Gemini API Key',
            hintText: 'AIzaSy...',
            prefixIcon: Icon(Icons.key),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(geminiApiKeyProvider.notifier)
                  .setKey(controller.text.trim());
              if (ctx.mounted) Navigator.of(ctx).pop(true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (saved == true && mounted) {
      await _generate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasKey = ref.watch(aiBudgetSuggesterServiceProvider).hasApiKey;
    final suggestion = _suggestion;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI Budget Suggester',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  key: const Key('ai_budget_sheet_listview'),
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextField(
                      key: const Key('suggester_destination_field'),
                      controller: _destController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                        hintText: 'e.g. Goa, Manali, Bali, Europe',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      onChanged: (_) => _generateOfflineLive(),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.calendar_today, size: 14),
                          label: Text('${widget.initialDays} days'),
                        ),
                        Chip(
                          avatar: const Icon(Icons.group_outlined, size: 14),
                          label: Text('${widget.initialTravelerCount} travelers'),
                        ),
                        Chip(
                          avatar: const Icon(Icons.currency_exchange, size: 14),
                          label: Text(widget.currencyCode),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Travel Style',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<TravelBudgetStyle>(
                      key: const Key('budget_style_segmented'),
                      segments: TravelBudgetStyle.values
                          .map(
                            (s) => ButtonSegment<TravelBudgetStyle>(
                              value: s,
                              label: Text(s.label),
                            ),
                          )
                          .toList(),
                      selected: {_style},
                      onSelectionChanged: (set) {
                        setState(() => _style = set.first);
                        _generateOfflineLive();
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _configureGeminiKey,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: hasKey
                                    ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                                    : colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    hasKey ? Icons.verified : Icons.vpn_key_outlined,
                                    size: 16,
                                    color: hasKey
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      hasKey
                                          ? 'Gemini AI Connected (tap to update key)'
                                          : 'Smart Offline Mode • Add Gemini key for AI mode',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (hasKey) ...[
                          const SizedBox(width: 8),
                          FilledButton.tonalIcon(
                            key: const Key('generate_ai_budget_btn'),
                            onPressed: _isLoading ? null : _generate,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.auto_awesome, size: 16),
                            label: const Text('Ask AI'),
                          ),
                        ],
                      ],
                    ),
                    if (_notice != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _notice!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (suggestion != null)
                      Card(
                        key: const Key('ai_budget_preview_card'),
                        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    suggestion.isAiGenerated
                                        ? 'GEMINI AI ESTIMATE'
                                        : 'SMART DESTINATION ESTIMATE',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  Text(
                                    '${Money.formatAmount(suggestion.dailyPerPersonMinor, currencyCode: suggestion.currencyCode)}/person/day',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                Money.formatAmount(
                                  suggestion.totalBudgetMinor,
                                  currencyCode: suggestion.currencyCode,
                                ),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                suggestion.reasoning,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: suggestion.categoryAllocations.entries
                                    .where((e) => e.value > 0)
                                    .map(
                                      (e) => Chip(
                                        visualDensity: VisualDensity.compact,
                                        label: Text('${e.key} ${e.value}%'),
                                      ),
                                    )
                                    .toList(),
                              ),
                              if (suggestion.tips.isNotEmpty) ...[
                                const Divider(height: 20),
                                ...suggestion.tips.map(
                                  (tip) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.tips_and_updates_outlined,
                                          size: 14,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            tip,
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      key: const Key('apply_ai_budget_btn'),
                      onPressed: suggestion == null
                          ? null
                          : () {
                              Navigator.of(context).pop(
                                AppliedBudgetSuggestion(
                                  totalBudgetMinor: suggestion.totalBudgetMinor,
                                  categoryAllocations:
                                      suggestion.categoryAllocations,
                                  updatedDestination:
                                      _destController.text.trim().isNotEmpty
                                          ? _destController.text.trim()
                                          : null,
                                ),
                              );
                            },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Apply Suggested Budget'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _generateOfflineLive() {
    setState(() {
      _notice = null;
      _suggestion = AiBudgetSuggesterService.suggestOffline(
        destination: _destController.text.trim(),
        days: widget.initialDays,
        travelerCount: widget.initialTravelerCount,
        currencyCode: widget.currencyCode,
        style: _style,
      );
    });
  }
}
