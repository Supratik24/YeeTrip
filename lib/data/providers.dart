import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/expenses/domain/expense_comment_model.dart';
import '../features/expenses/domain/expense_model.dart';
import '../features/gallery/domain/trip_photo_model.dart';
import '../features/itinerary/domain/itinerary_model.dart';
import '../features/trips/domain/trip_model.dart';
import '../features/trips/services/trip_backup_service.dart';
import 'local/app_database.dart';
import 'local/connection/connection.dart';
import 'repositories/expense_comment_repository.dart';
import 'repositories/expense_repository.dart';
import 'repositories/itinerary_repository.dart';
import 'repositories/trip_photo_repository.dart';
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

/// ItineraryRepository provider.
final itineraryRepositoryProvider = Provider<ItineraryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftItineraryRepository(db);
});

/// ExpenseCommentRepository provider.
final expenseCommentRepositoryProvider =
    Provider<ExpenseCommentRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftExpenseCommentRepository(db);
});

/// TripPhotoRepository provider.
final tripPhotoRepositoryProvider = Provider<TripPhotoRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftTripPhotoRepository(db);
});

/// TripBackupService provider.
final tripBackupServiceProvider = Provider<TripBackupService>((ref) {
  final db = ref.watch(databaseProvider);
  return TripBackupService(db);
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

/// Stream of day-by-day itinerary items for a specific trip.
final tripItineraryProvider =
    StreamProvider.family<List<ItineraryItemModel>, String>((ref, tripId) {
  final repo = ref.watch(itineraryRepositoryProvider);
  return repo.watchItinerary(tripId);
});

/// Stream of comments and disputes for a single expense.
final expenseCommentsProvider =
    StreamProvider.family<List<ExpenseCommentModel>, String>((ref, expenseId) {
  final repo = ref.watch(expenseCommentRepositoryProvider);
  return repo.watchCommentsForExpense(expenseId);
});

/// Stream of shared gallery photos for a specific trip.
final tripPhotosProvider =
    StreamProvider.family<List<TripPhotoModel>, String>((ref, tripId) {
  final repo = ref.watch(tripPhotoRepositoryProvider);
  return repo.watchPhotos(tripId);
});
