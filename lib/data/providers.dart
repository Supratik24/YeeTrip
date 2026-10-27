import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/expenses/domain/expense_model.dart';
import '../features/trips/domain/trip_model.dart';
import 'local/app_database.dart';
import 'local/connection/connection.dart';
import 'repositories/expense_repository.dart';
import 'repositories/trip_repository.dart';

/// Database provider. Can be overridden in tests.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(openAppConnection());
  ref.onDispose(() => db.close());
  return db;
});

/// TripRepository provider.
final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftTripRepository(db);
});

/// ExpenseRepository provider.
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftExpenseRepository(db);
});

/// Stream of all trips for the home screen.
final tripsStreamProvider = StreamProvider<List<TripWithDetails>>((ref) {
  final repo = ref.watch(tripRepositoryProvider);
  return repo.watchTrips();
});

/// Stream of a single trip with details.
final tripDetailsProvider =
    StreamProvider.family<TripWithDetails?, String>((ref, tripId) {
  final repo = ref.watch(tripRepositoryProvider);
  return repo.watchTripById(tripId);
});

/// Stream of expenses for a specific trip.
final tripExpensesProvider =
    StreamProvider.family<List<ExpenseWithSplits>, String>((ref, tripId) {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.watchExpenses(tripId);
});
