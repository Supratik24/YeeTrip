import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'YeeTrip'**
  String get appTitle;

  /// No description provided for @dashboardTab.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTab;

  /// No description provided for @expensesTab.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTab;

  /// No description provided for @budgetTab.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetTab;

  /// No description provided for @settleTab.
  ///
  /// In en, this message translates to:
  /// **'Settle'**
  String get settleTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @totalBudget.
  ///
  /// In en, this message translates to:
  /// **'Total budget'**
  String get totalBudget;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @travelers.
  ///
  /// In en, this message translates to:
  /// **'Travelers'**
  String get travelers;

  /// No description provided for @loggedExpenses.
  ///
  /// In en, this message translates to:
  /// **'Logged expenses'**
  String get loggedExpenses;

  /// No description provided for @recorded.
  ///
  /// In en, this message translates to:
  /// **'recorded'**
  String get recorded;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @editTripAndTravelers.
  ///
  /// In en, this message translates to:
  /// **'Edit trip & travelers'**
  String get editTripAndTravelers;

  /// No description provided for @editTripDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit trip details'**
  String get editTripDetails;

  /// No description provided for @dataExport.
  ///
  /// In en, this message translates to:
  /// **'Data export'**
  String get dataExport;

  /// No description provided for @dataExportDesc.
  ///
  /// In en, this message translates to:
  /// **'Export all logged expenses for \"{tripName}\" as an RFC 4180 compliant CSV file. Includes date, description, category, payer, amount in ₹, and split breakdown.'**
  String dataExportDesc(String tripName);

  /// No description provided for @exportAndShareCsv.
  ///
  /// In en, this message translates to:
  /// **'Export & share CSV'**
  String get exportAndShareCsv;

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exporting;

  /// No description provided for @noExpensesToExport.
  ///
  /// In en, this message translates to:
  /// **'No expenses logged yet to export.'**
  String get noExpensesToExport;

  /// No description provided for @aboutYeeTrip.
  ///
  /// In en, this message translates to:
  /// **'About YeeTrip'**
  String get aboutYeeTrip;

  /// No description provided for @aboutYeeTripDesc.
  ///
  /// In en, this message translates to:
  /// **'YeeTrip is an offline-first group trip budget and expense-splitting app crafted specifically for Indian travelers.'**
  String get aboutYeeTripDesc;

  /// No description provided for @offlinePrivate.
  ///
  /// In en, this message translates to:
  /// **'100% Offline & Private'**
  String get offlinePrivate;

  /// No description provided for @offlinePrivateDesc.
  ///
  /// In en, this message translates to:
  /// **'All trip data and expenses remain strictly on this phone. No accounts or internet required.'**
  String get offlinePrivateDesc;

  /// No description provided for @precisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Exact Integer Paise Precision'**
  String get precisionTitle;

  /// No description provided for @precisionDesc.
  ///
  /// In en, this message translates to:
  /// **'Calculated in exact integer paise to prevent floating-point rounding errors. Formatted in standard Indian numbering (₹1,00,000).'**
  String get precisionDesc;

  /// No description provided for @settlementTitle.
  ///
  /// In en, this message translates to:
  /// **'Minimum Transactions Settlement'**
  String get settlementTitle;

  /// No description provided for @settlementDesc.
  ///
  /// In en, this message translates to:
  /// **'Greedy balance netting algorithm calculates the fewest peer-to-peer transfers to settle all trip debts.'**
  String get settlementDesc;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred display language'**
  String get languageSubtitle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी (Hindi)'**
  String get hindi;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
