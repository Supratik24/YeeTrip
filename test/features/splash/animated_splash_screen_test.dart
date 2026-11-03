import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/features/splash/presentation/animated_splash_screen.dart';

void main() {
  group('AnimatedSplashScreen Widget Tests', () {
    testWidgets('renders logo mark, wordmark image, tagline and badges', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedSplashScreen(
            autoNavigateDelay: Duration(seconds: 10),
          ),
        ),
      );

      // Initially starts animation
      expect(find.byKey(const Key('splash_logo_mark')), findsOneWidget);
      expect(find.byKey(const Key('splash_wordmark_image')), findsOneWidget);
      expect(find.text('Smart Group Travel & Expense Splitting'), findsOneWidget);
      expect(find.text('100% Offline'), findsOneWidget);
      expect(find.text('Zero Float Errors'), findsOneWidget);
      expect(find.text('Min Settlements'), findsOneWidget);
      expect(find.byKey(const Key('skip_splash_btn')), findsOneWidget);

      // Advance animation through completion
      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.text('Smart Group Travel & Expense Splitting'), findsOneWidget);
    });

    testWidgets('triggers onComplete when skip button is tapped', (tester) async {
      var completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedSplashScreen(
            autoNavigateDelay: const Duration(seconds: 10),
            onComplete: () {
              completed = true;
            },
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(completed, isFalse);

      await tester.tap(find.byKey(const Key('skip_splash_btn')));
      await tester.pump();

      expect(completed, isTrue);
    });

    testWidgets('triggers onComplete when screen is tapped anywhere', (tester) async {
      var completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedSplashScreen(
            autoNavigateDelay: const Duration(seconds: 10),
            onComplete: () {
              completed = true;
            },
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(completed, isFalse);

      await tester.tap(find.byKey(const Key('splash_gesture_detector')));
      await tester.pump();

      expect(completed, isTrue);
    });

    testWidgets('auto-completes when autoNavigateDelay elapses', (tester) async {
      var completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedSplashScreen(
            autoNavigateDelay: const Duration(milliseconds: 1500),
            onComplete: () {
              completed = true;
            },
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(completed, isFalse);

      await tester.pump(const Duration(milliseconds: 1100));
      expect(completed, isTrue);
    });

    testWidgets('renders cleanly in dark mode without overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const AnimatedSplashScreen(
            autoNavigateDelay: Duration(seconds: 10),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 800));
      expect(find.byKey(const Key('splash_logo_mark')), findsOneWidget);
      expect(find.byKey(const Key('splash_wordmark_image')), findsOneWidget);
    });
  });
}
