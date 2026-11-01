import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/constants/categories.dart';
import 'package:yeetrip/core/receipt_parser.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/features/expenses/presentation/screens/add_edit_expense_screen.dart';
import 'package:yeetrip/features/expenses/presentation/widgets/receipt_scanner_sheet.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

void main() {
  group('ReceiptScannerSheet & Bill Scanner UI Tests', () {
    testWidgets('ReceiptScannerSheet displays options, loads sample receipt, and applies it',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      ReceiptData? appliedReceipt;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    ReceiptScannerSheet.show(
                      context,
                      onReceiptApplied: (receipt) {
                        appliedReceipt = receipt;
                      },
                    );
                  },
                  child: const Text('Open Scanner'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open scanner sheet
      await tester.tap(find.text('Open Scanner'));
      await tester.pumpAndSettle();

      // Verify header and sample chips exist
      expect(find.text('Scan Bill / Receipt'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text("Fisherman's Wharf (Goa)"), findsOneWidget);
      expect(find.text('Bharat Petroleum (Highway Fuel)'), findsOneWidget);

      // Tap Fisherman's Wharf sample chip
      await tester.tap(find.text("Fisherman's Wharf (Goa)"));
      await tester.pumpAndSettle();

      // Verify extracted details card appears
      expect(find.text('EXTRACTED BILL DETAILS'), findsOneWidget);
      expect(find.text("THE FISHERMAN'S WHARF"), findsOneWidget);
      expect(find.text('₹1,845.50'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);

      // Tap Apply to Expense button
      final applyBtn = find.byKey(const Key('apply_scanned_receipt_button'));
      expect(applyBtn, findsOneWidget);
      await tester.tap(applyBtn);
      await tester.pumpAndSettle();

      // Verify callback received the receipt data with integer paise
      expect(appliedReceipt, isNotNull);
      expect(appliedReceipt!.amountPaise, equals(184550));
      expect(appliedReceipt!.merchantName, equals("THE FISHERMAN'S WHARF"));
      expect(appliedReceipt!.suggestedCategory, equals(TripCategory.food.key));
    });

    testWidgets('AddEditExpenseScreen auto-fills details when bill is scanned and applied',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final trip = TripWithDetails(
        id: 'trip-1',
        name: 'Goa Trip',
        totalBudgetPaise: 5000000,
        days: 3,
        currency: 'INR',
        createdAt: DateTime.now(),
        travelers: const [
          Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
          Traveler(id: 't-2', tripId: 'trip-1', name: 'Diya'),
        ],
        categoryAllocations: const {},
        totalSpentPaise: 0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripDetailsProvider('trip-1').overrideWith(
              (ref) => Stream.value(trip),
            ),
          ],
          child: const MaterialApp(
            home: AddEditExpenseScreen(tripId: 'trip-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Scan Bill Banner button exists
      final scanBannerBtn = find.byKey(const Key('scan_bill_banner_button'));
      expect(scanBannerBtn, findsOneWidget);

      // Tap Scan Bill Banner button
      await tester.tap(scanBannerBtn);
      await tester.pumpAndSettle();

      // Select Bharat Petroleum Fuel sample
      expect(find.text('Bharat Petroleum (Highway Fuel)'), findsOneWidget);
      await tester.tap(find.text('Bharat Petroleum (Highway Fuel)'));
      await tester.pumpAndSettle();

      // Verify extracted details
      expect(find.text('BHARAT PETROLEUM CORP LTD'), findsOneWidget);
      expect(find.text('₹2,500'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);

      // Tap Apply to Expense
      await tester.tap(find.byKey(const Key('apply_scanned_receipt_button')));
      await tester.pumpAndSettle();

      // Verify AddEditExpenseScreen fields were auto-filled
      final descField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'BHARAT PETROLEUM CORP LTD'),
      );
      expect(descField.controller?.text, equals('BHARAT PETROLEUM CORP LTD'));

      final amountField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, '2500.00'),
      );
      expect(amountField.controller?.text, equals('2500.00'));

      // Verify SnackBar was shown
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Applied receipt: BHARAT PETROLEUM CORP LTD'), findsOneWidget);
    });

    testWidgets('AppBar scan receipt icon button also opens scanner and allows custom text',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final trip = TripWithDetails(
        id: 'trip-1',
        name: 'Goa Trip',
        totalBudgetPaise: 5000000,
        days: 3,
        currency: 'INR',
        createdAt: DateTime.now(),
        travelers: const [
          Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
        ],
        categoryAllocations: const {},
        totalSpentPaise: 0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripDetailsProvider('trip-1').overrideWith(
              (ref) => Stream.value(trip),
            ),
          ],
          child: const MaterialApp(
            home: AddEditExpenseScreen(tripId: 'trip-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap AppBar Scan Receipt icon button
      final appbarBtn = find.byKey(const Key('appbar_scan_receipt_button'));
      expect(appbarBtn, findsOneWidget);
      await tester.tap(appbarBtn);
      await tester.pumpAndSettle();

      // Paste custom receipt text
      final textField = find.widgetWithText(TextField, 'Receipt Text / OCR Output');
      expect(textField, findsOneWidget);
      await tester.enterText(
        textField,
        'Taj Exotica Resort & Spa\nDate: 20/10/2026\nGrand Total: ₹ 1,25,000.00',
      );
      await tester.pumpAndSettle();

      // Verify live extraction
      expect(find.text('Taj Exotica Resort & Spa'), findsOneWidget);
      expect(find.text('₹1,25,000'), findsOneWidget);
      expect(
        find.descendant(of: find.byType(Card), matching: find.text('Stay')),
        findsOneWidget,
      );

      // Apply
      await tester.tap(find.byKey(const Key('apply_scanned_receipt_button')));
      await tester.pumpAndSettle();

      // Verify fields
      expect(find.text('Taj Exotica Resort & Spa'), findsOneWidget);
      expect(find.text('125000.00'), findsOneWidget);
    });
  });
}
