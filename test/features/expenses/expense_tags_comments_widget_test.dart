import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/data/repositories/expense_comment_repository.dart';
import 'package:yeetrip/features/expenses/domain/expense_comment_model.dart';
import 'package:yeetrip/features/expenses/domain/expense_model.dart';
import 'package:yeetrip/features/expenses/presentation/screens/add_edit_expense_screen.dart';
import 'package:yeetrip/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:yeetrip/features/expenses/presentation/widgets/expense_comments_sheet.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

class _MockCommentRepo extends Mock implements ExpenseCommentRepository {}

void main() {
  final tripUsd = TripWithDetails(
    id: 'trip-usd',
    name: 'New York Trip',
    totalBudgetPaise: 300000, // $3,000
    days: 4,
    currency: 'USD',
    createdAt: DateTime(2026, 12, 1),
    travelers: const [
      Traveler(id: 't-1', tripId: 'trip-usd', name: 'Aarav'),
      Traveler(id: 't-2', tripId: 'trip-usd', name: 'Diya'),
    ],
  );

  final sampleExpense = ExpenseWithSplits(
    id: 'e-1',
    tripId: 'trip-usd',
    description: 'Brooklyn Pizza',
    amountPaise: 4500, // $45
    category: 'Food',
    paidBy: 't-1',
    createdAt: DateTime(2026, 12, 2),
    notes: 'Shared large pie + drinks',
    tags: const ['lunch', 'shared'],
    originalCurrency: 'EUR',
    originalAmountPaise: 4180,
    exchangeRate: 1.076,
    commentCount: 2,
    openDisputeCount: 1,
    splits: const [
      ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-1', sharePaise: 2250),
      ExpenseSplitModel(expenseId: 'e-1', travelerId: 't-2', sharePaise: 2250),
    ],
  );

  testWidgets('ExpenseListScreen shows USD amounts, tags, notes, and dispute badge',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripExpensesProvider('trip-usd')
              .overrideWith((ref) => Stream.value([sampleExpense])),
        ],
        child: MaterialApp(
          home: ExpenseListScreen(trip: tripUsd),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('\$45'), findsOneWidget);
    expect(find.text('€41.80'), findsOneWidget);
    expect(find.text('#lunch'), findsOneWidget);
    expect(find.text('#shared'), findsOneWidget);
    expect(find.text('Shared large pie + drinks'), findsOneWidget);
    expect(find.text('1 dispute'), findsOneWidget);
  });

  testWidgets('AddEditExpenseScreen shows tag chips, notes, and foreign currency converter',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripDetailsProvider('trip-usd')
              .overrideWith((ref) => Stream.value(tripUsd)),
        ],
        child: const MaterialApp(
          home: AddEditExpenseScreen(tripId: 'trip-usd'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Amount (\$)'), findsOneWidget);
    expect(find.byKey(const Key('toggle_foreign_currency_chip')), findsOneWidget);

    // Toggle foreign currency box
    await tester.tap(find.byKey(const Key('toggle_foreign_currency_chip')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('foreign_currency_box')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('tag_chip_lunch')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('tag_chip_lunch')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('expense_notes_field')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('expense_notes_field')), findsOneWidget);
  });

  testWidgets('ExpenseCommentsSheet displays comments, posts dispute, and resolves dispute',
      (tester) async {
    final mockRepo = _MockCommentRepo();
    final existingComments = [
      ExpenseCommentModel(
        id: 'c-1',
        expenseId: 'e-1',
        tripId: 'trip-usd',
        authorTravelerId: 't-2',
        authorName: 'Diya',
        body: 'Did this include tip?',
        isDispute: true,
        isResolved: false,
        createdAt: DateTime(2026, 12, 2, 14, 0),
      ),
    ];

    when(
      () => mockRepo.addComment(
        expenseId: any(named: 'expenseId'),
        tripId: any(named: 'tripId'),
        authorTravelerId: any(named: 'authorTravelerId'),
        authorName: any(named: 'authorName'),
        body: any(named: 'body'),
        isDispute: any(named: 'isDispute'),
      ),
    ).thenAnswer((_) async => 'c-new');
    when(() => mockRepo.setDisputeResolved(any(), any()))
        .thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expenseCommentsProvider('e-1')
              .overrideWith((ref) => Stream.value(existingComments)),
          expenseCommentRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ExpenseCommentsSheet(
              trip: tripUsd,
              expense: sampleExpense,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Did this include tip?'), findsOneWidget);
    expect(find.text('Dispute'), findsWidgets);

    // Resolve dispute
    await tester.tap(find.text('Mark resolved'));
    await tester.pumpAndSettle();
    verify(() => mockRepo.setDisputeResolved('c-1', true)).called(1);

    // Post new comment
    await tester.enterText(
      find.byKey(const Key('comment_body_field')),
      'Yes, 15% tip included',
    );
    await tester.tap(find.byKey(const Key('send_comment_btn')));
    await tester.pumpAndSettle();

    verify(
      () => mockRepo.addComment(
        expenseId: 'e-1',
        tripId: 'trip-usd',
        authorTravelerId: 't-1',
        authorName: 'Aarav',
        body: 'Yes, 15% tip included',
        isDispute: false,
      ),
    ).called(1);
  });
}
