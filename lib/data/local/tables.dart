import 'package:drift/drift.dart';

/// Trips table
/// All budget numbers are in integer paise.
class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get totalBudgetPaise => integer()();
  IntColumn get days => integer()();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  DateTimeColumn get createdAt => dateTime()();

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
