import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/constants/categories.dart';
import 'package:yeetrip/core/ml/smart_categorizer.dart';

void main() {
  group('SmartCategorizer - ML Keyword Classification Tests', () {
    const categorizer = SmartCategorizer();

    test('classifies Food expenses accurately across various Indian cuisines & apps', () {
      final samples = [
        'Hyderabadi Chicken Biryani and Thali',
        'Filter Coffee, Idli and Masala Dosa',
        'Swiggy dinner order with Dominos Pizza',
        'Lunch at highway Dhaba with tandoori roti',
        'McDonalds burger, fries and coke',
        'Evening snacks at local bakery and chai',
        'Starbucks cold brew and cheesecake',
      ];

      for (final sample in samples) {
        final prediction = categorizer.predict(sample);
        expect(
          prediction.categoryKey,
          equals(TripCategory.food.key),
          reason: 'Failed for: $sample',
        );
        expect(prediction.confidence, greaterThanOrEqualTo(0.5));
        expect(prediction.matchedTokens, isNotEmpty);
      }
    });

    test('classifies Transport expenses with Indian transit & fuel keywords', () {
      final samples = [
        'Uber cab ride to Dabolim Airport',
        'HPCL Petrol pump 25L Speed fuel',
        'Highway toll plaza Fastag recharge',
        'Goa scooter rental for 3 days',
        'IRCTC train tickets from Mumbai to Madgaon',
        'IndiGo flight tickets to Goa',
        'Ola auto fare to Mobor beach',
        'Redbus AC sleeper bus tickets',
      ];

      for (final sample in samples) {
        final prediction = categorizer.predict(sample);
        expect(
          prediction.categoryKey,
          equals(TripCategory.transport.key),
          reason: 'Failed for: $sample',
        );
        expect(prediction.confidence, greaterThanOrEqualTo(0.5));
      }
    });

    test('classifies Stay expenses for hotels, resorts, hostels, and villas', () {
      final samples = [
        'OYO Rooms near Calangute beach',
        'Airbnb ocean view villa for 4 nights',
        'Taj Exotica resort and spa checkin',
        'Zostel backpacker hostel booking',
        'Heritage homestay cottage reservation',
        'Marriott hotel room service',
      ];

      for (final sample in samples) {
        final prediction = categorizer.predict(sample);
        expect(
          prediction.categoryKey,
          equals(TripCategory.stay.key),
          reason: 'Failed for: $sample',
        );
        expect(prediction.confidence, greaterThanOrEqualTo(0.5));
      }
    });

    test('classifies Activities expenses for adventure, sightseeing, and nightlife', () {
      final samples = [
        'Scuba diving and snorkeling at Grand Island',
        'Water sports package with parasailing and jetski',
        'Aguada Fort entry tickets and camera pass',
        'Dudhsagar waterfall jungle trekking guide',
        'Mandovi river dinner cruise boat ride',
        'Club Tito entry pass and casino',
      ];

      for (final sample in samples) {
        final prediction = categorizer.predict(sample);
        expect(
          prediction.categoryKey,
          equals(TripCategory.activities.key),
          reason: 'Failed for: $sample',
        );
        expect(prediction.confidence, greaterThanOrEqualTo(0.5));
      }
    });

    test('classifies Shopping expenses for retail, souvenirs, and supplies', () {
      final samples = [
        'D-Mart supermarket groceries and water bottles',
        'Decathlon hiking shoes and swimming goggles',
        'Goan cashew nuts and handmade spices bazaar',
        'Souvenirs and handicraft gifts from Anjuna flea market',
        'Wine shop local feni and beer',
      ];

      for (final sample in samples) {
        final prediction = categorizer.predict(sample);
        expect(
          prediction.categoryKey,
          equals(TripCategory.shopping.key),
          reason: 'Failed for: $sample',
        );
        expect(prediction.confidence, greaterThanOrEqualTo(0.5));
      }
    });

    test('classifies Buffer expenses for medical, fines, and emergencies', () {
      final samples = [
        'Pharmacy emergency medicine and painkiller',
        'Traffic police challan fine for helmet',
        'Hotel bellboy tips and gratuity',
      ];

      for (final sample in samples) {
        final prediction = categorizer.predict(sample);
        expect(
          prediction.categoryKey,
          equals(TripCategory.buffer.key),
          reason: 'Failed for: $sample',
        );
        expect(prediction.confidence, greaterThanOrEqualTo(0.4));
      }
    });

    test('handles empty input and stop words safely without crashing', () {
      final emptyResult = categorizer.predict('');
      expect(emptyResult.confidence, equals(0.0));
      expect(emptyResult.matchedTokens, isEmpty);

      final stopwordResult = categorizer.predict('the of with on in');
      expect(stopwordResult.confidence, equals(0.0));
      expect(stopwordResult.matchedTokens, isEmpty);
    });
  });
}
