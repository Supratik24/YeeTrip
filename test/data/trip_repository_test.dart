import 'package:drift/native.dart';
import 'package:yeetrip/data/local/app_database.dart';
import 'package:yeetrip/data/repositories/trip_repository.dart';
import 'package:yeetrip/data/repositories/expense_repository.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import '../test_helper.dart';

void main() async {
  late AppDatabase db;
  late DriftTripRepository tripRepo;
  late DriftExpenseRepository expenseRepo;

  void setUp() {
    db = AppDatabase(NativeDatabase.memory());
    tripRepo = DriftTripRepository(db);
    expenseRepo = DriftExpenseRepository(db);
  }

  void tearDown() async {
    await db.close();
  }

  group('DriftTripRepository', () {
    test('creates a trip with travelers and default allocations', () async {
      setUp();

      final tripId = await tripRepo.createTrip(
        name: 'Leh Ladakh',
        totalBudgetPaise: 8000000, // ₹80,000
        days: 7,
        travelerNames: ['Kabir', 'Tara', 'Arjun'],
      );

      final trip = await tripRepo.getTripById(tripId);
      expect(trip != null, true);
      expect(trip!.name, 'Leh Ladakh');
      expect(trip.totalBudgetPaise, 8000000);
      expect(trip.days, 7);
      expect(trip.travelers.length, 3);
      expect(trip.travelers.map((t) => t.name).toList(), ['Kabir', 'Tara', 'Arjun']);
      expect(trip.categoryAllocations['Stay'], 30);
      expect(trip.categoryAllocations['Food'], 25);
      expect(trip.totalSpentPaise, 0);
      expect(trip.remainingBudgetPaise, 8000000);
      expect(trip.budgetPerPersonPaise, 8000000 ~/ 3);
      expect(trip.budgetPerDayPaise, 8000000 ~/ 7);

      tearDown();
    });

    test('updates category allocations', () async {
      setUp();

      final tripId = await tripRepo.createTrip(
        name: 'Jaipur',
        totalBudgetPaise: 3000000,
        days: 3,
        travelerNames: ['Amit'],
      );

      await tripRepo.updateCategoryAllocations(tripId, {
        'Stay': 40,
        'Food': 30,
        'Transport': 10,
        'Activities': 10,
        'Shopping': 5,
        'Buffer': 5,
      });

      final trip = await tripRepo.getTripById(tripId);
      expect(trip != null, true);
      expect(trip!.categoryAllocations['Stay'], 40);
      expect(trip.categoryAllocations['Food'], 30);
      expect(trip.categoryAllocations['Transport'], 10);

      tearDown();
    });

    test('accurately calculates spent and remaining budget when expenses are logged', () async {
      setUp();

      final tripId = await tripRepo.createTrip(
        name: 'Rishikesh',
        totalBudgetPaise: 1000000, // ₹10,000
        days: 2,
        travelerNames: ['Dev', 'Ravi'],
      );

      final trip = await tripRepo.getTripById(tripId);
      final dev = trip!.travelers.firstWhere((t) => t.name == 'Dev');
      final ravi = trip.travelers.firstWhere((t) => t.name == 'Ravi');

      // Log an expense of ₹2,500 (250000 paise) split equally
      await expenseRepo.addExpense(
        tripId: tripId,
        description: 'Rafting tickets',
        amountPaise: 250000,
        category: 'Activities',
        paidBy: dev.id,
        createdAt: DateTime.now(),
        splits: [
          ExpenseSplitModel(expenseId: '', travelerId: dev.id, sharePaise: 125000),
          ExpenseSplitModel(expenseId: '', travelerId: ravi.id, sharePaise: 125000),
        ],
      );

      final updatedTrip = await tripRepo.getTripById(tripId);
      expect(updatedTrip!.totalSpentPaise, 250000);
      expect(updatedTrip.remainingBudgetPaise, 750000);

      tearDown();
    });

    test('deleting a trip deletes all associated data', () async {
      setUp();

      final tripId = await tripRepo.createTrip(
        name: 'Ooty',
        totalBudgetPaise: 4000000,
        days: 3,
        travelerNames: ['Sara', 'Meera'],
      );

      await tripRepo.deleteTrip(tripId);
      final trip = await tripRepo.getTripById(tripId);
      expect(trip == null, true);

      final allTrips = await tripRepo.getTrips();
      expect(allTrips.isEmpty, true);

      tearDown();
    });

    test('updateTripDetails updates trip name, budget and days', () async {
      setUp();

      final tripId = await tripRepo.createTrip(
        name: 'Manali ❄️',
        totalBudgetPaise: 5000000, // ₹50,000
        days: 5,
        travelerNames: ['Vikram'],
      );

      await tripRepo.updateTripDetails(
        tripId: tripId,
        name: 'Manali & Kasol 🏔️',
        totalBudgetPaise: 7500000, // ₹75,000
        days: 6,
      );

      final updated = await tripRepo.getTripById(tripId);
      expect(updated!.name, 'Manali & Kasol 🏔️');
      expect(updated.totalBudgetPaise, 7500000);
      expect(updated.days, 6);

      tearDown();
    });

    test('addTraveler and updateTraveler manage travelers and optional upiVpa', () async {
      setUp();

      final tripId = await tripRepo.createTrip(
        name: 'Shimla',
        totalBudgetPaise: 2000000,
        days: 2,
        travelerNames: ['Ananya'],
      );

      final newTravelerId = await tripRepo.addTraveler(
        tripId: tripId,
        name: 'Rohit',
        upiVpa: 'rohit@okaxis',
      );

      var trip = await tripRepo.getTripById(tripId);
      expect(trip!.travelers.length, 2);
      final rohit = trip.travelers.firstWhere((t) => t.id == newTravelerId);
      expect(rohit.name, 'Rohit');
      expect(rohit.upiVpa, 'rohit@okaxis');

      await tripRepo.updateTraveler(
        travelerId: newTravelerId,
        name: 'Rohit S.',
        upiVpa: 'rohit.s@okhdfcbank',
      );

      trip = await tripRepo.getTripById(tripId);
      final updatedRohit = trip!.travelers.firstWhere((t) => t.id == newTravelerId);
      expect(updatedRohit.name, 'Rohit S.');
      expect(updatedRohit.upiVpa, 'rohit.s@okhdfcbank');

      tearDown();
    });

    test('canDeleteTraveler allows deletion without expenses, blocks deletion with expenses', () async {
      setUp();

      final tripId = await tripRepo.createTrip(
        name: 'Goa',
        totalBudgetPaise: 3000000,
        days: 3,
        travelerNames: ['Traveler 1', 'Traveler 2'],
      );

      var trip = await tripRepo.getTripById(tripId);
      final t1 = trip!.travelers[0];
      final t2 = trip.travelers[1];

      // Traveler 2 has no expenses yet
      expect(await tripRepo.canDeleteTraveler(t2.id), true);
      await tripRepo.deleteTraveler(t2.id);

      trip = await tripRepo.getTripById(tripId);
      expect(trip!.travelers.length, 1);
      expect(trip.travelers.first.id, t1.id);

      // Now add expense for Traveler 1
      await expenseRepo.addExpense(
        tripId: tripId,
        description: 'Snacks',
        amountPaise: 20000,
        category: 'Food',
        paidBy: t1.id,
        createdAt: DateTime.now(),
        splits: [
          ExpenseSplitModel(expenseId: '', travelerId: t1.id, sharePaise: 20000),
        ],
      );

      expect(await tripRepo.canDeleteTraveler(t1.id), false);
      expect(() => tripRepo.deleteTraveler(t1.id), throwsA(isA<StateError>()));

      tearDown();
    });
  });

  final ok = await runSuite('Trip Repository Tests');
  if (!ok) throw Exception('Trip repository tests failed');
}
