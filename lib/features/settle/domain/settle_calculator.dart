import 'dart:math';

import '../../trips/domain/trip_model.dart';
import '../../expenses/domain/expense_model.dart';

/// Person balance summary: total paid, total share, and net balance.
class PersonBalance {
  final String travelerId;
  final String travelerName;
  final int paidPaise;
  final int sharePaise;

  const PersonBalance({
    required this.travelerId,
    required this.travelerName,
    required this.paidPaise,
    required this.sharePaise,
  });

  /// Net balance in paise: positive means they are owed money (creditor),
  /// negative means they owe money (debtor).
  int get netBalancePaise => paidPaise - sharePaise;

  PersonBalance copyWith({
    String? travelerId,
    String? travelerName,
    int? paidPaise,
    int? sharePaise,
  }) {
    return PersonBalance(
      travelerId: travelerId ?? this.travelerId,
      travelerName: travelerName ?? this.travelerName,
      paidPaise: paidPaise ?? this.paidPaise,
      sharePaise: sharePaise ?? this.sharePaise,
    );
  }
}

/// A settlement transfer between two travelers.
class SettlementPayment {
  final String fromTravelerId;
  final String toTravelerId;
  final int amountPaise;

  const SettlementPayment({
    required this.fromTravelerId,
    required this.toTravelerId,
    required this.amountPaise,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettlementPayment &&
          runtimeType == other.runtimeType &&
          fromTravelerId == other.fromTravelerId &&
          toTravelerId == other.toTravelerId &&
          amountPaise == other.amountPaise;

  @override
  int get hashCode => Object.hash(fromTravelerId, toTravelerId, amountPaise);

  @override
  String toString() =>
      'SettlementPayment($fromTravelerId -> $toTravelerId: $amountPaise paise)';
}

/// Pure Dart settlement computation engine.
class SettleCalculator {
  SettleCalculator._();

  /// Calculates the balance for every traveler in the trip based on confirmed expenses.
  static List<PersonBalance> calculateBalances({
    required List<Traveler> travelers,
    required List<ExpenseWithSplits> expenses,
  }) {
    final paidMap = <String, int>{for (final t in travelers) t.id: 0};
    final shareMap = <String, int>{for (final t in travelers) t.id: 0};

    for (final expense in expenses) {
      if (!expense.confirmed) continue;

      paidMap[expense.paidBy] =
          (paidMap[expense.paidBy] ?? 0) + expense.amountPaise;

      for (final split in expense.splits) {
        shareMap[split.travelerId] =
            (shareMap[split.travelerId] ?? 0) + split.sharePaise;
      }
    }

    return travelers.map((t) {
      return PersonBalance(
        travelerId: t.id,
        travelerName: t.name,
        paidPaise: paidMap[t.id] ?? 0,
        sharePaise: shareMap[t.id] ?? 0,
      );
    }).toList();
  }

  /// Calculates the optimal greedy settlement payments to clear all debts.
  ///
  /// Note: This greedy matching algorithm produces at most n - 1 transactions.
  /// While optimal and standard for group expense settling, finding the absolute
  /// minimum number of transactions is NP-hard (reducible to the Subset Sum / 3-Partition problem).
  ///
  /// After applying all settlements, every balance is guaranteed to be exactly 0 paise.
  static List<SettlementPayment> calculateSettlements({
    required List<PersonBalance> balances,
  }) {
    // Mutable working balances in paise
    final currentBalances = <String, int>{
      for (final b in balances) b.travelerId: b.netBalancePaise,
    };

    final settlements = <SettlementPayment>[];

    while (true) {
      // Find largest creditor (net > 0) and largest debtor (net < 0)
      String? largestCreditorId;
      int maxCredit = 0;

      String? largestDebtorId;
      int maxDebt = 0; // Absolute value of debt

      for (final entry in currentBalances.entries) {
        final bal = entry.value;
        if (bal > maxCredit) {
          maxCredit = bal;
          largestCreditorId = entry.key;
        } else if (bal < -maxDebt) {
          maxDebt = -bal;
          largestDebtorId = entry.key;
        }
      }

      // If no valid debtor or creditor remains (or remaining balance is < 1 paisa)
      if (largestCreditorId == null ||
          largestDebtorId == null ||
          maxCredit < 1 ||
          maxDebt < 1) {
        break;
      }

      // Transfer the smaller of the debt and credit
      final transfer = min(maxCredit, maxDebt);

      settlements.add(
        SettlementPayment(
          fromTravelerId: largestDebtorId,
          toTravelerId: largestCreditorId,
          amountPaise: transfer,
        ),
      );

      // Apply transfer
      currentBalances[largestDebtorId] =
          currentBalances[largestDebtorId]! + transfer;
      currentBalances[largestCreditorId] =
          currentBalances[largestCreditorId]! - transfer;
    }

    // Assert that every balance is exactly 0 paise after settlements
    for (final val in currentBalances.values) {
      assert(
        val == 0,
        'All balances must be exactly 0 paise after applying settlements, got $val',
      );
    }

    return settlements;
  }
}
