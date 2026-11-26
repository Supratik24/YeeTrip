import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/data/local/app_database.dart' hide Traveler;
import 'package:yeetrip/data/repositories/expense_comment_repository.dart';
import 'package:yeetrip/data/repositories/expense_repository.dart';
import 'package:yeetrip/data/repositories/itinerary_repository.dart';
import 'package:yeetrip/data/repositories/trip_repository.dart';
import 'package:yeetrip/features/expenses/domain/expense_filter.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/trips/services/trip_backup_service.dart';

void main() {
  late AppDatabase db;
  late DriftTripRepository tripRepo;
  late DriftExpenseRepository expenseRepo;
  late DriftItineraryRepository itineraryRepo;
  late DriftExpenseCommentRepository commentRepo;
  late TripBackupService backupService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tripRepo = DriftTripRepository(db);
    expenseRepo = DriftExpenseRepository(db);
    itineraryRepo = DriftItineraryRepository(db);
    commentRepo = DriftExpenseCommentRepository(db);
    backupService = TripBackupService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('supports multi-currency trip creation, expense tags/notes, and tag filtering', () async {
    final tripId = await tripRepo.createTrip(
      name: 'Tokyo Week',
      totalBudgetPaise: 200000, // $2,000
      days: 5,
      travelerNames: ['Aarav', 'Diya'],
      currency: 'USD',
    );

    final trip = await tripRepo.getTripById(tripId);
    expect(trip!.currency, equals('USD'));
    final aarav = trip.travelers.first.id;
    final diya = trip.travelers.last.id;

    await expenseRepo.addExpense(
      tripId: tripId,
      description: 'Sushi Dinner in Shibuya',
      amountPaise: 8450, // $84.50
      category: 'Food',
      paidBy: aarav,
      createdAt: DateTime(2026, 11, 1),
      splits: [
        ExpenseSplitModel(expenseId: '', travelerId: aarav, sharePaise: 4225),
        ExpenseSplitModel(expenseId: '', travelerId: diya, sharePaise: 4225),
      ],
      notes: 'Cash paid at counter after 5% discount',
      tags: const ['#dinner', 'Reimbursable', 'dinner'],
      originalCurrency: 'JPY',
      originalAmountPaise: 1250000, // ¥12,500
      exchangeRate: 0.00676,
    );

    final expenses = await expenseRepo.getExpenses(tripId);
    expect(expenses.length, equals(1));
    final exp = expenses.first;
    expect(exp.tags, equals(['dinner', 'Reimbursable']));
    expect(exp.notes, contains('Cash paid'));
    expect(exp.originalCurrency, equals('JPY'));
    expect(exp.originalAmountPaise, equals(1250000));

    // Tag & note search
    final byTag = const ExpenseFilterCriteria(tag: 'reimbursable').apply(expenses);
    expect(byTag.length, equals(1));
    final byNote = const ExpenseFilterCriteria(searchQuery: 'counter').apply(expenses);
    expect(byNote.length, equals(1));
  });

  test('manages per-expense comments and disputes with live stats & cascade delete', () async {
    final tripId = await tripRepo.createTrip(
      name: 'Goa',
      totalBudgetPaise: 3000000,
      days: 3,
      travelerNames: ['Aarav', 'Diya'],
    );
    final trip = await tripRepo.getTripById(tripId);
    final aarav = trip!.travelers.first.id;

    final expenseId = await expenseRepo.addExpense(
      tripId: tripId,
      description: 'Boat Charter',
      amountPaise: 500000,
      category: 'Activities',
      paidBy: aarav,
      createdAt: DateTime.now(),
      splits: [
        ExpenseSplitModel(expenseId: '', travelerId: aarav, sharePaise: 500000),
      ],
    );

    final c1 = await commentRepo.addComment(
      expenseId: expenseId,
      tripId: tripId,
      authorTravelerId: aarav,
      authorName: 'Aarav',
      body: 'Does this include life jackets?',
    );
    final c2 = await commentRepo.addComment(
      expenseId: expenseId,
      tripId: tripId,
      authorName: 'Diya',
      body: 'Amount looks 500 higher than quote',
      isDispute: true,
    );

    var expenses = await expenseRepo.getExpenses(tripId);
    expect(expenses.single.commentCount, equals(2));
    expect(expenses.single.openDisputeCount, equals(1));

    await commentRepo.setDisputeResolved(c2, true);
    expenses = await expenseRepo.getExpenses(tripId);
    expect(expenses.single.commentCount, equals(2));
    expect(expenses.single.openDisputeCount, equals(0));

    await commentRepo.deleteComment(c1);
    final remaining = await commentRepo.getCommentsForExpense(expenseId);
    expect(remaining.length, equals(1));

    await expenseRepo.deleteExpense(expenseId);
    expect(await commentRepo.getCommentsForExpense(expenseId), isEmpty);
  });

  test('manages day-by-day itinerary and updates trip summary & backup/restore', () async {
    final tripId = await tripRepo.createTrip(
      name: 'Bali Plan',
      totalBudgetPaise: 150000,
      days: 3,
      travelerNames: ['Aarav'],
      currency: 'USD',
    );

    final i2 = await itineraryRepo.addItem(
      tripId: tripId,
      dayNumber: 2,
      title: 'Uluwatu Temple Sunset',
      location: 'Uluwatu, Bali',
      startTimeMinutes: 17 * 60,
      estimatedCostPaise: 4000,
      notes: 'Sarong included in entry ticket',
    );
    final i1 = await itineraryRepo.addItem(
      tripId: tripId,
      dayNumber: 1,
      title: 'Check-in Ubud Villa',
      startTimeMinutes: 14 * 60,
      category: 'Stay',
      estimatedCostPaise: 25000,
    );

    final items = await itineraryRepo.getItinerary(tripId);
    expect(items.map((i) => i.id).toList(), equals([i1, i2]));
    expect(items.first.displayTime, equals('02:00 PM'));

    var trip = await tripRepo.getTripById(tripId);
    expect(trip!.itineraryTotalCount, equals(2));
    expect(trip.itineraryCompletedCount, equals(0));
    expect(trip.nextItineraryTitle, equals('Day 1: Check-in Ubud Villa'));

    await itineraryRepo.toggleCompleted(i1, true);
    trip = await tripRepo.getTripById(tripId);
    expect(trip!.itineraryCompletedCount, equals(1));
    expect(trip.nextItineraryTitle, equals('Day 2: Uluwatu Temple Sunset'));

    // Backup & Restore round-trip including currency + itinerary
    final fullJson = TripBackupService.exportTripToJson(
      trip: trip,
      expenses: await expenseRepo.getExpenses(tripId),
      itinerary: await itineraryRepo.getItinerary(tripId),
    );
    final restoredId = await backupService.restoreTripFromJson(fullJson);
    final restoredTrip = await tripRepo.getTripById(restoredId);
    final restoredItinerary = await itineraryRepo.getItinerary(restoredId);

    expect(restoredTrip!.currency, equals('USD'));
    expect(restoredItinerary.length, equals(2));
    expect(restoredItinerary.first.title, equals('Check-in Ubud Villa'));
    expect(restoredItinerary.first.isCompleted, isTrue);

    await tripRepo.deleteTrip(tripId);
    expect(await itineraryRepo.getItinerary(tripId), isEmpty);
  });
}
