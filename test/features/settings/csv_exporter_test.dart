import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/settings/services/csv_generator.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';
import '../../test_helper.dart';

void main() async {
  group('CsvGenerator.generateCsv', () {
    test('generates valid RFC 4180 CSV with required columns', () {
      final trip = TripWithDetails(
        id: 'trip_1',
        name: 'Goa Holiday',
        totalBudgetPaise: 5000000,
        days: 4,
        createdAt: DateTime(2026, 10, 20),
        travelers: const [
          Traveler(id: 't1', tripId: 'trip_1', name: 'Aarav'),
          Traveler(id: 't2', tripId: 'trip_1', name: 'Priya'),
        ],
      );

      final expenses = [
        ExpenseWithSplits(
          id: 'exp_1',
          tripId: 'trip_1',
          description: 'Lunch, beach shack',
          amountPaise: 240050, // ₹2,400.50
          category: 'Food',
          paidBy: 't1',
          createdAt: DateTime(2026, 10, 21),
          splits: const [
            ExpenseSplitModel(expenseId: 'exp_1', travelerId: 't1', sharePaise: 120025),
            ExpenseSplitModel(expenseId: 'exp_1', travelerId: 't2', sharePaise: 120025),
          ],
        ),
      ];

      final csv = CsvGenerator.generateCsv(trip: trip, expenses: expenses);

      // Verify columns in header: date, description, category, paid_by, amount_inr, split_among
      expect(
        csv.contains('date,description,category,paid_by,amount_inr,split_among'),
        true,
      );

      // Verify data row
      expect(csv.contains('2026-10-21'), true);
      expect(csv.contains('"Lunch, beach shack"'), true); // escaped comma
      expect(csv.contains('Food'), true);
      expect(csv.contains('Aarav'), true);
      expect(csv.contains('2400.50'), true);
      expect(csv.contains('"Aarav, Priya"'), true); // escaped comma
    });

    test('handles empty expenses cleanly', () {
      final trip = TripWithDetails(
        id: 'trip_1',
        name: 'Goa Holiday',
        totalBudgetPaise: 5000000,
        days: 4,
        createdAt: DateTime(2026, 10, 20),
        travelers: const [
          Traveler(id: 't1', tripId: 'trip_1', name: 'Aarav'),
        ],
      );

      final csv = CsvGenerator.generateCsv(trip: trip, expenses: []);
      final lines = csv.trim().split('\r\n');
      final lineCount = lines.length == 1 ? lines : csv.trim().split('\n');
      expect(lineCount.length, 1);
      expect(lineCount.first, 'date,description,category,paid_by,amount_inr,split_among');
    });
  });

  final ok = await runSuite('CSV Generator Tests');
  if (!ok) throw Exception('CSV generator tests failed');
}
