import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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

  /// Recognizes text from a local image file using on-device Google ML Kit OCR.
  /// Uses 2D spatial clustering to preserve columns and row alignment.
  /// Runs on Android & iOS devices completely offline.
  Future<String> recognizeTextFromImage(String imagePath) async {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return '';
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final latinRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      RecognizedText recognizedText;
      try {
        recognizedText = await latinRecognizer.processImage(inputImage);
      } finally {
        await latinRecognizer.close();
      }

      String spatialText = reconstructSpatialText(recognizedText);

      // If Latin text is sparse or empty, attempt Devanagari recognition
      if (spatialText.trim().length < 15) {
        try {
          final devanagariRecognizer = TextRecognizer(script: TextRecognitionScript.devanagiri);
          try {
            final devanagariText = await devanagariRecognizer.processImage(inputImage);
            final devanagariSpatial = reconstructSpatialText(devanagariText);
            if (devanagariSpatial.trim().length > spatialText.trim().length) {
              spatialText = devanagariSpatial;
            }
          } finally {
            await devanagariRecognizer.close();
          }
        } catch (e) {
          debugPrint('Devanagari OCR fallback: $e');
        }
      }

      return spatialText;
    } catch (e) {
      debugPrint('Error performing OCR on receipt image: $e');
      return '';
    }
  }

  /// Reconstructs 2D physical receipt rows from OCR bounding boxes.
  /// Solves the multi-column disconnect where labels (e.g. "TOTAL") and
  /// values (e.g. "1,450.00") are placed in separate blocks.
  static String reconstructSpatialText(RecognizedText recognized) {
    final allLines = <TextLine>[];
    for (final block in recognized.blocks) {
      allLines.addAll(block.lines);
    }

    if (allLines.isEmpty) {
      return recognized.text;
    }

    // Sort lines primarily by vertical center
    allLines.sort((a, b) {
      final aCenterY = a.boundingBox.top + (a.boundingBox.height / 2);
      final bCenterY = b.boundingBox.top + (b.boundingBox.height / 2);
      return aCenterY.compareTo(bCenterY);
    });

    final rows = <List<TextLine>>[];
    for (final line in allLines) {
      final centerY = line.boundingBox.top + (line.boundingBox.height / 2);
      final lineHeight = line.boundingBox.height;

      if (rows.isEmpty) {
        rows.add([line]);
        continue;
      }

      final lastRow = rows.last;
      // Average center Y of the current row
      final rowAvgCenterY = lastRow
              .map((l) => l.boundingBox.top + (l.boundingBox.height / 2))
              .reduce((a, b) => a + b) /
          lastRow.length;
      final avgHeight = lastRow
              .map((l) => l.boundingBox.height)
              .reduce((a, b) => a + b) /
          lastRow.length;

      final threshold = (avgHeight > 0 ? avgHeight : lineHeight) * 0.6;
      final effectiveThreshold = threshold.clamp(12.0, 40.0);

      if ((centerY - rowAvgCenterY).abs() <= effectiveThreshold) {
        lastRow.add(line);
      } else {
        rows.add([line]);
      }
    }

    // Within each row, sort lines horizontally (left to right)
    final buffer = StringBuffer();
    for (final row in rows) {
      row.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
      final lineStr = row
          .map((l) => l.text.trim())
          .where((t) => t.isNotEmpty)
          .join(' ');
      if (lineStr.isNotEmpty) {
        buffer.writeln(lineStr);
      }
    }

    final reconstructed = buffer.toString().trim();
    return reconstructed.isNotEmpty ? reconstructed : recognized.text;
  }

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
