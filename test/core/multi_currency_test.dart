import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/constants/currencies.dart';
import 'package:yeetrip/core/ml/spending_velocity_predictor.dart';
import 'package:yeetrip/core/money.dart';

void main() {
  group('Multi-Currency Formatting & Conversion', () {
    test('formats INR with Indian grouping and non-INR with Western grouping', () {
      expect(Money.formatAmount(12500000, currencyCode: 'INR'), '₹1,25,000');
      expect(Money.formatAmount(12500000, currencyCode: 'USD'), '\$125,000');
      expect(Money.formatAmount(240050, currencyCode: 'EUR'), '€2,400.50');
      expect(Money.formatAmount(100000, currencyCode: 'GBP'), '£1,000');
      expect(Money.formatAmount(50000, currencyCode: 'AED'), 'AED 500');
      expect(Money.formatAmount(250000, currencyCode: 'THB'), '฿2,500');
    });

    test('converts foreign minor units into integer target minor units', () {
      // $25.00 at 1 USD = 84.5 INR -> ₹2,112.50 = 211250 paise
      expect(
        Money.convertAmount(2500, exchangeRate: 84.5),
        equals(211250),
      );
      expect(
        () => Money.convertAmount(1000, exchangeRate: 0),
        throwsArgumentError,
      );
    });

    test('TripCurrency.suggestedRate calculates directional cross-rate', () {
      expect(TripCurrency.suggestedRate('INR', 'INR'), equals(1.0));
      expect(TripCurrency.suggestedRate('USD', 'INR'), greaterThan(50));
      expect(TripCurrency.suggestedRate('INR', 'USD'), lessThan(0.05));
    });

    test('SpendingVelocityPredictor formats summary in trip currency', () {
      const predictor = SpendingVelocityPredictor();
      final report = predictor.calculate(
        totalBudgetPaise: 100000, // $1,000
        totalSpentPaise: 20000, // $200 on day 1
        totalTripDays: 4,
        elapsedDays: 1,
        currencyCode: 'USD',
      );
      expect(report.summaryMessage, contains('\$200'));
    });
  });
}
