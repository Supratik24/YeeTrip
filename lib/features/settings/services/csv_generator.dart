import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import 'package:yeetrip/core/money.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

/// Pure Dart utility to format trip expenses into RFC 4180 CSV strings.
/// Has zero Flutter or native dependencies so it is 100% unit-testable.
class CsvGenerator {
  const CsvGenerator._();

  /// Converts expenses into CSV format with columns:
  /// date, description, category, paid_by, amount_inr, split_among
  static String generateCsv({
    required TripWithDetails trip,
    required List<ExpenseWithSplits> expenses,
  }) {
    final travelersMap = {
      for (final t in trip.travelers) t.id: t.name,
    };

    final rows = <List<dynamic>>[];

    // CSV Header row
    rows.add([
      'date',
      'description',
      'category',
      'paid_by',
      'amount_inr',
      'split_among',
    ]);

    final dateFormat = DateFormat('yyyy-MM-dd');

    for (final exp in expenses) {
      final dateStr = dateFormat.format(exp.createdAt);
      final payerName = travelersMap[exp.paidBy] ?? 'Unknown';
      final amountInr = Money.paiseToDecimalString(exp.amountPaise);

      final splitNames = exp.splits
          .map((s) => travelersMap[s.travelerId] ?? 'Unknown')
          .join(', ');

      rows.add([
        dateStr,
        exp.description,
        exp.category,
        payerName,
        amountInr,
        splitNames,
      ]);
    }

    return csv.encode(rows);
  }
}
