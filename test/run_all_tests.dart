// ignore_for_file: avoid_print
import 'dart:io';

import 'core/money_test.dart' as money_test;
import 'data/database_test.dart' as database_test;
import 'data/trip_repository_test.dart' as trip_repository_test;
import 'features/budget/rebalance_test.dart' as rebalance_test;
import 'features/expenses/split_calculator_test.dart' as split_calculator_test;
import 'features/settings/csv_exporter_test.dart' as csv_exporter_test;
import 'features/settle/settle_calculator_test.dart' as settle_calculator_test;
import 'features/trips/trip_setup_validation_test.dart' as trip_setup_test;
import 'integration/trip_flow_integration_test.dart' as integration_test;
import 'test_helper.dart';

void main() async {
  print('======================================================');
  print('          YEETRIP COMPREHENSIVE TEST SUITE            ');
  print('======================================================');

  final suites = <String, dynamic Function()>{
    'Money Utilities & Indian Grouping': money_test.main,
    'Drift SQLite In-Memory Database': database_test.main,
    'Trip Repository & Allocations': trip_repository_test.main,
    'Trip Setup Validation Rules': trip_setup_test.main,
    'Budget Rebalance (Proportional & Largest-Remainder)': rebalance_test.main,
    'Split Calculator (Equal, Percent, Shares, Exact)': split_calculator_test.main,
    'Settle-Up Greedy Debt Resolution Engine': settle_calculator_test.main,
    'CSV Exporter (RFC 4180 Format)': csv_exporter_test.main,
    'End-to-End Trip Flow Integration': integration_test.main,
  };

  int totalPassed = 0;
  int totalFailed = 0;
  final results = <String, bool>{};

  final stopwatch = Stopwatch()..start();

  for (final entry in suites.entries) {
    try {
      final res = entry.value();
      if (res is Future) {
        await res;
      }
      results[entry.key] = true;
      totalPassed += lastSuitePassed;
      totalFailed += lastSuiteFailed;
    } catch (e) {
      results[entry.key] = false;
      totalFailed += (lastSuiteFailed > 0 ? lastSuiteFailed : 1);
      print('FAILED suite: ${entry.key} with error: $e');
    }
  }

  stopwatch.stop();

  print('\n======================================================');
  print('                TEST EXECUTION SUMMARY                ');
  print('======================================================');
  results.forEach((suite, passed) {
    final status = passed ? 'PASS ✓' : 'FAIL ✗';
    print(' [$status] $suite');
  });

  print('------------------------------------------------------');
  print(' Total Tests Passed: $totalPassed');
  print(' Total Tests Failed: $totalFailed');
  print(' Total Elapsed Time: ${stopwatch.elapsedMilliseconds} ms');
  print('======================================================');

  if (totalFailed > 0) {
    exit(1);
  }
}
