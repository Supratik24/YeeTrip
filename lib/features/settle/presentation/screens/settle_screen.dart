import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/categories.dart';
import '../../../../core/money.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../data/providers.dart';
import '../../../expenses/domain/expense_model.dart';
import '../../../trips/domain/trip_model.dart';
import '../../domain/settle_calculator.dart';
import '../../services/upi_payment_launcher.dart';

/// Screen displaying individual balances and greedy settlement instructions.
class SettleScreen extends ConsumerWidget {
  final TripWithDetails trip;

  const SettleScreen({
    super.key,
    required this.trip,
  });

  Future<void> _confirmMarkSettled(
    BuildContext context,
    WidgetRef ref,
    SettlementPayment payment,
    String fromName,
    String toName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as settled?'),
        content: Text(
          'Confirm that $fromName has paid ${Money.formatRupees(payment.amountPaise)} to $toName?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final expenseRepo = ref.read(expenseRepositoryProvider);
      await expenseRepo.addExpense(
        tripId: trip.id,
        description: 'Settlement: $fromName → $toName',
        amountPaise: payment.amountPaise,
        category: TripCategory.buffer.key,
        paidBy: payment.fromTravelerId,
        source: 'settlement',
        createdAt: DateTime.now(),
        splits: [
          ExpenseSplitModel(
            expenseId: '',
            travelerId: payment.toTravelerId,
            sharePaise: payment.amountPaise,
          ),
        ],
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recorded settlement: $fromName paid ${Money.formatRupees(payment.amountPaise)} to $toName',
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleUpiPayment({
    required BuildContext context,
    required SettlementPayment payment,
    required String fromName,
    required String toName,
    required String toVpa,
  }) async {
    final launched = await UpiPaymentLauncher.launchUpiPayment(
      payeeVpa: toVpa,
      payeeName: toName,
      amountPaise: payment.amountPaise,
      note: 'YeeTrip Settlement: $fromName to $toName',
    );

    if (!launched && context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('UPI Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Could not open a UPI app directly.'),
              const SizedBox(height: 12),
              Text(
                'Payee: $toName',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('UPI ID: $toVpa'),
              Text('Amount: ${Money.formatRupees(payment.amountPaise)}'),
              const SizedBox(height: 12),
              const Text(
                'You can copy the UPI ID and complete the payment using any UPI app (Google Pay, PhonePe, Paytm, BHIM).',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: toVpa));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied "$toVpa" to clipboard'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy UPI ID'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _promptAddUpiAndPay({
    required BuildContext context,
    required WidgetRef ref,
    required Traveler toTraveler,
    required SettlementPayment payment,
    required String fromName,
  }) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add UPI ID for ${toTraveler.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter ${toTraveler.name}\'s UPI ID (VPA) to pay directly with UPI:',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('add_vpa_field'),
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'UPI ID',
                hintText: 'e.g. name@okhdfcbank',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('save_vpa_and_pay_btn'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save & Pay'),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().isNotEmpty) {
      final vpa = controller.text.trim();
      await ref.read(tripRepositoryProvider).updateTraveler(
            travelerId: toTraveler.id,
            name: toTraveler.name,
            upiVpa: vpa,
          );

      if (context.mounted) {
        await _handleUpiPayment(
          context: context,
          payment: payment,
          fromName: fromName,
          toName: toTraveler.name,
          toVpa: vpa,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(tripExpensesProvider(trip.id));
    final theme = Theme.of(context);
    final travelersMap = {
      for (final t in trip.travelers) t.id: t.name,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settle up'),
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading expenses: $err')),
        data: (expenses) {
          final balances = SettleCalculator.calculateBalances(
            travelers: trip.travelers,
            expenses: expenses,
          );

          final settlements = SettleCalculator.calculateSettlements(
            balances: balances,
          );

          return ResponsiveCenter(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
              // Section 1: Individual Balances
              Text(
                'Individual balances',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              ...balances.map((person) {
                final net = person.netBalancePaise;
                final isCreditor = net > 0;
                final isDebtor = net < 0;

                final netColor = isCreditor
                    ? const Color(0xFF10B981) // Green
                    : (isDebtor ? theme.colorScheme.error : Colors.grey.shade600);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          foregroundColor: theme.colorScheme.primary,
                          child: Text(
                            person.travelerName.isNotEmpty
                                ? person.travelerName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                person.travelerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Paid ${Money.formatRupees(person.paidPaise)} • Share ${Money.formatRupees(person.sharePaise)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isCreditor
                                  ? '+${Money.formatRupees(net)}'
                                  : (isDebtor
                                      ? '-${Money.formatRupees(net.abs())}'
                                      : '₹0'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: netColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isCreditor
                                  ? 'gets back'
                                  : (isDebtor ? 'owes' : 'settled'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: netColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Section 2: Greedy Settlement Plan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Settlement plan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (settlements.isNotEmpty)
                    Text(
                      '${settlements.length} ${settlements.length == 1 ? "payment" : "payments"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              if (settlements.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: const Color(0xFF10B981),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'All settled up!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            expenses.isEmpty
                                ? 'Add expenses to see settlements.'
                                : 'No outstanding balances between group members.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...settlements.map((payment) {
                  final fromName =
                      travelersMap[payment.fromTravelerId] ?? 'Someone';
                  final toName =
                      travelersMap[payment.toTravelerId] ?? 'Someone';
                  final toTraveler = trip.travelers.firstWhere(
                    (t) => t.id == payment.toTravelerId,
                    orElse: () => Traveler(
                      id: payment.toTravelerId,
                      tripId: trip.id,
                      name: toName,
                    ),
                  );
                  final hasVpa = toTraveler.upiVpa != null &&
                      toTraveler.upiVpa!.trim().isNotEmpty;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_circle_right_outlined,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: theme.textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: fromName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: ' pays '),
                                  TextSpan(
                                    text: toName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              Money.formatRupees(payment.amountPaise),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            key: Key(
                              'pay_upi_${payment.fromTravelerId}_${payment.toTravelerId}',
                            ),
                            icon: Icon(
                              Icons.payment,
                              color: theme.colorScheme.primary,
                            ),
                            tooltip: hasVpa
                                ? 'Pay ${toTraveler.upiVpa} via UPI'
                                : 'Add UPI ID to pay',
                            onPressed: () {
                              if (hasVpa) {
                                _handleUpiPayment(
                                  context: context,
                                  payment: payment,
                                  fromName: fromName,
                                  toName: toName,
                                  toVpa: toTraveler.upiVpa!.trim(),
                                );
                              } else {
                                _promptAddUpiAndPay(
                                  context: context,
                                  ref: ref,
                                  toTraveler: toTraveler,
                                  payment: payment,
                                  fromName: fromName,
                                );
                              }
                            },
                          ),
                          IconButton(
                            key: Key(
                              'mark_settled_${payment.fromTravelerId}_${payment.toTravelerId}',
                            ),
                            icon: const Icon(Icons.check_circle_outline),
                            color: const Color(0xFF10B981),
                            tooltip: 'Mark settled',
                            onPressed: () => _confirmMarkSettled(
                              context,
                              ref,
                              payment,
                              fromName,
                              toName,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
