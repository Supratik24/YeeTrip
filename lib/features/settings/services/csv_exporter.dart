import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';
import 'csv_generator.dart';

/// Service to export trip expenses as CSV and share via platform share sheet.
class CsvExporter {
  CsvExporter._();

  /// Formats expenses as CSV using [CsvGenerator].
  static String generateCsv({
    required TripWithDetails trip,
    required List<ExpenseWithSplits> expenses,
  }) {
    return CsvGenerator.generateCsv(trip: trip, expenses: expenses);
  }

  /// Exports the trip expenses and invokes the system share sheet.
  static Future<void> exportAndShare({
    required TripWithDetails trip,
    required List<ExpenseWithSplits> expenses,
  }) async {
    final csvContent = CsvGenerator.generateCsv(trip: trip, expenses: expenses);

    final tempDir = await getTemporaryDirectory();
    final sanitizedName = trip.name.replaceAll(RegExp(r'[^\w\s]+'), '_');
    final filePath = '${tempDir.path}/yeetrip_${sanitizedName}_expenses.csv';

    final file = File(filePath);
    await file.writeAsString(csvContent);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Expenses for ${trip.name}',
        text: 'Exported expenses for ${trip.name} via YeeTrip',
      ),
    );
  }
}
