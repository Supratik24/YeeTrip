import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/receipt_parser.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/expenses/domain/split_calculator.dart';
import 'package:yeetrip/features/expenses/presentation/screens/add_edit_expense_screen.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

void main() {
  group('ReceiptParser line-item extraction & SplitCalculator.calculateItemizedSplit', () {
    test('extracts line items + tax lines and splits dish-by-dish with proportional GST', () {
      const sampleText = '''
THE FISHERMAN'S WHARF
Date: 15/10/2026
King Fish Rava Fry          1     450.00
Goan Prawn Curry            1     580.00
Steamed Rice                2     240.00
Fresh Lime Soda             2     180.00
Subtotal:                        1450.00
CGST 2.5%                          36.25
SGST 2.5%                          36.25
Service Charge 5%                  72.50
GRAND TOTAL:                 ₹ 1,595.00
''';

      final parsed = ReceiptParser.parse(sampleText);
      final dishItems = parsed.lineItems.where((i) => !i.isTaxOrFee).toList();
      final feeItems = parsed.lineItems.where((i) => i.isTaxOrFee).toList();

      expect(parsed.amountPaise, equals(159500));
      expect(dishItems.length, equals(4));
      expect(feeItems.length, equals(3));

      // Person A orders King Fish Rava Fry + shares Rice + Soda
      // Person B orders Goan Prawn Curry + shares Rice + Soda
      final splits = SplitCalculator.calculateItemizedSplit(
        totalPaise: parsed.amountPaise!,
        items: parsed.lineItems,
        itemAssignees: {
          dishItems[0].id: {'t-1'}, // 450
          dishItems[1].id: {'t-2'}, // 580
          dishItems[2].id: {'t-1', 't-2'}, // 120 each
          dishItems[3].id: {'t-1', 't-2'}, // 90 each
        },
        allTravelerIds: const ['t-1', 't-2'],
      );

      // Exact minor-unit sum invariant
      expect(splits.values.fold<int>(0, (s, v) => s + v), equals(159500));
      // Person B ordered costlier curry so owes strictly more than Person A
      expect(splits['t-2']!, greaterThan(splits['t-1']!));
    });

    test('scales shares down cleanly when coupon discounts below item subtotal', () {
      const items = [
        ReceiptLineItem(id: 'i1', name: 'Pizza', amountPaise: 60000),
        ReceiptLineItem(id: 'i2', name: 'Pasta', amountPaise: 40000),
      ];
      final splits = SplitCalculator.calculateItemizedSplit(
        totalPaise: 80000, // ₹200 discount applied
        items: items,
        itemAssignees: {
          'i1': {'a'},
          'i2': {'b'},
        },
        allTravelerIds: const ['a', 'b'],
      );

      expect(splits['a'], equals(48000));
      expect(splits['b'], equals(32000));
      expect(splits.values.fold<int>(0, (s, v) => s + v), equals(80000));
    });

    testWidgets('AddEditExpenseScreen Items mode adds line item and previews split',
        (tester) async {
      final trip = TripWithDetails(
        id: 'trip-1',
        name: 'Goa Dinner',
        totalBudgetPaise: 2000000,
        days: 3,
        createdAt: DateTime(2026, 12, 1),
        travelers: const [
          Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
          Traveler(id: 't-2', tripId: 'trip-1', name: 'Diya'),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripDetailsProvider('trip-1').overrideWith((_) => Stream.value(trip)),
            tripExpensesProvider('trip-1')
                .overrideWith((_) => Stream.value(const <ExpenseWithSplits>[])),
          ],
          child: const MaterialApp(
            home: AddEditExpenseScreen(tripId: 'trip-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final itemsSegment = find.text('Items');
      await tester.scrollUntilVisible(
        itemsSegment,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(itemsSegment);
      await tester.pumpAndSettle();

      final addItemBtn = find.byKey(const Key('add_line_item_btn'));
      await tester.scrollUntilVisible(
        addItemBtn,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(addItemBtn);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('line_item_name_field')),
        'Beach Thali',
      );
      await tester.enterText(
        find.byKey(const Key('line_item_price_field')),
        '500',
      );
      await tester.tap(find.byKey(const Key('confirm_add_line_item_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Beach Thali'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('itemized_preview_totals')),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('itemized_preview_totals')), findsOneWidget);
    });
  });
}
