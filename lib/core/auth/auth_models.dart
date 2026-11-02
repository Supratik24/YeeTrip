import 'package:flutter/foundation.dart';

/// User profile representing an authenticated cloud account or linked traveler.
@immutable
class UserProfile {
  final String uid;
  final String displayName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? defaultUpiVpa;
  final String preferredLanguage;
  final DateTime createdAt;

  const UserProfile({
    required this.uid,
    required this.displayName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.defaultUpiVpa,
    this.preferredLanguage = 'en',
    required this.createdAt,
  });

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? defaultUpiVpa,
    String? preferredLanguage,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      defaultUpiVpa: defaultUpiVpa ?? this.defaultUpiVpa,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'phoneNumber': phoneNumber,
        'avatarUrl': avatarUrl,
        'defaultUpiVpa': defaultUpiVpa,
        'preferredLanguage': preferredLanguage,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      defaultUpiVpa: json['defaultUpiVpa'] as String?,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Authentication state representing either a Guest or Authenticated session.
@immutable
class AuthState {
  final bool isAuthenticated;
  final UserProfile? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isGuest => !isAuthenticated;

  factory AuthState.guest() => const AuthState(isAuthenticated: false);

  factory AuthState.authenticated(UserProfile user) => AuthState(
        isAuthenticated: true,
        user: user,
      );

  factory AuthState.loading() => const AuthState(isLoading: true);

  factory AuthState.error(String message) => AuthState(
        isAuthenticated: false,
        errorMessage: message,
      );

  AuthState copyWith({
    bool? isAuthenticated,
    UserProfile? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
