import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Opens the SQLite database in the browser using WebAssembly.
QueryExecutor openAppConnection() {
  return DatabaseConnection.delayed(Future.sync(() async {
    final result = await WasmDatabase.open(
      databaseName: 'yeetrip_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  }));
}
