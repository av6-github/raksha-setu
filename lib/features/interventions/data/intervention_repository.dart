// lib/features/interventions/data/intervention_repository.dart
// Repository for voluntary interventions, counselling bookings, and return-to-duty plans

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../core/logging/app_logger.dart';
import '../domain/counselling_booking.dart';
import '../domain/return_to_duty_plan.dart';
import '../domain/support_intervention.dart';

abstract class IInterventionRepository {
  Future<List<SupportIntervention>> getOfficerInterventions(String officerId);
  Future<SupportIntervention> acceptIntervention(String interventionId);
  Future<SupportIntervention> declineIntervention(String interventionId);
  Future<CounsellingBooking> scheduleCounselling({
    required String officerId,
    required DateTime sessionDate,
    required String sessionType,
    bool isTeleCounselling = false,
  });
  Future<List<CounsellingBooking>> getCounsellingBookings(String officerId);
  Future<ReturnToDutyPlan?> getReturnToDutyPlan(String officerId);
  Future<ReturnToDutyPlan> createReturnToDutyPlan({
    required String officerId,
    required String recommendedByType,
    required DateTime expectedReturnDate,
    required List<String> gradedSteps,
  });
  Future<String> getCommanderDisclosedStatus(String officerId);
}

class InterventionRepository implements IInterventionRepository {
  final sp.SupabaseClient? client;

  // Local state cache for prototype
  final List<SupportIntervention> _interventions = [];
  final List<CounsellingBooking> _counsellingBookings = [];
  ReturnToDutyPlan? _activeRtdPlan;

  InterventionRepository({this.client}) {
    _seedPrototypeData();
  }

  void _seedPrototypeData() {
    _interventions.addAll([
      SupportIntervention(
        id: 'int-1',
        officerId: 'mock-officer-uuid-001',
        recommendedByType: 'welfare_officer',
        interventionType: InterventionType.shiftChange,
        status: InterventionStatus.proposed,
        proposedAt: DateTime.now().subtract(const Duration(days: 1)),
        notes: 'Recommend rotating off consecutive night stand-to shifts for circadian rest.',
      ),
      SupportIntervention(
        id: 'int-2',
        officerId: 'mock-officer-uuid-001',
        recommendedByType: 'welfare_officer',
        interventionType: InterventionType.leaveGranted,
        status: InterventionStatus.proposed,
        proposedAt: DateTime.now().subtract(const Duration(hours: 12)),
        notes: 'Priority 48-hour restorative respite leave authorization.',
      ),
      SupportIntervention(
        id: 'int-3',
        officerId: 'mock-officer-uuid-001',
        recommendedByType: 'welfare_officer',
        interventionType: InterventionType.counselling,
        status: InterventionStatus.accepted,
        proposedAt: DateTime.now().subtract(const Duration(days: 3)),
        actionedAt: DateTime.now().subtract(const Duration(days: 2)),
        notes: 'Voluntary discussion with regimental wellness counsellor.',
      ),
    ]);

    _counsellingBookings.add(
      CounsellingBooking(
        id: 'couns-1',
        officerId: 'mock-officer-uuid-001',
        counsellorName: 'Capt. Ananya Sharma (Clinical Psychologist)',
        sessionDate: DateTime.now().add(const Duration(days: 1, hours: 2)),
        sessionType: 'welfare_followup',
        isTeleCounselling: false,
        status: 'scheduled',
      ),
    );

    _activeRtdPlan = ReturnToDutyPlan(
      id: 'rtd-001',
      officerId: 'mock-officer-uuid-001',
      clinicianName: 'Maj. R. K. Nair (Senior Medical Officer)',
      offDutyStart: DateTime.now().subtract(const Duration(days: 4)),
      expectedReturnDate: DateTime.now().add(const Duration(days: 10)),
      gradedSteps: const [
        'Step 1: Clinical sleep recovery & hydration protocol',
        'Step 2: Restricted light duty (administrative day duties only)',
        'Step 3: Supervised buddy-pair deployment',
        'Step 4: Clinical clearance for high-tempo night rosters'
      ],
      commanderStatusDisclosed: 'medically_unavailable',
      clinicianClearanceGranted: false,
    );
  }

