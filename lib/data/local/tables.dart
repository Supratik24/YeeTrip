import 'package:drift/drift.dart';

/// Trips table
/// All budget numbers are in integer minor units (e.g. paise/cents).
class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get totalBudgetPaise => integer()();
  IntColumn get days => integer()();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  DateTimeColumn get createdAt => dateTime()();

  // Modern 2026 trip enhancements
  TextColumn get destination => text().nullable()();
  TextColumn get coverPhotoPath => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Travelers table
/// Belongs to a trip with cascade delete.
class Travelers extends Table {
  TextColumn get id => text()();
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get upiVpa => text().nullable()();
  TextColumn get avatarPath => text().nullable()();
  TextColumn get phone => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// CategoryAllocations table
/// Percentage allocations per category for a trip.
class CategoryAllocations extends Table {
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get category => text()();
  IntColumn get percent => integer()();

  @override
  Set<Column> get primaryKey => {tripId, category};
}

/// Expenses table
/// Represents an expense incurred within a trip.
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get description => text()();
  IntColumn get amountPaise => integer()();
  TextColumn get category => text()();
  TextColumn get paidBy =>
      text().references(Travelers, #id, onDelete: KeyAction.cascade)();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get upiTxnId => text().nullable()();
  BoolColumn get confirmed => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get receiptImagePath => text().nullable()();

  // P0 enhancements: tags, notes, and foreign currency origin
  TextColumn get notes => text().nullable()();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get originalCurrency => text().nullable()();
  IntColumn get originalAmountPaise => integer().nullable()();
  RealColumn get exchangeRate => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// ExpenseSplits table
/// Breakdown of each traveler's share for an expense.
class ExpenseSplits extends Table {
  TextColumn get expenseId =>
      text().references(Expenses, #id, onDelete: KeyAction.cascade)();
  TextColumn get travelerId =>
      text().references(Travelers, #id, onDelete: KeyAction.cascade)();
  IntColumn get sharePaise => integer()();

  @override
  Set<Column> get primaryKey => {expenseId, travelerId};
}

/// ItineraryItems table
/// Day-by-day trip planner activities and reservations.
class ItineraryItems extends Table {
  TextColumn get id => text()();
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  IntColumn get dayNumber => integer()();
  TextColumn get title => text()();
  TextColumn get location => text().nullable()();
  TextColumn get timeSlot => text().nullable()();
  IntColumn get startTimeMinutes => integer().nullable()();
  TextColumn get category =>
      text().withDefault(const Constant('Activities'))();
  IntColumn get estimatedCostPaise =>
      integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// ExpenseComments table
/// Group discussion and dispute flags attached to an expense.
class ExpenseComments extends Table {
  TextColumn get id => text()();
  TextColumn get expenseId =>
      text().references(Expenses, #id, onDelete: KeyAction.cascade)();
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get authorTravelerId => text().nullable()();
  TextColumn get authorName => text()();
  TextColumn get body => text()();
  BoolColumn get isDispute => boolean().withDefault(const Constant(false))();
  BoolColumn get isResolved =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// TripPhotos table
/// Shared photo gallery memories contributed by travelers on a trip.
class TripPhotos extends Table {
  TextColumn get id => text()();
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get imagePath => text()();
  TextColumn get caption => text().nullable()();
  IntColumn get dayNumber => integer().withDefault(const Constant(1))();
  TextColumn get uploadedByTravelerId => text().nullable()();
  TextColumn get uploadedByName => text().withDefault(const Constant('You'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
