// lib/features/family/domain/family_member.dart
// Enrolled family member profile linked to an officer

class FamilyMember {
  final String id;
  final String officerId;
  final String relation; // 'spouse', 'parent', 'child', 'sibling'
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final bool isEmergencyContact;
  final bool isVerified;
  final DateTime createdAt;

  const FamilyMember({
    required this.id,
    required this.officerId,
    required this.relation,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.isEmergencyContact = false,
    this.isVerified = true,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get relationDisplay {
    switch (relation.toLowerCase()) {
      case 'spouse':
        return 'Spouse';
      case 'parent':
        return 'Parent';
      case 'child':
        return 'Son/Daughter';
      case 'sibling':
        return 'Sibling';
      default:
        return relation;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'officer_id': officerId,
        'relation': relation,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
        'is_emergency_contact': isEmergencyContact,
        'is_verified': isVerified,
        'created_at': createdAt.toIso8601String(),
      };

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      officerId: json['officer_id'] as String,
      relation: json['relation'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String? ?? '',
      phone: json['phone'] as String,
      email: json['email'] as String?,
      isEmergencyContact: json['is_emergency_contact'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
