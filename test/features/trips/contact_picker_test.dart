import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/features/trips/presentation/widgets/contact_picker_sheet.dart';

void main() {
  group('Contact Permission Notification Dialog Tests', () {
    testWidgets('renders disclosure notification and handles Cancel', (tester) async {
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    dialogResult = await showContactPermissionNotification(ctx);
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap button to trigger notification dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify notification dialog content
      expect(find.text('Add from Contacts'), findsOneWidget);
      expect(find.textContaining('YeeTrip needs access to your contacts'), findsOneWidget);
      expect(find.textContaining('100% Offline & Private'), findsOneWidget);
      expect(find.text('Not Now'), findsOneWidget);
      expect(find.text('Allow & Continue'), findsOneWidget);

      // Tap 'Not Now'
      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();

      expect(dialogResult, isFalse);
    });

    testWidgets('handles Allow & Continue tap', (tester) async {
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    dialogResult = await showContactPermissionNotification(ctx);
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap 'Allow & Continue'
      await tester.tap(find.text('Allow & Continue'));
      await tester.pumpAndSettle();

      expect(dialogResult, isTrue);
    });
  });

  group('ContactPickerSheet UI Tests', () {
    testWidgets('displays contacts, filters by search, and allows selection', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sampleContacts = [
        Contact(
          displayName: 'Aarav Sharma',
          phones: const [Phone(number: '9876543210')],
        ),
        Contact(
          displayName: 'Diya Patel',
          phones: const [Phone(number: '9123456780')],
        ),
        Contact(
          displayName: 'Kabir Mehta',
          phones: const [Phone(number: '9988776655')],
        ),
      ];

      List<ContactPickerResult>? picked;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  picked = await showModalBottomSheet<List<ContactPickerResult>>(
                    context: ctx,
                    builder: (_) => ContactPickerSheet(
                      contacts: sampleContacts,
                      existingNames: const ['Diya Patel'],
                    ),
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Select Contacts'), findsOneWidget);
      expect(find.text('Aarav Sharma'), findsOneWidget);
      expect(find.text('Diya Patel'), findsOneWidget);
      expect(find.text('In trip'), findsOneWidget); // Diya is in existingNames
      expect(find.text('Kabir Mehta'), findsOneWidget);

      // Search for "Aarav"
      await tester.enterText(find.byType(TextField), 'Aarav');
      await tester.pumpAndSettle();

      expect(find.text('Aarav Sharma'), findsOneWidget);
      expect(find.text('Kabir Mehta'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('Kabir Mehta'), findsOneWidget);

      // Select Aarav Sharma
      await tester.tap(find.text('Aarav Sharma'));
      await tester.pumpAndSettle();

      expect(find.text('1 selected'), findsOneWidget);
      expect(find.text('Add (1) to trip'), findsOneWidget);

      // Tap "Add (1) to trip"
      await tester.tap(find.text('Add (1) to trip'));
      await tester.pumpAndSettle();

      expect(picked, isNotNull);
      expect(picked!.length, equals(1));
      expect(picked!.first.name, equals('Aarav Sharma'));
      expect(picked!.first.phoneNumber, equals('9876543210'));
    });
  });
}
