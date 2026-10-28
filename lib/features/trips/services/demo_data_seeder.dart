import '../../../core/constants/categories.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/trip_repository.dart';
import '../../expenses/domain/expense_model.dart';
import '../../expenses/domain/split_calculator.dart';

/// Seeds realistic demo data for Indian users to explore YeeTrip in one tap.
class DemoDataSeeder {
  static const String demoTripName = 'Goa Weekend 🌴';
  static const int demoBudgetPaise = 6000000; // ₹60,000
  static const int demoDays = 4;
  static const List<String> demoTravelers = ['Aarav', 'Diya', 'Kabir', 'Rohan'];

  /// Helper to generate [ExpenseSplitModel] list from equal splits.
  static List<ExpenseSplitModel> _equalSplits(
    int totalPaise,
    List<String> travelerIds,
  ) {
    final splitMap = SplitCalculator.calculateEqualSplit(
      totalPaise: totalPaise,
      travelerIds: travelerIds,
    );
    return splitMap.entries
        .map((e) => ExpenseSplitModel(
              expenseId: '',
              travelerId: e.key,
              sharePaise: e.value,
            ))
        .toList();
  }

  /// Seeds a complete demo trip with travelers, category allocations, and expenses.
  /// Returns the newly created tripId.
  static Future<String> seedDemoTrip({
    required TripRepository tripRepo,
    required ExpenseRepository expenseRepo,
  }) async {
    // 1. Create Trip with default allocations
    final tripId = await tripRepo.createTrip(
      name: demoTripName,
      totalBudgetPaise: demoBudgetPaise,
      days: demoDays,
      travelerNames: demoTravelers,
      allocations: {
        TripCategory.stay.key: 30, // ₹18,000
        TripCategory.food.key: 25, // ₹15,000
        TripCategory.transport.key: 20, // ₹12,000
        TripCategory.activities.key: 15, // ₹9,000
        TripCategory.shopping.key: 5, // ₹3,000
        TripCategory.buffer.key: 5, // ₹3,000
      },
    );

    // 2. Load created trip to retrieve generated traveler IDs
    final createdTrip = await tripRepo.getTripById(tripId);
    if (createdTrip == null) {
      throw StateError('Failed to retrieve newly created demo trip: $tripId');
    }

    final travelerMap = {
      for (final t in createdTrip.travelers) t.name: t.id,
    };

    final aaravId = travelerMap['Aarav']!;
    final diyaId = travelerMap['Diya']!;
    final kabirId = travelerMap['Kabir']!;
    final rohanId = travelerMap['Rohan']!;
    final allTravelerIds = [aaravId, diyaId, kabirId, rohanId];

    final now = DateTime.now();

    // 3. Log realistic demo expenses across categories and payers

    // Expense 1: Beachside Villa Booking (Stay, paid by Aarav, ₹16,000)
    await expenseRepo.addExpense(
      tripId: tripId,
      description: 'Beachside Villa booking (2 nights)',
      amountPaise: 1600000,
      category: TripCategory.stay.key,
      paidBy: aaravId,
      createdAt: now.subtract(const Duration(days: 3)),
      splits: _equalSplits(1600000, allTravelerIds),
    );

    // Expense 2: SUV Rental & Highway Fuel (Transport, paid by Kabir, ₹8,400)
    await expenseRepo.addExpense(
      tripId: tripId,
      description: 'SUV Rental & Highway Fuel',
      amountPaise: 840000,
      category: TripCategory.transport.key,
      paidBy: kabirId,
      createdAt: now.subtract(const Duration(days: 2, hours: 4)),
      splits: _equalSplits(840000, allTravelerIds),
    );

    // Expense 3: Seafood Dinner at Curlies (Food, paid by Diya, ₹5,200)
    await expenseRepo.addExpense(
      tripId: tripId,
      description: 'Seafood Dinner at Curlies Shack',
      amountPaise: 520000,
      category: TripCategory.food.key,
      paidBy: diyaId,
      createdAt: now.subtract(const Duration(days: 2)),
      splits: _equalSplits(520000, allTravelerIds),
    );

    // Expense 4: Scuba Diving & Parasailing (Activities, paid by Rohan, ₹7,200)
    await expenseRepo.addExpense(
      tripId: tripId,
      description: 'Scuba Diving & Parasailing',
      amountPaise: 720000,
      category: TripCategory.activities.key,
      paidBy: rohanId,
      createdAt: now.subtract(const Duration(days: 1)),
      splits: _equalSplits(720000, allTravelerIds),
    );

    // Expense 5: Local Goan Sweets & Cashews (Shopping, paid by Aarav, ₹1,800)
    await expenseRepo.addExpense(
      tripId: tripId,
      description: 'Goan Cashews & Bebinca Sweets',
      amountPaise: 180000,
      category: TripCategory.shopping.key,
      paidBy: aaravId,
      createdAt: now.subtract(const Duration(hours: 6)),
      splits: _equalSplits(180000, allTravelerIds),
    );

    return tripId;
  }
}
