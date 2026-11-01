import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/constants/categories.dart';
import 'package:yeetrip/core/receipt_parser.dart';
import 'package:yeetrip/core/receipt_scanner_service.dart';

void main() {
  group('ReceiptParser - Indian Receipt Parsing Tests', () {
    test('parses Goa seafood restaurant bill accurately', () {
      const sample = '''
THE FISHERMAN'S WHARF
Mobor Beach, Cavelossim, Goa - 403731
GSTIN: 30AABCF1234F1Z8
Date: 15/10/2026  Time: 20:45
Table: 12  Order: 4892

King Fish Rava Fry          1     450.00
Goan Prawn Curry            1     580.00
Steamed Rice                2     240.00
Fresh Lime Soda             2     180.00
----------------------------------------
Subtotal:                        1450.00
CGST 2.5%                          36.25
SGST 2.5%                          36.25
Service Charge 5%                  72.50
Round Off                           0.50
----------------------------------------
GRAND TOTAL:                 ₹ 1,845.50
----------------------------------------
Thank You! Visit Us Again
''';

      final result = ReceiptParser.parse(sample);

      expect(result.merchantName, equals("THE FISHERMAN'S WHARF"));
      expect(result.amountPaise, equals(184550)); // ₹1,845.50 = 184550 paise
      expect(result.date, equals(DateTime(2026, 10, 15)));
      expect(result.suggestedCategory, equals(TripCategory.food.key));
      expect(result.confidence, greaterThanOrEqualTo(0.8));
    });

    test('parses highway petrol pump slip accurately', () {
      const sample = '''
BHARAT PETROLEUM CORP LTD
NH-66 Highway Fuel Station, Kolhapur
Date: 12-Oct-2026  Time: 14:12
Pump: 04  Nozzle: 02
Product: SPEED PETROL
Rate: Rs. 104.50/Ltr
Volume: 23.92 Ltrs
----------------------------------------
TOTAL SALE:                 Rs. 2500.00
----------------------------------------
Paid via: UPI / PhonePe
Save Fuel, Save Earth!
''';

      final result = ReceiptParser.parse(sample);

      expect(result.merchantName, equals('BHARAT PETROLEUM CORP LTD'));
      expect(result.amountPaise, equals(250000)); // ₹2,500.00 = 250000 paise
      expect(result.date, equals(DateTime(2026, 10, 12)));
      expect(result.suggestedCategory, equals(TripCategory.transport.key));
      expect(result.confidence, greaterThanOrEqualTo(0.8));
    });

    test('parses supermarket groceries invoice with ISO date', () {
      const sample = '''
DMART READY - AVENUE SUPERMARTS
Candolim Main Road, Goa - 403515
TAX INVOICE / CASH MEMO
Date: 2026-10-14  Time: 11:30

Description             Qty    Rate    Amt
Biscuits & Snacks        4    30.00  120.00
Mineral Water 5L         2    90.00  180.00
Sunscreen SPF 50         1   450.00  450.00
Cold Drinks & Juices     6    60.00  360.00
Tissue & Wet Wipes       2   105.00  210.00
-------------------------------------------
TOTAL ITEMS: 15
NET PAYABLE:                   1,320.00
-------------------------------------------
You Saved: Rs. 185.00 Today!
''';

      final result = ReceiptParser.parse(sample);

      expect(result.merchantName, equals('DMART READY - AVENUE SUPERMARTS'));
      expect(result.amountPaise, equals(132000)); // ₹1,320.00 = 132000 paise
      expect(result.date, equals(DateTime(2026, 10, 14)));
      expect(result.suggestedCategory, equals(TripCategory.shopping.key));
      expect(result.confidence, greaterThanOrEqualTo(0.8));
    });

    test('parses cab ride receipt accurately', () {
      const sample = '''
Uber India Systems Pvt Ltd
TRIP RECEIPT
Trip Date: 16 Oct 2026
Driver: Ramesh K (Goa Taxi)

Base Fare                          120.00
Distance & Time Fare               320.00
Toll Charges                        45.00
-----------------------------------------
TRIP TOTAL:                      ₹ 485.00
-----------------------------------------
Payment Method: Cash / UPI Paid
Thank you for riding with Uber
''';

      final result = ReceiptParser.parse(sample);

      expect(result.merchantName, equals('Uber India Systems Pvt Ltd'));
      expect(result.amountPaise, equals(48500)); // ₹485.00 = 48500 paise
      expect(result.date, equals(DateTime(2026, 10, 16)));
      expect(result.suggestedCategory, equals(TripCategory.transport.key));
      expect(result.confidence, greaterThanOrEqualTo(0.8));
    });

    test('handles trailing /- notation and Indian lakh amounts', () {
      const sample = '''
Taj Exotica Resort & Spa
Benaulim, Goa
Date: 20/10/2026
Luxury Ocean Villa - 2 Nights
----------------------------------
Total Bill: 1,25,000/-
Paid in full
''';

      final result = ReceiptParser.parse(sample);

      expect(result.merchantName, equals('Taj Exotica Resort & Spa'));
      expect(result.amountPaise, equals(12500000)); // ₹1,25,000.00 = 12500000 paise
      expect(result.date, equals(DateTime(2026, 10, 20)));
      expect(result.suggestedCategory, equals(TripCategory.stay.key));
    });

    test('handles scuba diving activity ticket', () {
      const sample = '''
Atlantis Water Sports & Scuba
Grand Island, North Goa
Date: 18-Oct-2026
2x Scuba Diving with Video Package
----------------------------------
Amount Payable: ₹ 5,600.00
''';

      final result = ReceiptParser.parse(sample);

      expect(result.merchantName, equals('Atlantis Water Sports & Scuba'));
      expect(result.amountPaise, equals(560000)); // ₹5,600.00
      expect(result.suggestedCategory, equals(TripCategory.activities.key));
    });

    test('handles empty or whitespace input gracefully', () {
      final result = ReceiptParser.parse('   \n  \t ');
      expect(result.amountPaise, isNull);
      expect(result.merchantName, isNull);
      expect(result.date, isNull);
      expect(result.confidence, equals(0.0));
    });

    test('handles text with no monetary amounts safely', () {
      final result = ReceiptParser.parse('''
Goa Handicrafts & Souvenirs
Panaji Main Market, Goa
Visit us again!
''');
      expect(result.amountPaise, isNull);
      expect(result.merchantName, equals('Goa Handicrafts & Souvenirs'));
    });

    test('ReceiptScannerService provides ready samples that all parse valid amounts', () {
      const service = ReceiptScannerService();
      final samples = service.getSampleReceipts();

      expect(samples.length, equals(4));
      for (final sample in samples) {
        final parsed = service.parseText(sample.rawText);
        expect(parsed.amountPaise, isNotNull);
        expect(parsed.amountPaise!, greaterThan(0));
        expect(parsed.merchantName, isNotNull);
        expect(parsed.date, isNotNull);
      }
    });
  });
}
