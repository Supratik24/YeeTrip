import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'receipt_parser.dart';

/// Pre-configured sample receipt for instant testing, verification, and demoing.
class SampleReceipt {
  final String title;
  final String subtitle;
  final String rawText;

  const SampleReceipt({
    required this.title,
    required this.subtitle,
    required this.rawText,
  });
}

/// Service that coordinates receipt parsing, camera OCR, and sample bills.
class ReceiptScannerService {
  const ReceiptScannerService();

  /// Parses arbitrary raw OCR or pasted receipt text into [ReceiptData].
  ReceiptData parseText(String rawText) {
    return ReceiptParser.parse(rawText);
  }

  /// Built-in realistic Indian receipt samples for zero-friction testing.
  List<SampleReceipt> getSampleReceipts() {
    return const [
      SampleReceipt(
        title: "Fisherman's Wharf (Goa)",
        subtitle: "Restaurant & Bar • ₹1,845.50",
        rawText: '''
THE FISHERMAN'S WHARF
Mobor Beach, Cavelossim, Goa - 403731
GSTIN: 30AABCF1234F1Z8
Date: 15/10/2026  Time: 20:45
Table: 12  Order: 4892

ITEMS                      QTY    AMOUNT
----------------------------------------
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
''',
      ),
      SampleReceipt(
        title: "Bharat Petroleum (Highway Fuel)",
        subtitle: "Transport / Petrol • ₹2,500.00",
        rawText: '''
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
''',
      ),
      SampleReceipt(
        title: "D-Mart Supermarket (Groceries)",
        subtitle: "Shopping / Supplies • ₹1,320.00",
        rawText: '''
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
''',
      ),
      SampleReceipt(
        title: "Uber India (Cab Ride)",
        subtitle: "Transport / Taxi • ₹485.00",
        rawText: '''
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
''',
      ),
    ];
  }
}

/// Riverpod provider for [ReceiptScannerService].
final receiptScannerServiceProvider = Provider<ReceiptScannerService>((ref) {
  return const ReceiptScannerService();
});
