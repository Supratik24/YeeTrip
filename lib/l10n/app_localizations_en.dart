// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'YeeTrip';

  @override
  String get dashboardTab => 'Dashboard';

  @override
  String get expensesTab => 'Expenses';

  @override
  String get budgetTab => 'Budget';

  @override
  String get settleTab => 'Settle';

  @override
  String get settingsTab => 'Settings';

  @override
  String get totalBudget => 'Total budget';

  @override
  String get duration => 'Duration';

  @override
  String get travelers => 'Travelers';

  @override
  String get loggedExpenses => 'Logged expenses';

  @override
  String get recorded => 'recorded';

  @override
  String get day => 'day';

  @override
  String get days => 'days';

  @override
  String get editTripAndTravelers => 'Edit trip & travelers';

  @override
  String get editTripDetails => 'Edit trip details';

  @override
  String get dataExport => 'Data export';

  @override
  String dataExportDesc(String tripName) {
    return 'Export all logged expenses for \"$tripName\" as an RFC 4180 compliant CSV file. Includes date, description, category, payer, amount in ₹, and split breakdown.';
  }

  @override
  String get exportAndShareCsv => 'Export & share CSV';

  @override
  String get exporting => 'Exporting...';

  @override
  String get noExpensesToExport => 'No expenses logged yet to export.';

  @override
  String get aboutYeeTrip => 'About YeeTrip';

  @override
  String get aboutYeeTripDesc =>
      'YeeTrip is an offline-first group trip budget and expense-splitting app crafted specifically for Indian travelers.';

  @override
  String get offlinePrivate => '100% Offline & Private';

  @override
  String get offlinePrivateDesc =>
      'All trip data and expenses remain strictly on this phone. No accounts or internet required.';

  @override
  String get precisionTitle => 'Exact Integer Paise Precision';

  @override
  String get precisionDesc =>
      'Calculated in exact integer paise to prevent floating-point rounding errors. Formatted in standard Indian numbering (₹1,00,000).';

  @override
  String get settlementTitle => 'Minimum Transactions Settlement';

  @override
  String get settlementDesc =>
      'Greedy balance netting algorithm calculates the fewest peer-to-peer transfers to settle all trip debts.';

  @override
  String get version => 'Version';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Select your preferred display language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी (Hindi)';

  @override
  String get systemDefault => 'System Default';
}
