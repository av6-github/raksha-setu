// lib/features/auth/domain/app_user.dart
// Domain model for authenticated user and identity metadata

import 'user_role.dart';

class AppUser {
  final String id;
  final String? email;
  final String? phone;
  final UserRole role;
  final String? officerId;
  final String? serviceNumber;
  final String? firstName;
  final String? lastName;
  final String? familyMemberId;

  const AppUser({
    required this.id,
    this.email,
    this.phone,
    required this.role,
    this.officerId,
    this.serviceNumber,
    this.firstName,
    this.lastName,
    this.familyMemberId,
  });

  String get displayName {
    if (firstName != null && firstName!.isNotEmpty) {
      return '$firstName ${lastName ?? ''}'.trim();
    }
    return email ?? serviceNumber ?? 'Officer';
  }
}