  @override
  Future<List<SupportIntervention>> getOfficerInterventions(String officerId) async {
    return _interventions.where((i) => i.officerId == officerId).toList();
  }

  @override
  Future<SupportIntervention> acceptIntervention(String interventionId) async {
    final idx = _interventions.indexWhere((i) => i.id == interventionId);
    if (idx != -1) {
      final current = _interventions[idx];
      final updated = SupportIntervention(
        id: current.id,
        officerId: current.officerId,
        recommendedByType: current.recommendedByType,
        interventionType: current.interventionType,
        status: InterventionStatus.accepted,
        proposedAt: current.proposedAt,
        actionedAt: DateTime.now(),
        notes: current.notes,
      );
      _interventions[idx] = updated;
      AppLogger.info('Officer accepted intervention ${current.interventionType.name}');
      return updated;
    }
    throw Exception('Intervention $interventionId not found');
  }

  @override
  Future<SupportIntervention> declineIntervention(String interventionId) async {
    final idx = _interventions.indexWhere((i) => i.id == interventionId);
    if (idx != -1) {
      final current = _interventions[idx];
      final updated = SupportIntervention(
        id: current.id,
        officerId: current.officerId,
        recommendedByType: current.recommendedByType,
        interventionType: current.interventionType,
        status: InterventionStatus.declined,
        proposedAt: current.proposedAt,
        actionedAt: DateTime.now(),
        notes: current.notes,
      );
      _interventions[idx] = updated;
      AppLogger.info('Officer voluntarily declined intervention ${current.interventionType.name}');
      return updated;
    }
    throw Exception('Intervention $interventionId not found');
  }

  @override
  Future<CounsellingBooking> scheduleCounselling({
    required String officerId,
    required DateTime sessionDate,
    required String sessionType,
    bool isTeleCounselling = false,
  }) async {
    final booking = CounsellingBooking(
      id: 'couns-${DateTime.now().millisecondsSinceEpoch}',
      officerId: officerId,
      counsellorName: isTeleCounselling ? 'Tele-MANAS On-Duty Officer' : 'Force Regimental Counsellor',
      sessionDate: sessionDate,
      sessionType: sessionType,
      isTeleCounselling: isTeleCounselling,
      status: 'scheduled',
    );
    _counsellingBookings.add(booking);
    AppLogger.info('Scheduled confidential counselling for $officerId on $sessionDate');
    return booking;
  }

  @override
  Future<List<CounsellingBooking>> getCounsellingBookings(String officerId) async {
    return _counsellingBookings.where((c) => c.officerId == officerId).toList();
  }

  @override
  Future<ReturnToDutyPlan?> getReturnToDutyPlan(String officerId) async {
    return _activeRtdPlan?.officerId == officerId ? _activeRtdPlan : null;
  }

  @override
  Future<ReturnToDutyPlan> createReturnToDutyPlan({
    required String officerId,
    required String recommendedByType,
    required DateTime expectedReturnDate,
    required List<String> gradedSteps,
  }) async {
    // Enforce human clinician gate
    ReturnToDutyPlan.assertHumanClinicianAuthorized(recommendedByType);

    final plan = ReturnToDutyPlan(
      id: 'rtd-${DateTime.now().millisecondsSinceEpoch}',
      officerId: officerId,
      clinicianName: 'Force Medical Officer',
      offDutyStart: DateTime.now(),
      expectedReturnDate: expectedReturnDate,
      gradedSteps: gradedSteps,
      commanderStatusDisclosed: 'medically_unavailable',
      clinicianClearanceGranted: false,
    );

    plan.assertMinimumNecessaryCommanderDisclosure();
    _activeRtdPlan = plan;
    AppLogger.info('Created clinical return-to-duty plan for $officerId');
    return plan;
  }

  @override
  Future<String> getCommanderDisclosedStatus(String officerId) async {
    final plan = await getReturnToDutyPlan(officerId);
    if (plan != null && !plan.clinicianClearanceGranted) {
      plan.assertMinimumNecessaryCommanderDisclosure();
      return plan.commanderStatusDisclosed; // 'medically_unavailable'
    }
    return 'available';
  }
}
