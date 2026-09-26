// lib/features/profile/domain/officer_profile.dart
// Domain model for Officer identity, service info, and duty availability

class OfficerProfile {
  final String id;
  final String identityId;
  final String? unitId;
  final String? unitName;
  final String serviceNumber;
  final String firstName;
  final String? lastName;
  final String? designation;
  final DateTime dateOfJoining;
  final String? bloodGroup;
  final String? gender;
  final bool isAvailable;
  final bool limitedDuty;
  final bool welfareSupported;

  const OfficerProfile({
    required this.id,
    required this.identityId,
    this.unitId,
    this.unitName,
    required this.serviceNumber,
    required this.firstName,
    this.lastName,
    this.designation,
    required this.dateOfJoining,
    this.bloodGroup,
    this.gender,
    this.isAvailable = true,
    this.limitedDuty = false,
    this.welfareSupported = false,
  });

  String get fullName => '$firstName ${lastName ?? ''}'.trim();

  String get dutyStatusDisplay {
    if (!isAvailable) return 'Medically Unavailable';
    if (limitedDuty) return 'Limited Duty';
    if (welfareSupported) return 'Welfare Supported';
    return 'Full Active Duty';
  }

  factory OfficerProfile.fromMap(Map<String, dynamic> map) {
    return OfficerProfile(
      id: map['id'] as String,
      identityId: map['identity_id'] as String,
      unitId: map['unit_id'] as String?,
      unitName: map['units'] != null ? map['units']['name'] as String? : null,
      serviceNumber: map['service_number'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String?,
      designation: map['designation'] as String?,
      dateOfJoining: DateTime.tryParse(map['date_of_joining'] as String? ?? '') ?? DateTime.now(),
      bloodGroup: map['blood_group'] as String?,
      gender: map['gender'] as String?,
      isAvailable: map['is_available'] as bool? ?? true,
      limitedDuty: map['limited_duty'] as bool? ?? false,
      welfareSupported: map['welfare_supported'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'identity_id': identityId,
      'unit_id': unitId,
      'service_number': serviceNumber,
      'first_name': firstName,
      'last_name': lastName,
      'designation': designation,
      'date_of_joining': dateOfJoining.toIso8601String().split('T').first,
      'blood_group': bloodGroup,
      'gender': gender,
      'is_available': isAvailable,
      'limited_duty': limitedDuty,
      'welfare_supported': welfareSupported,
    };
  }
}
