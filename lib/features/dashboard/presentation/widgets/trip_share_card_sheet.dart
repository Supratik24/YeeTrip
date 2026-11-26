import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/money.dart';
import '../../../expenses/domain/expense_model.dart';
import '../../../settle/domain/settle_calculator.dart';
import '../../../trips/domain/trip_model.dart';

/// Card visual themes for social group-chat sharing.
enum ShareCardTheme {
  oceanTeal(
    'Teal',
    [Color(0xFF0F766E), Color(0xFF134E4A)],
    Color(0xFF5EEAD4),
  ),
  midnightPro(
    'Dark',
    [Color(0xFF0F172A), Color(0xFF1E293B)],
    Color(0xFF38BDF8),
  ),
  sunsetAmber(
    'Sunset',
    [Color(0xFF7C2D12), Color(0xFFB45309)],
    Color(0xFFFDE68A),
  );

  final String label;
  final List<Color> gradient;
  final Color accent;

  const ShareCardTheme(this.label, this.gradient, this.accent);
}

/// Pure formatting helper for WhatsApp / Telegram text summaries alongside share cards.
class TripShareCardFormatter {
  TripShareCardFormatter._();

  static String buildTextSummary({
    required TripWithDetails trip,
    required List<ExpenseWithSplits> expenses,
    required List<SettlementPayment> settlements,
  }) {
    final activeExpenses =
        expenses.where((e) => e.confirmed && e.source != 'settlement').toList();
    final totalSpent =
        activeExpenses.fold<int>(0, (sum, e) => sum + e.amountPaise);
    final remaining = trip.totalBudgetPaise - totalSpent;

    final catMap = <String, int>{};
    for (final exp in activeExpenses) {
      catMap[exp.category] = (catMap[exp.category] ?? 0) + exp.amountPaise;
    }
    final topCats = catMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final travelerNames = {
      for (final t in trip.travelers) t.id: t.name,
    };

    final buf = StringBuffer()
      ..writeln('*${trip.name}* — YeeTrip Summary')
      ..writeln(
        '${trip.days} day(s) • ${trip.travelers.length} traveler(s)${trip.destination != null && trip.destination!.trim().isNotEmpty ? " • ${trip.destination!.trim()}" : ""}',
      )
      ..writeln(
        'Spent: ${Money.formatAmount(totalSpent, currencyCode: trip.currency)} / ${Money.formatAmount(trip.totalBudgetPaise, currencyCode: trip.currency)} (${remaining < 0 ? "Over by ${Money.formatAmount(remaining.abs(), currencyCode: trip.currency)}" : "${Money.formatAmount(remaining, currencyCode: trip.currency)} left"})',
      );

    if (topCats.isNotEmpty) {
      buf.writeln('\nTop categories:');
      for (final c in topCats.take(3)) {
        buf.writeln(
          '• ${c.key}: ${Money.formatAmount(c.value, currencyCode: trip.currency)}',
        );
      }
    }

    if (settlements.isEmpty) {
      buf.writeln('\nSettlement: All squared up!');
    } else {
      buf.writeln('\nPending settlements:');
      for (final s in settlements.take(5)) {
        final from = travelerNames[s.fromTravelerId] ?? 'Member';
        final to = travelerNames[s.toTravelerId] ?? 'Member';
        buf.writeln(
          '• $from → $to: ${Money.formatAmount(s.amountPaise, currencyCode: trip.currency)}',
        );
      }
    }

    return buf.toString().trim();
  }
}

/// Modal preview sheet that renders a high-contrast shareable summary card and
/// exports it as a PNG image (or text) for WhatsApp / Telegram group chats.
class TripShareCardSheet extends StatefulWidget {
  final TripWithDetails trip;
  final List<ExpenseWithSplits> expenses;
  final Future<void> Function(Uint8List pngBytes, String text)?
      onShareImageOverride;
  final Future<void> Function(String text)? onShareTextOverride;

  const TripShareCardSheet({
    super.key,
    required this.trip,
    required this.expenses,
    this.onShareImageOverride,
    this.onShareTextOverride,
  });

  static Future<void> show(
    BuildContext context, {
    required TripWithDetails trip,
    required List<ExpenseWithSplits> expenses,
    Future<void> Function(Uint8List pngBytes, String text)?
        onShareImageOverride,
    Future<void> Function(String text)? onShareTextOverride,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TripShareCardSheet(
        trip: trip,
        expenses: expenses,
        onShareImageOverride: onShareImageOverride,
        onShareTextOverride: onShareTextOverride,
      ),
    );
  }

  @override
  State<TripShareCardSheet> createState() => _TripShareCardSheetState();
}

class _TripShareCardSheetState extends State<TripShareCardSheet> {
  final _posterKey = GlobalKey();
  ShareCardTheme _selectedTheme = ShareCardTheme.oceanTeal;
  bool _isSharing = false;

