// lib/features/auth/domain/user_role.dart
// Role enumeration matching database roles table

enum UserRole {
  officer,
  welfareOfficer,
  counsellor,
  commander,
  family,
  admin,
  unknown;

  static UserRole fromString(String? roleStr) {
    if (roleStr == null) return UserRole.unknown;
    switch (roleStr.toLowerCase()) {
      case 'officer':
        return UserRole.officer;
      case 'welfare_officer':
        return UserRole.welfareOfficer;
      case 'counsellor':
        return UserRole.counsellor;
      case 'commander':
        return UserRole.commander;
      case 'family':
        return UserRole.family;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.unknown;
    }
  }

  String toDbString() {
    switch (this) {
      case UserRole.officer:
        return 'officer';
      case UserRole.welfareOfficer:
        return 'welfare_officer';
      case UserRole.counsellor:
        return 'counsellor';
      case UserRole.commander:
        return 'commander';
      case UserRole.family:
        return 'family';
      case UserRole.admin:
        return 'admin';
      case UserRole.unknown:
        return 'officer';
    }
  }
}
