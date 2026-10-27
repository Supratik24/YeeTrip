import 'package:drift/drift.dart';

import 'unsupported.dart'
    if (dart.library.io) 'native.dart'
    if (dart.library.js_interop) 'web.dart' as impl;

/// Opens the app connection appropriately for the running platform (Native or Web).
QueryExecutor openAppConnection() => impl.openAppConnection();