  Future<void> _shareAsImage(String textSummary) async {
    setState(() => _isSharing = true);
    try {
      final boundary = _posterKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('Share card is not ready yet');
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) {
        throw StateError('Could not encode card image');
      }
      final bytes = byteData.buffer.asUint8List();

      if (widget.onShareImageOverride != null) {
        await widget.onShareImageOverride!(bytes, textSummary);
      } else {
        final safeName = widget.trip.name
            .replaceAll(RegExp(r'[^\w\s]+'), '')
            .trim()
            .replaceAll(' ', '_');
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(
                bytes,
                mimeType: 'image/png',
                name: 'yeetrip_${safeName.isEmpty ? "summary" : safeName}.png',
              ),
            ],
            text: textSummary,
            subject: '${widget.trip.name} • YeeTrip Summary',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share summary card: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _shareAsText(String textSummary) async {
    try {
      if (widget.onShareTextOverride != null) {
        await widget.onShareTextOverride!(textSummary);
      } else {
        await SharePlus.instance.share(
          ShareParams(
            text: textSummary,
            subject: '${widget.trip.name} • YeeTrip Summary',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share text summary: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final balances = SettleCalculator.calculateBalances(
      travelers: widget.trip.travelers,
      expenses: widget.expenses,
    );
    final settlements =
        SettleCalculator.calculateSettlements(balances: balances);

    final activeExpenses = widget.expenses
        .where((e) => e.confirmed && e.source != 'settlement')
        .toList();
    final totalSpent =
        activeExpenses.fold<int>(0, (s, e) => s + e.amountPaise);
    final effectiveTrip = widget.trip.copyWith(totalSpentPaise: totalSpent);
    final textSummary = TripShareCardFormatter.buildTextSummary(
      trip: effectiveTrip,
      expenses: widget.expenses,
      settlements: settlements,
    );

    final catTotals = <String, int>{};
    for (final exp in activeExpenses) {
      catTotals[exp.category] = (catTotals[exp.category] ?? 0) + exp.amountPaise;
    }
    final topCategories = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
                    Icon(Icons.ios_share_rounded, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Share Trip Summary Card',
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
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Theme selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ShareCardTheme.values.map((cardTheme) {
                        final selected = _selectedTheme == cardTheme;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            key: Key('share_card_theme_${cardTheme.name}'),
                            label: Text(cardTheme.label),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _selectedTheme = cardTheme),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Captured Share Card Poster
                    Center(
                      child: RepaintBoundary(
                        key: _posterKey,
                        child: _PosterCard(
                          trip: effectiveTrip,
                          activeExpenseCount: activeExpenses.length,
                          topCategories: topCategories.take(3).toList(),
                          pendingSettlements: settlements,
                          cardTheme: _selectedTheme,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    FilledButton.icon(
                      key: const Key('share_summary_card_image_btn'),
                      onPressed:
                          _isSharing ? null : () => _shareAsImage(textSummary),
                      icon: _isSharing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.share_rounded),
                      label: Text(
                        _isSharing
                            ? 'Rendering card...'
                            : 'Share Image (WhatsApp / Telegram)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      key: const Key('share_summary_text_btn'),
                      onPressed: () => _shareAsText(textSummary),
                      icon: const Icon(Icons.text_snippet_outlined),
                      label: const Text('Share Formatted Text'),
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
}

class _PosterCard extends StatelessWidget {
  final TripWithDetails trip;
  final int activeExpenseCount;
  final List<MapEntry<String, int>> topCategories;
  final List<SettlementPayment> pendingSettlements;
  final ShareCardTheme cardTheme;

  const _PosterCard({
    required this.trip,
    required this.activeExpenseCount,
    required this.topCategories,
    required this.pendingSettlements,
    required this.cardTheme,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = trip.totalBudgetPaise > 0
        ? (trip.totalSpentPaise / trip.totalBudgetPaise).clamp(0.0, 1.0)
        : 0.0;
    final pct = trip.totalBudgetPaise > 0
        ? ((trip.totalSpentPaise * 100) / trip.totalBudgetPaise).round()
        : 0;
    final isOver = trip.remainingBudgetPaise < 0;
    final perPersonSpent = trip.travelers.isEmpty
        ? 0
        : trip.totalSpentPaise ~/ trip.travelers.length;

    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cardTheme.gradient,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cardTheme.gradient.last.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flight_takeoff, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'YEETRIP SUMMARY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${trip.days}D • ${trip.travelers.length}P',
                style: TextStyle(
                  color: cardTheme.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            trip.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.15,
            ),
          ),
          if (trip.destination != null && trip.destination!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: cardTheme.accent),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      trip.destination!.trim(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total Spent',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '$pct% of ${Money.formatAmount(trip.totalBudgetPaise, currencyCode: trip.currency)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: isOver
                              ? const Color(0xFFFCA5A5)
                              : cardTheme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  Money.formatAmount(
                    trip.totalSpentPaise,
                    currencyCode: trip.currency,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOver ? const Color(0xFFEF4444) : cardTheme.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        label: isOver ? 'Over Budget' : 'Remaining',
                        value: Money.formatAmount(
                          trip.remainingBudgetPaise.abs(),
                          currencyCode: trip.currency,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _MiniStat(
                        label: 'Per Person',
                        value: Money.formatAmount(
                          perPersonSpent,
                          currencyCode: trip.currency,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _MiniStat(
                        label: 'Expenses',
                        value: '$activeExpenseCount',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (topCategories.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'TOP SPENDS',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            ...topCategories.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        Money.formatAmount(
                          entry.value,
                          currencyCode: trip.currency,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: cardTheme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  pendingSettlements.isEmpty
                      ? Icons.check_circle_outline
                      : Icons.handshake_outlined,
                  size: 16,
                  color: cardTheme.accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pendingSettlements.isEmpty
                        ? 'All group balances settled!'
                        : '${pendingSettlements.length} pending settlement(s)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  trip.currency,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
