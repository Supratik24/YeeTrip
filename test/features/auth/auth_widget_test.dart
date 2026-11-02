import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/auth/auth_models.dart';
import 'package:yeetrip/core/auth/auth_providers.dart';
import 'package:yeetrip/core/auth/auth_service.dart';
import 'package:yeetrip/core/auth/auth_storage.dart';
import 'package:yeetrip/core/auth/profile_migration_service.dart';
import 'package:yeetrip/data/local/app_database.dart' hide Traveler;
import 'package:yeetrip/data/providers.dart';
import 'package:yeetrip/features/auth/presentation/widgets/auth_modal.dart';
import 'package:yeetrip/features/auth/presentation/widgets/edit_profile_dialog.dart';
import 'package:yeetrip/features/settings/presentation/screens/settings_screen.dart';
import 'package:yeetrip/features/trips/domain/trip_model.dart';

class _FakeMigrationService extends ProfileMigrationService {
  _FakeMigrationService(super.db);

  @override
  Future<ProfileMigrationReport> linkProfileToLocalTrips(UserProfile user) async {
    return const ProfileMigrationReport(
      tripsInspected: 1,
      travelersLinked: 1,
      upisUpdated: 1,
    );
  }
}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  final trip = TripWithDetails(
    id: 'trip-1',
    name: 'Goa Weekend 🌴',
    totalBudgetPaise: 5000000,
    days: 4,
    currency: 'INR',
    createdAt: DateTime.now(),
    travelers: const [
      Traveler(id: 't-1', tripId: 'trip-1', name: 'Aarav'),
    ],
    categoryAllocations: const {
      'Stay': 30,
      'Food': 25,
      'Transport': 20,
      'Activities': 15,
      'Shopping': 5,
      'Buffer': 5,
    },
    totalSpentPaise: 100000,
  );

  group('AuthModal UI Tests', () {
    testWidgets('Allows signing in with Google and triggers local migration', (tester) async {
      final storage = InMemoryAuthStorage();
      final authService = AuthService(storage: storage);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(authService),
            profileMigrationServiceProvider.overrideWithValue(
              _FakeMigrationService(AppDatabase()),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AuthModal(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account & Cloud Profile'), findsOneWidget);
      expect(find.byKey(const Key('google_sign_in_btn')), findsOneWidget);

      // Tap Google Sign In
      await tester.tap(find.byKey(const Key('google_sign_in_btn')));
      await tester.pumpAndSettle();

      // Auth modal should dismiss and user should be authenticated
      expect(authService.currentState.isAuthenticated, isTrue);
      expect(authService.currentState.user?.displayName, equals('Aarav Sharma'));
    });

    testWidgets('Email tab switches and signs in with email/password', (tester) async {
      final storage = InMemoryAuthStorage();
      final authService = AuthService(storage: storage);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(authService),
            profileMigrationServiceProvider.overrideWithValue(
              _FakeMigrationService(AppDatabase()),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AuthModal(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Email tab
      await tester.tap(find.text('Email'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('auth_email_field')), findsOneWidget);
      expect(find.byKey(const Key('auth_password_field')), findsOneWidget);

      // Fill in form
      await tester.enterText(find.byKey(const Key('auth_display_name_field')), 'Diya Patel');
      await tester.enterText(find.byKey(const Key('auth_email_field')), 'diya@example.com');
      await tester.enterText(find.byKey(const Key('auth_password_field')), 'password123');

      // Tap submit
      await tester.tap(find.byKey(const Key('email_sign_in_btn')));
      await tester.pumpAndSettle();

      expect(authService.currentState.isAuthenticated, isTrue);
      expect(authService.currentState.user?.displayName, equals('Diya Patel'));
    });
  });

  group('EditProfileDialog UI Tests', () {
    testWidgets('Pre-populates fields and saves updated display name and UPI ID', (tester) async {
      final storage = InMemoryAuthStorage();
      final authService = AuthService(storage: storage);
      final initialUser = await authService.signInWithGoogle();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(authService),
            profileMigrationServiceProvider.overrideWithValue(
              _FakeMigrationService(AppDatabase()),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: EditProfileDialog(user: initialUser),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.byKey(const Key('profile_name_input')), findsOneWidget);
      expect(find.byKey(const Key('profile_upi_input')), findsOneWidget);

      // Update name and UPI
      await tester.enterText(find.byKey(const Key('profile_name_input')), 'Aarav S.');
      await tester.enterText(find.byKey(const Key('profile_upi_input')), 'aarav@okaxis');

      await tester.tap(find.byKey(const Key('save_profile_btn')));
      await tester.pumpAndSettle();

      expect(authService.currentState.user?.displayName, equals('Aarav S.'));
      expect(authService.currentState.user?.defaultUpiVpa, equals('aarav@okaxis'));
    });
  });

  group('SettingsScreen Account Card Integration Tests', () {
    testWidgets('Renders Guest User state initially and opens AuthModal on tap', (tester) async {
      final storage = InMemoryAuthStorage();
      final authService = AuthService(storage: storage);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(authService),
            tripExpensesProvider(trip.id).overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            home: SettingsScreen(trip: trip),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('account_profile_card')), findsOneWidget);
      expect(find.text('Guest User'), findsOneWidget);
      expect(find.text('Local offline mode'), findsOneWidget);

      final openAuthBtn = find.byKey(const Key('open_auth_modal_btn'));
      expect(openAuthBtn, findsOneWidget);

      await tester.tap(openAuthBtn);
      await tester.pumpAndSettle();

      expect(find.byType(AuthModal), findsOneWidget);
    });

    testWidgets('Renders authenticated user profile, allows editing, and signs out', (tester) async {
      final storage = InMemoryAuthStorage();
      final authService = AuthService(storage: storage);
      await authService.signInWithGoogle(
        customName: 'Aarav Sharma',
        customEmail: 'aarav@example.com',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(authService),
            tripExpensesProvider(trip.id).overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            home: SettingsScreen(trip: trip),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aarav Sharma'), findsWidgets);
      expect(find.text('aarav@example.com'), findsOneWidget);
      expect(find.text('UPI: aarav@oksbi'), findsOneWidget);
      expect(find.byKey(const Key('edit_profile_btn')), findsOneWidget);
      expect(find.byKey(const Key('sign_out_btn')), findsOneWidget);

      // Tap Sign Out
      await tester.tap(find.byKey(const Key('sign_out_btn')));
      await tester.pumpAndSettle();

      // Should return to Guest User mode
      expect(find.text('Guest User'), findsOneWidget);
      expect(find.text('Sign In / Create Account'), findsOneWidget);
    });
  });
}
