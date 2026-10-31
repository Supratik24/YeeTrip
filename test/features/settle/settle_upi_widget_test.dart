import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/data/repositories/expense_repository.dart';
import 'package:yeetrip/data/repositories/trip_repository.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/settle/presentation/screens/settle_screen.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

class MockTripRepository extends Mock implements TripRepository {}
class MockExpenseRepository extends Mock implements ExpenseRepository {}

void main() {
  late MockTripRepository mockTripRepo;
  late MockExpenseRepository mockExpenseRepo;

  final trip = TripWithDetails(
    id: 'trip-1',
    name: 'Goa Trip 🌊',
    totalBudgetPaise: 5000000,
    days: 3,
    currency: 'INR',
    createdAt: DateTime.now(),
    travelers: const [
      Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
      Traveler(id: 't-2', tripId: 'trip-1', name: 'Diya', upiVpa: 'diya@okhdfcbank'),
    ],
    categoryAllocations: const {},
    totalSpentPaise: 400000,
  );

  // Diya paid ₹4000 for both (₹2000 each) => Aarav owes Diya ₹2000
  final expenses = [
    ExpenseWithSplits(
      id: 'e-1',
      tripId: 'trip-1',
      description: 'Dinner',
      amountPaise: 400000,
      category: 'Food',
      paidBy: 't-2',
      source: 'manual',
      confirmed: true,
      createdAt: DateTime.now(),
      splits: const [
        ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-1', sharePaise: 200000),
        ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-2', sharePaise: 200000),
      ],
    ),
  ];

  setUp(() {
    mockTripRepo = MockTripRepository();
    mockExpenseRepo = MockExpenseRepository();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'canLaunch') {
          return false;
        }
        return false;
      },
    );
  });

  group('SettleScreen UPI Payment Tests', () {
    testWidgets('renders UPI payment button when settlement exists and opens UPI fallback dialog',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripRepositoryProvider.overrideWithValue(mockTripRepo),
            expenseRepositoryProvider.overrideWithValue(mockExpenseRepo),
            tripExpensesProvider('trip-1')
                .overrideWith((ref) => Stream.value(expenses)),
          ],
          child: MaterialApp(
            home: SettleScreen(trip: trip),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aarav pays Diya'), findsOneWidget);
      expect(find.text('₹2,000'), findsOneWidget);

      final upiBtn = find.byKey(const Key('pay_upi_t-1_t-2'));
      expect(upiBtn, findsOneWidget);

      // Tap UPI pay button (in test environment, no external UPI app exists so fallback dialog shows)
      await tester.tap(upiBtn);
      await tester.pumpAndSettle();

      expect(find.text('UPI Payment'), findsOneWidget);
      expect(find.text('Copy UPI ID'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    testWidgets('prompts to add UPI ID if payee does not have one set',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final tripWithoutVpa = TripWithDetails(
        id: 'trip-1',
        name: 'Goa Trip 🌊',
        totalBudgetPaise: 5000000,
        days: 3,
        currency: 'INR',
        createdAt: DateTime.now(),
        travelers: const [
          Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
          Traveler(id: 't-2', tripId: 'trip-1', name: 'Diya'), // No VPA
        ],
        categoryAllocations: const {},
        totalSpentPaise: 400000,
      );

      when(() => mockTripRepo.updateTraveler(
            travelerId: 't-2',
            name: 'Diya',
            upiVpa: 'diya@axisbank',
          )).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripRepositoryProvider.overrideWithValue(mockTripRepo),
            expenseRepositoryProvider.overrideWithValue(mockExpenseRepo),
            tripExpensesProvider('trip-1')
                .overrideWith((ref) => Stream.value(expenses)),
          ],
          child: MaterialApp(
            home: SettleScreen(trip: tripWithoutVpa),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final upiBtn = find.byKey(const Key('pay_upi_t-1_t-2'));
      expect(upiBtn, findsOneWidget);

      await tester.tap(upiBtn);
      await tester.pumpAndSettle();

      // Dialog prompting for UPI ID
      expect(find.text('Add UPI ID for Diya'), findsOneWidget);
      expect(find.byKey(const Key('add_vpa_field')), findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('add_vpa_field')), 'diya@axisbank');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_vpa_and_pay_btn')));
      await tester.pumpAndSettle();

      verify(() => mockTripRepo.updateTraveler(
            travelerId: 't-2',
            name: 'Diya',
            upiVpa: 'diya@axisbank',
          )).called(1);
    });
  });
}
