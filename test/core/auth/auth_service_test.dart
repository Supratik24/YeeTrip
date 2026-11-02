import 'package:flutter_test/flutter_test.dart';
import 'package:yeetrip/core/auth/auth_service.dart';
import 'package:yeetrip/core/auth/auth_storage.dart';

void main() {
  late InMemoryAuthStorage storage;
  late AuthService service;

  setUp(() {
    storage = InMemoryAuthStorage();
    service = AuthService(storage: storage);
  });

  tearDown(() {
    service.dispose();
  });

  group('AuthService Tests', () {
    test('Initial state is Guest mode', () {
      expect(service.currentState.isGuest, isTrue);
      expect(service.currentState.isAuthenticated, isFalse);
      expect(service.currentState.user, isNull);
    });

    test('Sign in with Google creates profile and sets authenticated state', () async {
      final user = await service.signInWithGoogle(
        customName: 'Aarav Sharma',
        customEmail: 'aarav@gmail.com',
      );

      expect(service.currentState.isAuthenticated, isTrue);
      expect(service.currentState.isGuest, isFalse);
      expect(user.displayName, equals('Aarav Sharma'));
      expect(user.email, equals('aarav@gmail.com'));
      expect(user.defaultUpiVpa, equals('aarav@oksbi'));

      // Check stored in storage
      final stored = await storage.loadStoredProfile();
      expect(stored?.displayName, equals('Aarav Sharma'));
    });

    test('Sign in with Email and Password validates format and creates user', () async {
      // Rejects invalid email
      expect(
        () => service.signInWithEmailPassword(email: 'invalid', password: 'password123'),
        throwsA(isA<FormatException>()),
      );

      // Rejects short password (< 6 chars)
      expect(
        () => service.signInWithEmailPassword(email: 'test@example.com', password: '123'),
        throwsA(isA<FormatException>()),
      );

      final user = await service.signInWithEmailPassword(
        email: 'diya.patel@gmail.com',
        password: 'securePass123',
        displayName: 'Diya Patel',
      );

      expect(user.displayName, equals('Diya Patel'));
      expect(user.email, equals('diya.patel@gmail.com'));
      expect(service.currentState.isAuthenticated, isTrue);
    });

    test('Sign in with Phone Number validates Indian mobile length and OTP', () async {
      // Rejects short phone number
      expect(
        () => service.signInWithPhone(phoneNumber: '98765', otp: '123456'),
        throwsA(isA<FormatException>()),
      );

      // Rejects invalid OTP length
      expect(
        () => service.signInWithPhone(phoneNumber: '9876543210', otp: '12'),
        throwsA(isA<FormatException>()),
      );

      final user = await service.signInWithPhone(
        phoneNumber: '9876543210',
        otp: '123456',
        displayName: 'Kabir Verma',
      );

      expect(user.displayName, equals('Kabir Verma'));
      expect(user.phoneNumber, equals('+919876543210'));
      expect(service.currentState.isAuthenticated, isTrue);
    });

    test('Update profile modifies display name, UPI VPA, and language', () async {
      await service.signInWithGoogle();

      final updated = await service.updateProfile(
        displayName: 'Aarav S.',
        defaultUpiVpa: 'aarav@okaxis',
        preferredLanguage: 'hi',
      );

      expect(updated.displayName, equals('Aarav S.'));
      expect(updated.defaultUpiVpa, equals('aarav@okaxis'));
      expect(updated.preferredLanguage, equals('hi'));
      expect(service.currentState.user?.displayName, equals('Aarav S.'));
    });

    test('Sign out resets state to Guest and clears storage', () async {
      await service.signInWithGoogle();
      expect(service.currentState.isAuthenticated, isTrue);

      await service.signOut();
      expect(service.currentState.isGuest, isTrue);
      expect(service.currentState.user, isNull);

      final stored = await storage.loadStoredProfile();
      expect(stored, isNull);
    });

    test('Restore session recovers stored profile on app relaunch', () async {
      await service.signInWithGoogle(customName: 'Rohan Mehra');

      // Create a fresh service instance with the same storage
      final newService = AuthService(storage: storage);
      expect(newService.currentState.isGuest, isTrue);

      final restoredState = await newService.restoreSession();
      expect(restoredState.isAuthenticated, isTrue);
      expect(restoredState.user?.displayName, equals('Rohan Mehra'));
      newService.dispose();
    });
  });
}
