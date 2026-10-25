import 'package:yeetrip/core/money.dart';
import '../test_helper.dart';

void main() async {
  group('Money.paiseToDecimalString', () {
    test('converts zero paise', () {
      expect(Money.paiseToDecimalString(0), '0.00');
    });

    test('converts single-digit paise', () {
      expect(Money.paiseToDecimalString(5), '0.05');
    });

    test('converts two-digit paise', () {
      expect(Money.paiseToDecimalString(50), '0.50');
      expect(Money.paiseToDecimalString(99), '0.99');
    });

    test('converts typical amounts', () {
      expect(Money.paiseToDecimalString(240050), '2400.50');
      expect(Money.paiseToDecimalString(240000), '2400.00');
      expect(Money.paiseToDecimalString(12500000), '125000.00');
    });

    test('converts negative paise correctly', () {
      expect(Money.paiseToDecimalString(-240050), '-2400.50');
      expect(Money.paiseToDecimalString(-5), '-0.05');
      expect(Money.paiseToDecimalString(-50), '-0.50');
    });
  });

  group('Money.decimalStringToPaise - Valid Inputs', () {
    test('accepts plain integer rupees', () {
      expect(Money.decimalStringToPaise('2400'), 240000);
      expect(Money.decimalStringToPaise('0'), 0);
      expect(Money.decimalStringToPaise('100'), 10000);
    });

    test('accepts amounts with commas', () {
      expect(Money.decimalStringToPaise('2,400'), 240000);
      expect(Money.decimalStringToPaise('1,25,000'), 12500000);
      expect(Money.decimalStringToPaise('1,00,00,000'), 1000000000);
    });

    test('accepts amounts with 1 decimal digit', () {
      expect(Money.decimalStringToPaise('2,400.5'), 240050);
      expect(Money.decimalStringToPaise('0.5'), 50);
      expect(Money.decimalStringToPaise('10.9'), 1090);
    });

    test('accepts amounts with 2 decimal digits', () {
      expect(Money.decimalStringToPaise('2400.50'), 240050);
      expect(Money.decimalStringToPaise('2,400.05'), 240005);
      expect(Money.decimalStringToPaise('0.05'), 5);
      expect(Money.decimalStringToPaise('0.01'), 1);
      expect(Money.decimalStringToPaise('1,25,000.75'), 12500075);
    });

    test('accepts trailing decimal point with no decimal digits', () {
      expect(Money.decimalStringToPaise('2400.'), 240000);
    });

    test('accepts amounts with surrounding whitespace', () {
      expect(Money.decimalStringToPaise('  2400.50  '), 240050);
    });
  });

  group('Money.decimalStringToPaise - Rejected Inputs', () {
    test('rejects negative amounts', () {
      expect(() => Money.decimalStringToPaise('-2400'), throwsFormatException);
      expect(() => Money.decimalStringToPaise('-0.5'), throwsFormatException);
      expect(() => Money.decimalStringToPaise('-1,25,000.50'), throwsFormatException);
    });

    test('rejects more than 2 decimal digits', () {
      expect(() => Money.decimalStringToPaise('2400.505'), throwsFormatException);
      expect(() => Money.decimalStringToPaise('10.123'), throwsFormatException);
      expect(() => Money.decimalStringToPaise('0.001'), throwsFormatException);
    });

    test('rejects invalid characters, letters, and symbols', () {
      expect(() => Money.decimalStringToPaise('2400abc'), throwsFormatException);
      expect(() => Money.decimalStringToPaise('₹2400'), throwsFormatException);
      expect(() => Money.decimalStringToPaise('hello'), throwsFormatException);
      expect(() => Money.decimalStringToPaise('12.3.4'), throwsFormatException);
      expect(() => Money.decimalStringToPaise('24 00'), throwsFormatException);
    });

    test('rejects empty or whitespace-only strings', () {
      expect(() => Money.decimalStringToPaise(''), throwsFormatException);
      expect(() => Money.decimalStringToPaise('   '), throwsFormatException);
    });
  });

  group('Money.formatRupees - Indian Numbering Grouping', () {
    test('formats zero paise', () {
      expect(Money.formatRupees(0), '₹0');
      expect(Money.formatRupees(0, alwaysShowPaise: true), '₹0.00');
    });

    test('formats small amounts', () {
      expect(Money.formatRupees(5), '₹0.05');
      expect(Money.formatRupees(50), '₹0.50');
      expect(Money.formatRupees(99), '₹0.99');
      expect(Money.formatRupees(100), '₹1');
      expect(Money.formatRupees(100, alwaysShowPaise: true), '₹1.00');
    });

    test('formats requirement examples precisely', () {
      // Prompt requirement: "Display amounts in Indian grouping (₹1,25,000 and ₹2,400.50)"
      expect(Money.formatRupees(12500000), '₹1,25,000');
      expect(Money.formatRupees(240050), '₹2,400.50');
    });

    test('formats progression through Indian lakh and crore milestones', () {
      expect(Money.formatRupees(99900), '₹999');
      expect(Money.formatRupees(100000), '₹1,000');
      expect(Money.formatRupees(1000000), '₹10,000');
      expect(Money.formatRupees(10000000), '₹1,00,000'); // 1 Lakh
      expect(Money.formatRupees(100000000), '₹10,00,000'); // 10 Lakhs
      expect(Money.formatRupees(1000000000), '₹1,00,00,000'); // 1 Crore
    });

    test('formats negative amounts', () {
      expect(Money.formatRupees(-240050), '-₹2,400.50');
      expect(Money.formatRupees(-12500000), '-₹1,25,000');
    });

    test('allows omitting currency symbol', () {
      expect(Money.formatRupees(12500000, includeSymbol: false), '1,25,000');
      expect(Money.formatRupees(240050, includeSymbol: false), '2,400.50');
    });
  });

  final ok = await runSuite('Money Utilities Tests');
  if (!ok) throw Exception('Money tests failed');
}
