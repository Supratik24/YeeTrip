import 'package:drift/drift.dart';

/// Unsupported platform fallback.
QueryExecutor openAppConnection() {
  throw UnsupportedError('Platform not supported');
}
