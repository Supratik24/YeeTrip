import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/features/settle/services/upi_payment_launcher.dart';

void main() {
  group('UpiPaymentLauncher Tests', () {
    test('buildUpiUri creates valid NPCI UPI payment deep-link URI', () {
      final uri = UpiPaymentLauncher.buildUpiUri(
        payeeVpa: 'aarav@okhdfcbank',
        payeeName: 'Aarav Patel',
        amountPaise: 450050, // ₹4500.50
        note: 'Goa Trip Settlement',
      );

      expect(uri.scheme, equals('upi'));
      expect(uri.host, equals('pay'));
      expect(uri.queryParameters['pa'], equals('aarav@okhdfcbank'));
      expect(uri.queryParameters['pn'], equals('Aarav Patel'));
      expect(uri.queryParameters['am'], equals('4500.50'));
      expect(uri.queryParameters['cu'], equals('INR'));
      expect(uri.queryParameters['tn'], equals('Goa Trip Settlement'));
    });

    test('buildUpiUri formats whole rupees with two decimal places', () {
      final uri = UpiPaymentLauncher.buildUpiUri(
        payeeVpa: 'diya@icici',
        payeeName: 'Diya Sharma',
        amountPaise: 200000, // ₹2000
      );

      expect(uri.queryParameters['am'], equals('2000.00'));
      expect(uri.queryParameters['cu'], equals('INR'));
      expect(uri.queryParameters['tn'], equals('YeeTrip Settlement'));
    });

    test('buildUpiUri handles single-digit paise amounts correctly', () {
      final uri = UpiPaymentLauncher.buildUpiUri(
        payeeVpa: 'user@upi',
        payeeName: 'User',
        amountPaise: 5, // ₹0.05
      );

      expect(uri.queryParameters['am'], equals('0.05'));
    });
  });
}
