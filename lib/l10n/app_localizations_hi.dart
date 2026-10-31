// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'यीट्रिप';

  @override
  String get dashboardTab => 'डैशबोर्ड';

  @override
  String get expensesTab => 'खर्चे';

  @override
  String get budgetTab => 'बजट';

  @override
  String get settleTab => 'हिसाब';

  @override
  String get settingsTab => 'सेटिंग्स';

  @override
  String get totalBudget => 'कुल बजट';

  @override
  String get duration => 'अवधि';

  @override
  String get travelers => 'यात्री';

  @override
  String get loggedExpenses => 'दर्ज खर्चे';

  @override
  String get recorded => 'दर्ज';

  @override
  String get day => 'दिन';

  @override
  String get days => 'दिन';

  @override
  String get editTripAndTravelers => 'यात्रा और यात्री संपादित करें';

  @override
  String get editTripDetails => 'यात्रा विवरण संपादित करें';

  @override
  String get dataExport => 'डेटा निर्यात';

  @override
  String dataExportDesc(String tripName) {
    return '\"$tripName\" के सभी खर्चों को एक मानक सीएसवी (CSV) फ़ाइल के रूप में निर्यात करें। इसमें दिनांक, विवरण, श्रेणी, भुगतानकर्ता और विभाजन शामिल हैं।';
  }

  @override
  String get exportAndShareCsv => 'सीएसवी निर्यात और साझा करें';

  @override
  String get exporting => 'निर्यात हो रहा है...';

  @override
  String get noExpensesToExport =>
      'निर्यात करने के लिए अभी कोई खर्च दर्ज नहीं है।';

  @override
  String get aboutYeeTrip => 'यीट्रिप के बारे में';

  @override
  String get aboutYeeTripDesc =>
      'यीट्रिप भारतीय यात्रियों के लिए विशेष रूप से तैयार किया गया एक ऑफ़लाइन-प्रथम ग्रुप ट्रिप बजट और खर्च-विभाजन ऐप है।';

  @override
  String get offlinePrivate => '100% ऑफ़लाइन और सुरक्षित';

  @override
  String get offlinePrivateDesc =>
      'सभी यात्रा डेटा और खर्च केवल आपके फोन पर रहते हैं। इंटरनेट या खाते की कोई आवश्यकता नहीं है।';

  @override
  String get precisionTitle => 'सटीक पूर्णांक पैसे शुद्धता';

  @override
  String get precisionDesc =>
      'दशमलव त्रुटियों से बचने के लिए सटीक पैसों में गणना। भारतीय संख्या प्रणाली में प्रदर्शित (₹1,00,000)।';

  @override
  String get settlementTitle => 'न्यूनतम लेनदेन में हिसाब चुकता';

  @override
  String get settlementDesc =>
      'न्यूनतम बैंक ट्रांसफर द्वारा सभी उधारी चुकता करने वाला स्मार्ट एल्गोरिदम।';

  @override
  String get version => 'संस्करण';

  @override
  String get language => 'भाषा (Language)';

  @override
  String get languageSubtitle => 'अपनी पसंदीदा भाषा चुनें';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी (Hindi)';

  @override
  String get systemDefault => 'सिस्टम डिफ़ॉल्ट';
}
