// lib/features/crisis/domain/safety_plan.dart
// Stanley-Brown validated safety plan domain model for suicide risk mitigation

class SafetyPlan {
  final String id;
  final String officerId;
  final List<String> warningSigns;
  final List<String> internalCopingStrategies;
  final List<String> socialDistractions;
  final List<Map<String, String>> trustedContacts;
  final List<Map<String, String>> professionalContacts;
  final List<String> environmentalSafetySteps;
  final DateTime updatedAt;

  const SafetyPlan({
    required this.id,
    required this.officerId,
    required this.warningSigns,
    required this.internalCopingStrategies,
    required this.socialDistractions,
    required this.trustedContacts,
    required this.professionalContacts,
    required this.environmentalSafetySteps,
    required this.updatedAt,
  });

  /// Factory creating standard default template for rapid officer customization
  factory SafetyPlan.defaultTemplate(String officerId) {
    return SafetyPlan(
      id: 'sp-$officerId',
      officerId: officerId,
      warningSigns: const [
        'Prolonged insomnia and racing thoughts at night',
        'Feeling disconnected from squad and family',
        'Intense sense of burden or hopelessness',
      ],
      internalCopingStrategies: const [
        'Tactical box breathing (4-4-4-4 rhythm)',
        'Listening to recorded audio message from family',
        'Going for a 20-minute physical walk around unit lines',
      ],
      socialDistractions: const [
        'Visiting the unit recreation room / tea canteen',
        'Playing volleyball or sports with fellow officers',
      ],
      trustedContacts: const [
        {'name': 'Subedar Major (Buddy Pair)', 'role': 'Senior Peer', 'phone': '9876543210'},
        {'name': 'Spouse / Family Contact', 'role': 'Primary Family', 'phone': '9876543211'},
      ],
      professionalContacts: const [
        {'name': 'Tele-MANAS Emergency Mental Health', 'role': 'National 24x7 Helpline', 'phone': '14416'},
        {'name': 'Regimental Medical Officer', 'role': 'Unit Doctor', 'phone': '1800-891-4416'},
        {'name': 'Force Welfare Counsellor Desk', 'role': 'Clinical Specialist', 'phone': '011-2309-1234'},
      ],
      environmentalSafetySteps: const [
        'Ensure sidearm/service weapon is securely vaulted in the unit armory (kote)',
        'Share current physical location with assigned buddy pair or welfare officer',
      ],
      updatedAt: DateTime.now(),
    );
  }

  factory SafetyPlan.fromMap(Map<String, dynamic> map) {
    return SafetyPlan(
      id: map['id'] as String,
      officerId: map['officer_id'] as String,
      warningSigns: (map['warning_signs'] as List? ?? []).map((e) => e.toString()).toList(),
      internalCopingStrategies: (map['internal_coping_strategies'] as List? ?? []).map((e) => e.toString()).toList(),
      socialDistractions: (map['social_distractions'] as List? ?? []).map((e) => e.toString()).toList(),
      trustedContacts: (map['trusted_contacts'] as List? ?? [])
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      professionalContacts: (map['professional_contacts'] as List? ?? [])
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      environmentalSafetySteps: (map['environmental_safety_steps'] as List? ?? []).map((e) => e.toString()).toList(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'officer_id': officerId,
      'warning_signs': warningSigns,
      'internal_coping_strategies': internalCopingStrategies,
      'social_distractions': socialDistractions,
      'trusted_contacts': trustedContacts,
      'professional_contacts': professionalContacts,
      'environmental_safety_steps': environmentalSafetySteps,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
