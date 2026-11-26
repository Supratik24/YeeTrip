import '../../../core/constants/categories.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/itinerary_repository.dart';
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

  /// Seeds a complete demo trip with travelers, category allocations, expenses, and itinerary.
  /// Returns the newly created tripId.
  static Future<String> seedDemoTrip({
    required TripRepository tripRepo,
    required ExpenseRepository expenseRepo,
    ItineraryRepository? itineraryRepo,
  }) async {
    final now = DateTime.now();

    // 1. Create Trip with default allocations & destination dates
    final tripId = await tripRepo.createTrip(
      name: demoTripName,
      totalBudgetPaise: demoBudgetPaise,
      days: demoDays,
      travelerNames: demoTravelers,
      destination: 'North Goa, India',
      startDate: now.subtract(const Duration(days: 1)),
      endDate: now.add(const Duration(days: 2)),
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

    // 3. Log realistic demo expenses across categories, payers, tags & notes
    await expenseRepo.addExpense(
      tripId: tripId,
      description: 'Beachside Villa booking (2 nights)',
      amountPaise: 1600000,
      category: TripCategory.stay.key,
      paidBy: aaravId,
      createdAt: now.subtract(const Duration(days: 3)),
      splits: _equalSplits(1600000, allTravelerIds),
      tags: const ['villa', 'shared'],
      notes: 'Advance + check-in balance paid at Candolim',
    );

    await expenseRepo.addExpense(
      tripId: tripId,
      description: 'SUV Rental & Highway Fuel',
      amountPaise: 840000,
      category: TripCategory.transport.key,
      paidBy: kabirId,
      createdAt: now.subtract(const Duration(days: 2, hours: 4)),
      splits: _equalSplits(840000, allTravelerIds),
      tags: const ['cab', 'fuel'],
    );

    await expenseRepo.addExpense(
      tripId: tripId,
      description: 'Seafood Dinner at Curlies Shack',
      amountPaise: 520000,
      category: TripCategory.food.key,
      paidBy: diyaId,
      createdAt: now.subtract(const Duration(days: 2)),
      splits: _equalSplits(520000, allTravelerIds),
      tags: const ['dinner', 'seafood'],
      notes: 'Includes starters and sunset drinks',
    );

    await expenseRepo.addExpense(
      tripId: tripId,
      description: 'Scuba Diving & Parasailing',
      amountPaise: 720000,
      category: TripCategory.activities.key,
      paidBy: rohanId,
      createdAt: now.subtract(const Duration(days: 1)),
      splits: _equalSplits(720000, allTravelerIds),
      tags: const ['ticket', 'water-sports'],
    );

    await expenseRepo.addExpense(
      tripId: tripId,
      description: 'Goan Cashews & Bebinca Sweets',
      amountPaise: 180000,
      category: TripCategory.shopping.key,
      paidBy: aaravId,
      createdAt: now.subtract(const Duration(hours: 6)),
      splits: _equalSplits(180000, allTravelerIds),
      tags: const ['souvenir', 'optional'],
    );

    // 4. Optional Day-by-Day Itinerary items
    if (itineraryRepo != null) {
      await itineraryRepo.addItem(
        tripId: tripId,
        dayNumber: 1,
        title: 'Check-in at Candolim Beachside Villa',
        location: 'Candolim Beach Rd, North Goa',
        startTimeMinutes: 13 * 60, // 01:00 PM
        category: TripCategory.stay.key,
        estimatedCostPaise: 1600000,
        notes: 'Confirm early check-in and parking spot',
        isCompleted: true,
      );
      await itineraryRepo.addItem(
        tripId: tripId,
        dayNumber: 1,
        title: 'Sunset dinner at Curlies Beach Shack',
        location: 'Anjuna Beach, Goa',
        startTimeMinutes: 18 * 60 + 30, // 06:30 PM
        category: TripCategory.food.key,
        estimatedCostPaise: 500000,
        isCompleted: true,
      );
      await itineraryRepo.addItem(
        tripId: tripId,
        dayNumber: 2,
        title: 'Scuba Diving & Water Sports at Grande Island',
        location: 'Sinquerim Jetty, Goa',
        startTimeMinutes: 9 * 60, // 09:00 AM
        category: TripCategory.activities.key,
        estimatedCostPaise: 720000,
        notes: 'Carry swimwear and waterproof pouch',
        isCompleted: false,
      );
      await itineraryRepo.addItem(
        tripId: tripId,
        dayNumber: 3,
        title: 'Chapora Fort & Vagator Cliff Cafes',
        location: 'Chapora Fort, Vagator',
        startTimeMinutes: 16 * 60 + 30, // 04:30 PM
        category: TripCategory.activities.key,
        estimatedCostPaise: 250000,
        isCompleted: false,
      );
      await itineraryRepo.addItem(
        tripId: tripId,
        dayNumber: 4,
        title: 'Mapusa Market Cashew Shopping & Departure',
        location: 'Mapusa Municipal Market, Goa',
        startTimeMinutes: 11 * 60, // 11:00 AM
        category: TripCategory.shopping.key,
        estimatedCostPaise: 200000,
        isCompleted: false,
      );
    }

    return tripId;
  }
}
