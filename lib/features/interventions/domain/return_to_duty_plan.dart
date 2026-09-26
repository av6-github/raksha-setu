// lib/features/interventions/domain/return_to_duty_plan.dart
// Gradual reintegration plan with strict minimum-necessary commander disclosure

import '../../../core/errors/app_exceptions.dart';

class ReturnToDutyPlan {
  final String id;
  final String officerId;
  final String clinicianName;
  final DateTime offDutyStart;
  final DateTime expectedReturnDate;
  final DateTime? actualReturnDate;
  final List<String> gradedSteps;
  final String commanderStatusDisclosed; // Strictly 'medically_unavailable'
  final bool clinicianClearanceGranted;

  const ReturnToDutyPlan({
    required this.id,
    required this.officerId,
    required this.clinicianName,
    required this.offDutyStart,
    required this.expectedReturnDate,
    this.actualReturnDate,
    required this.gradedSteps,
    this.commanderStatusDisclosed = 'medically_unavailable',
    this.clinicianClearanceGranted = false,
  });

  /// Hard privacy firewall assertion:
  /// Verifies that no clinical notes, distress levels, or risk scores leak to the commander view.
  void assertMinimumNecessaryCommanderDisclosure() {
    final status = commanderStatusDisclosed.toLowerCase().trim();
    if (status != 'medically_unavailable' && status != 'available') {
      throw const FirewallViolationException(
        'Firewall Breach: Commander disclosed status must strictly be "medically_unavailable" or "available". '
        'Leaking psychological scores or clinical assessments to commanders is strictly prohibited.',
      );
    }
  }

  /// Ensures off-duty recommendations can ONLY originate from human clinicians, NEVER automated algorithms.
  static void assertHumanClinicianAuthorized(String recommendedByType) {
    if (recommendedByType != 'clinician') {
      throw const FirewallViolationException(
        'Human Intervention Gate Violation: Temporary off-duty status cannot be decided automatically by algorithms. '
        'A formal clinical recommendation by a qualified medical officer or licensed counsellor is strictly required.',
      );
    }
  }

  factory ReturnToDutyPlan.fromMap(Map<String, dynamic> map) {
    final stepsRaw = map['graded_steps'];
    List<String> steps = [];
    if (stepsRaw is List) {
      steps = stepsRaw.map((s) => s.toString()).toList();
    } else if (stepsRaw is String) {
      steps = stepsRaw.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }

    return ReturnToDutyPlan(
      id: map['id'] as String,
      officerId: map['officer_id'] as String,
      clinicianName: map['clinician_name'] as String? ?? 'Force Medical Officer',
      offDutyStart: DateTime.tryParse(map['off_duty_start'] as String? ?? '') ?? DateTime.now(),
      expectedReturnDate: DateTime.tryParse(map['expected_return_date'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 14)),
      actualReturnDate: map['actual_return_date'] != null
          ? DateTime.tryParse(map['actual_return_date'] as String)
          : null,
      gradedSteps: steps.isEmpty
          ? const [
              'Step 1: Clinical decompression & sleep circadian stabilization',
              'Step 2: Non-operational administrative light duty (day shifts only)',
              'Step 3: Supervised peer-pair duty rotation',
              'Step 4: Full operational fitness review and clearance'
            ]
          : steps,
      commanderStatusDisclosed: map['commander_status_disclosed'] as String? ?? 'medically_unavailable',
      clinicianClearanceGranted: map['clinician_clearance_granted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    assertMinimumNecessaryCommanderDisclosure();
    return {
      'id': id,
      'officer_id': officerId,
      'clinician_name': clinicianName,
      'off_duty_start': offDutyStart.toIso8601String().split('T').first,
      'expected_return_date': expectedReturnDate.toIso8601String().split('T').first,
      'actual_return_date': actualReturnDate?.toIso8601String().split('T').first,
      'graded_steps': gradedSteps.join('; '),
      'commander_status_disclosed': commanderStatusDisclosed,
      'clinician_clearance_granted': clinicianClearanceGranted,
    };
  }
}
