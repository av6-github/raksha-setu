// lib/features/counsellor_dashboard/data/counsellor_repository.dart
// Counsellor clinical repository — reads real assessments from Supabase,
// maintains case notes and follow-ups in counselling_sessions table,
// with full unit/widget test mock compatibility

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../core/logging/app_logger.dart';
import '../../auth/domain/user_role.dart';
import '../../../core/security/rbac_guard.dart';
import '../../crisis/domain/safety_plan.dart';
import '../domain/clinical_case.dart';
import '../domain/clinical_follow_up.dart';

abstract class ICounsellorRepository {
  Future<List<ClinicalCase>> getActiveCases();
  Future<ClinicalCase> getCaseDetail(String caseId);
  Future<List<ClinicalFollowUp>> getFollowUps(String caseId);
  Future<void> addFollowUpNote({
    required String caseId,
    required String note,
    required String rtdRecommendation,
  });
  Future<SafetyPlan> getSafetyPlanForOfficer(String officerId);
  Future<void> updateSafetyPlan(SafetyPlan plan);
  Future<BreakGlassEvent> emergencyBreakGlass({
    required String counsellorId,
    required String targetOfficerId,
    required String reasonCode,
    required String justification,
  });
  Future<List<Map<String, dynamic>>> getOfficerAssessments();
  Future<List<Map<String, dynamic>>> getEmergencyAlerts();
  Future<void> acknowledgeCrisisAlert(String alertId);
}

class CounsellorRepository implements ICounsellorRepository {
  final sp.SupabaseClient? client;

  final List<ClinicalCase> _cachedCases = [
    ClinicalCase(
      caseId: 'case-001',
      officerId: 'mock-officer-uuid-001',
      officerDisplayName: 'Vikram S.',
      rank: 'Major',
      unit: '12th Battalion HQ',
      activeConcern: 'Persistent sleep onset disturbance following 60-day high-altitude deployment',
      lastPhq9Score: 11,
      lastGad7Score: 9,
      cssrsSeverity: 'mild',
      hasActiveSafetyPlan: true,
      status: 'active',
      nextSessionDate: DateTime.now().add(const Duration(days: 3)),
      clinicalNotes: [
        'Initial assessment completed. Officer receptive to CBT-I sleep hygiene and box breathing.',
        'Follow-up: Sleep quality improved by 40 minutes per night with consistent sleep window.',
      ],
    ),
    ClinicalCase(
      caseId: 'case-002',
      officerId: 'mock-officer-uuid-002',
      officerDisplayName: 'Rohit M.',
      rank: 'Captain',
      unit: '12-BN Delta Company',
      activeConcern: 'Acute stress and hypervigilance post-operational patrol incident',
      lastPhq9Score: 14,
      lastGad7Score: 15,
      cssrsSeverity: 'moderate',
      hasActiveSafetyPlan: true,
      status: 'active',
      nextSessionDate: DateTime.now().add(const Duration(days: 1)),
      clinicalNotes: [
        'Initiated grounding techniques and PCL-5 tracking. Officer requested daytime light duty.',
      ],
    ),
  ];

  final List<ClinicalFollowUp> _cachedFollowUps = [
    ClinicalFollowUp(
      id: 'fol-001',
      caseId: 'case-001',
      officerId: 'mock-officer-uuid-001',
      sessionDate: DateTime.now().subtract(const Duration(days: 4)),
      sessionType: 'individual_counselling',
      progressNote: 'Review of tactical breathing logs. Officer reports reduced anticipatory tension.',
      attendance: 'attended',
      rtdRecommendation: 'Gradual duty resumption: avoid 24-hour continuous watch shifts for 2 weeks.',
    ),
  ];

  CounsellorRepository({this.client});

  @override
  Future<List<ClinicalCase>> getActiveCases() async {
    RbacGuard.assertAccess(
      role: UserRole.counsellor,
      resource: ResourceType.clinicalAssessmentDetail,
    );

    if (client == null) {
      return List.unmodifiable(_cachedCases);
    }

    try {
      final res = await client!
          .from('assessments')
          .select('''
            id,
            officer_id,
            assessment_type,
            total_score,
            severity_tier,
            phq9_item9_score,
            is_crisis_flagged,
            completed_at,
            officers (
              id,
              first_name,
              last_name,
              designation,
              units (name)
            )
          ''')
          .order('completed_at', ascending: false)
          .limit(60);

      final assessments = res as List;
      final Map<String, List<Map<String, dynamic>>> officerAssessments = {};

      for (final a in assessments) {
        final officerId = a['officer_id'] as String;
        officerAssessments.putIfAbsent(officerId, () => []).add(a as Map<String, dynamic>);
      }

      final Map<String, ClinicalCase> caseMap = {};

      for (final entry in officerAssessments.entries) {
        final officerId = entry.key;
        final records = entry.value;

        // Keep officers with non-normal or flagged assessments
        final hasElevated = records.any((r) {
          final tier = r['severity_tier'] as String? ?? 'normal';
          final crisis = r['is_crisis_flagged'] as bool? ?? false;
          return tier != 'normal' || crisis;
        });

        if (!hasElevated) continue;

        // Find most recent PHQ-9 and GAD-7 records
        final phqRecord = records.where((r) => r['assessment_type'] == 'phq9').firstOrNull;
        final gadRecord = records.where((r) => r['assessment_type'] == 'gad7').firstOrNull;

        final primary = phqRecord ?? gadRecord ?? records.first;
        final officer = primary['officers'] as Map<String, dynamic>?;
        final unit = officer?['units'] as Map<String, dynamic>?;

        final phqScore = (phqRecord?['total_score'] as num?)?.toInt() ?? 0;
        final gadScore = (gadRecord?['total_score'] as num?)?.toInt() ?? 0;
        final isCrisis = (phqRecord?['is_crisis_flagged'] == true) || (gadRecord?['is_crisis_flagged'] == true);
        final item9 = (phqRecord?['phq9_item9_score'] as num?)?.toInt() ?? 0;

        List<String> notes = [];
        try {
          final sessionRes = await client!
              .from('counselling_sessions')
              .select('recommendations')
              .eq('officer_id', officerId)
              .order('session_date', ascending: false)
              .limit(5);
          notes = (sessionRes as List)
              .where((s) => s['recommendations'] != null)
              .map((s) => s['recommendations'] as String)
              .toList();
        } catch (_) {}

        DateTime? nextSession;
        try {
          final followupRes = await client!
              .from('followups')
              .select('scheduled_date')
              .eq('officer_id', officerId)
              .eq('status', 'scheduled')
              .order('scheduled_date', ascending: true)
              .limit(1)
              .maybeSingle();
          if (followupRes != null) {
            nextSession = DateTime.tryParse(followupRes['scheduled_date'] as String? ?? '');
          }
        } catch (_) {}

        final displayName = officer != null
            ? '${officer['first_name']} ${(officer['last_name'] as String?)?.substring(0, 1) ?? ''}.'
            : 'Officer ${officerId.substring(0, 8)}';

        caseMap[officerId] = ClinicalCase(
          caseId: primary['id'] as String,
          officerId: officerId,
          officerDisplayName: displayName,
          rank: officer?['designation'] as String? ?? 'Personnel',
          unit: (unit?['name'] as String?) ?? 'CRPF Unit',
          activeConcern: _deriveCombinedConcern(
            phqScore: phqScore,
            phqTier: phqRecord?['severity_tier'] as String? ?? 'normal',
            gadScore: gadScore,
            gadTier: gadRecord?['severity_tier'] as String? ?? 'normal',
          ),
          lastPhq9Score: phqScore,
          lastGad7Score: gadScore,
          cssrsSeverity: item9 > 0 ? 'mild' : 'none',
          hasActiveSafetyPlan: isCrisis,
          status: isCrisis ? 'crisis' : 'active',
          nextSessionDate: nextSession ?? DateTime.now().add(const Duration(days: 7)),
          clinicalNotes: notes.isNotEmpty
              ? notes
              : ['Initial assessment completed. Monitoring recommended.'],
        );
      }

      if (caseMap.isNotEmpty) {
        _cachedCases
          ..clear()
          ..addAll(caseMap.values);
        return List.unmodifiable(_cachedCases);
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch cases from Supabase; using cached data', error: e);
    }

    return List.unmodifiable(_cachedCases);
  }

  String _deriveCombinedConcern({
    required int phqScore,
    required String phqTier,
    required int gadScore,
    required String gadTier,
  }) {
    if (phqTier == 'crisis' || gadTier == 'crisis') {
      return 'Crisis-level psychological symptoms requiring immediate clinical intervention';
    }
    if (phqTier == 'severe' || gadTier == 'severe') {
      return 'Severe psychological distress (PHQ-9: $phqScore, GAD-7: $gadScore) — urgent clinical care';
    }
    if (phqTier == 'moderate' && gadTier == 'moderate') {
      return 'Co-morbid moderate depression & anxiety (PHQ-9: $phqScore, GAD-7: $gadScore)';
    }
    if (phqTier == 'moderate') {
      return 'Moderate depression (PHQ-9: $phqScore, GAD-7: $gadScore) — regular CBT and monitoring';
    }
    if (gadTier == 'moderate') {
      return 'Generalised anxiety (GAD-7: $gadScore, PHQ-9: $phqScore) — relaxation & grounding indicated';
    }
    if (phqTier == 'mild' || gadTier == 'mild') {
      return 'Mild stress symptoms (PHQ-9: $phqScore, GAD-7: $gadScore) — wellness support recommended';
    }
    return 'Routine psychological monitoring (PHQ-9: $phqScore, GAD-7: $gadScore)';
  }

  @override
  Future<ClinicalCase> getCaseDetail(String caseId) async {
    RbacGuard.assertAccess(
      role: UserRole.counsellor,
      resource: ResourceType.clinicalAssessmentDetail,
    );

    final cached = _cachedCases.where((c) => c.caseId == caseId).toList();
    if (cached.isNotEmpty) return cached.first;

    final cases = await getActiveCases();
    return cases.firstWhere(
      (c) => c.caseId == caseId,
      orElse: () => throw ArgumentError('Case not found: $caseId'),
    );
  }

  @override
  Future<List<ClinicalFollowUp>> getFollowUps(String caseId) async {
    RbacGuard.assertAccess(
      role: UserRole.counsellor,
      resource: ResourceType.clinicalFollowUps,
    );

    final caseObj = _cachedCases.where((c) => c.caseId == caseId).firstOrNull;
    final officerId = caseObj?.officerId;

    if (client != null && officerId != null) {
      try {
        final res = await client!
            .from('counselling_sessions')
            .select()
            .eq('officer_id', officerId)
            .order('session_date', ascending: false);

        final list = (res as List).map((s) {
          return ClinicalFollowUp(
            id: s['id'] as String,
            caseId: caseId,
            officerId: officerId,
            sessionDate: DateTime.parse(s['session_date'] as String),
            sessionType: s['session_type'] as String? ?? 'individual_counselling',
            progressNote: s['recommendations'] as String? ?? 'Session completed.',
            attendance: s['attended'] == true ? 'attended' : 'missed',
            rtdRecommendation: s['recommendations'] as String? ?? 'Continue monitoring.',
          );
        }).toList();

        if (list.isNotEmpty) return list;
      } catch (e) {
        AppLogger.warning('Failed to fetch follow-ups from Supabase', error: e);
      }
    }

    return _cachedFollowUps.where((f) => f.caseId == caseId).toList();
  }

  @override
  Future<void> addFollowUpNote({
    required String caseId,
    required String note,
    required String rtdRecommendation,
  }) async {
    RbacGuard.assertAccess(
      role: UserRole.counsellor,
      resource: ResourceType.clinicalTherapyNotes,
    );

    final caseIndex = _cachedCases.indexWhere((c) => c.caseId == caseId);
    if (caseIndex != -1) {
      final current = _cachedCases[caseIndex];
      final updatedNotes = List<String>.from(current.clinicalNotes)..add(note);
      _cachedCases[caseIndex] = current.copyWith(clinicalNotes: updatedNotes);

      final followUp = ClinicalFollowUp(
        id: 'fol-${DateTime.now().millisecondsSinceEpoch}',
        caseId: caseId,
        officerId: current.officerId,
        sessionDate: DateTime.now(),
        sessionType: 'welfare_followup',
        progressNote: note,
        attendance: 'attended',
        rtdRecommendation: rtdRecommendation,
      );
      _cachedFollowUps.add(followUp);

      if (client != null) {
        try {
          await client!.from('counselling_sessions').insert({
            'officer_id': current.officerId,
            'session_date': DateTime.now().toIso8601String(),
            'session_type': 'welfare_followup',
            'recommendations': '$note\n\nReturn to Duty: $rtdRecommendation',
            'attended': true,
          });
          AppLogger.info('Follow-up note saved to Supabase for officer ${current.officerId}');
        } catch (e) {
          AppLogger.warning('Failed to save follow-up to Supabase', error: e);
        }
      }
    }
  }

  @override
  Future<SafetyPlan> getSafetyPlanForOfficer(String officerId) async {
    RbacGuard.assertAccess(
      role: UserRole.counsellor,
      resource: ResourceType.clinicalSafetyPlan,
    );

    if (client != null) {
      try {
        final res = await client!
            .from('safety_plans')
            .select()
            .eq('officer_id', officerId)
            .order('plan_date', ascending: false)
            .limit(1)
            .maybeSingle();

        if (res != null) {
          return SafetyPlan(
            id: res['id'] as String,
            officerId: officerId,
            warningSigns: [res['warning_signs'] as String? ?? 'Insomnia, isolation'],
            internalCopingStrategies: ((res['coping_strategies'] as String?) ?? '')
                .split('\n')
                .where((s) => s.isNotEmpty)
                .toList(),
            socialDistractions: const [
              'Recreation room visit',
              'Volleyball with squad',
            ],
            trustedContacts: const [
              {'name': 'Subedar Major', 'role': 'Senior Peer', 'phone': '9876543210'},
            ],
            professionalContacts: [
              {'name': 'Tele-MANAS', 'role': 'National Helpline', 'phone': '14416'},
              {'name': 'Regimental Medical Desk', 'role': 'Medical Desk', 'phone': '011-26192999'},
            ],
            environmentalSafetySteps: [
              res['means_restriction_recommendation'] as String? ?? 'Secure firearm in kote'
            ],
            updatedAt: DateTime.tryParse(res['plan_date'] as String? ?? '') ?? DateTime.now(),
          );
        }
      } catch (e) {
        AppLogger.warning('Failed to load safety plan from Supabase', error: e);
      }
    }

    return SafetyPlan.defaultTemplate(officerId);
  }

  @override
  Future<void> updateSafetyPlan(SafetyPlan plan) async {
    RbacGuard.assertAccess(
      role: UserRole.counsellor,
      resource: ResourceType.clinicalSafetyPlan,
    );

    if (client != null) {
      try {
        await client!.from('safety_plans').upsert({
          'officer_id': plan.officerId,
          'warning_signs': plan.warningSigns.join('\n'),
          'coping_strategies': plan.internalCopingStrategies.join('\n'),
          'professional_resources': plan.professionalContacts.map((c) => '${c['name']}: ${c['phone']}').join('; '),
          'means_restriction_recommendation': plan.environmentalSafetySteps.join('\n'),
          'plan_date': plan.updatedAt.toIso8601String(),
        });
        AppLogger.info('Safety plan updated in Supabase for officer ${plan.officerId}');
      } catch (e) {
        AppLogger.error('Failed to save safety plan to Supabase', error: e);
      }
    }
  }

  @override
  Future<BreakGlassEvent> emergencyBreakGlass({
    required String counsellorId,
    required String targetOfficerId,
    required String reasonCode,
    required String justification,
  }) async {
    return RbacGuard.recordBreakGlass(
      requesterId: counsellorId,
      requesterRole: UserRole.counsellor,
      targetOfficerId: targetOfficerId,
      reasonCode: reasonCode,
      clinicalJustification: justification,
    );
  }

  final List<Map<String, dynamic>> _mockAssessments = [
    {
      'id': 'asm-seed-003',
      'officer_name': 'Inspector Arjun Thakur',
      'service_number': 'BSF-2018-9932',
      'unit': '45 Battalion BSF (Alpha Co)',
      'assessment_type': 'PHQ-9 Depression Inventory',
      'total_score': 14,
      'max_score': 27,
      'severity_tier': 'moderate',
      'phq9_item9_score': 0,
      'is_crisis_flagged': false,
      'completed_at': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
    },
    {
      'id': 'asm-seed-001',
      'officer_name': 'Subedar Vikram Singh',
      'service_number': 'CRPF-2026-7788',
      'unit': '12 Battalion CRPF (Charlie Co)',
      'assessment_type': 'PHQ-9 Depression Inventory',
      'total_score': 8,
      'max_score': 27,
      'severity_tier': 'mild',
      'phq9_item9_score': 0,
      'is_crisis_flagged': false,
      'completed_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
    {
      'id': 'asm-seed-002',
      'officer_name': 'Head Constable Priya Nair',
      'service_number': 'CRPF-2022-4421',
      'unit': '12 Battalion CRPF (Charlie Co)',
      'assessment_type': 'PHQ-9 Depression Inventory',
      'total_score': 3,
      'max_score': 27,
      'severity_tier': 'normal',
      'phq9_item9_score': 0,
      'is_crisis_flagged': false,
      'completed_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
  ];

  final List<Map<String, dynamic>> _mockEmergencyAlerts = [
    {
      'id': 'crs-mock-001',
      'officer_name': 'Inspector Arjun Thakur',
      'service_number': 'BSF-2018-9932',
      'unit': '45 BN BSF',
      'trigger_source': 'Automated Wearable CUSUM Spike & Duty Stress',
      'severity': 'high',
      'status': 'escalated',
      'triggered_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> getOfficerAssessments() async {
    RbacGuard.assertAccess(
      role: UserRole.counsellor,
      resource: ResourceType.clinicalAssessmentDetail,
    );

    if (client != null) {
      try {
        final res = await client!
            .from('assessments')
            .select('''
              id,
              officer_id,
              assessment_type,
              total_score,
              severity_tier,
              phq9_item9_score,
              is_crisis_flagged,
              completed_at,
              officers (
                id,
                first_name,
                last_name,
                designation,
                service_number,
                units (name)
              )
            ''')
            .order('completed_at', ascending: false)
            .limit(30);

        final list = res as List;
        if (list.isNotEmpty) {
          return list.map((a) {
            final officer = a['officers'] as Map<String, dynamic>?;
            final unit = officer?['units'] as Map<String, dynamic>?;
            final isPhq = a['assessment_type'] == 'phq9';

            return {
              'id': a['id']?.toString() ?? '',
              'officer_name': officer != null
                  ? '${officer['designation'] ?? 'Officer'} ${officer['first_name']} ${officer['last_name'] ?? ''}'
                  : 'Officer ${a['officer_id']?.toString().substring(0, 8)}',
              'service_number': officer?['service_number']?.toString() ?? '—',
              'unit': unit?['name']?.toString() ?? 'CRPF Sector',
              'assessment_type': isPhq ? 'PHQ-9 Depression Inventory' : 'GAD-7 Anxiety Screening',
              'total_score': (a['total_score'] as num?)?.toInt() ?? 0,
              'max_score': isPhq ? 27 : 21,
              'severity_tier': a['severity_tier']?.toString() ?? 'mild',
              'phq9_item9_score': (a['phq9_item9_score'] as num?)?.toInt() ?? 0,
              'is_crisis_flagged': a['is_crisis_flagged'] as bool? ?? false,
              'completed_at': a['completed_at']?.toString() ?? DateTime.now().toIso8601String(),
            };
          }).toList();
        }
      } catch (e) {
        AppLogger.warning('Failed to fetch officer assessments from Supabase', error: e);
      }
    }

    return List.unmodifiable(_mockAssessments);
  }

  @override
  Future<List<Map<String, dynamic>>> getEmergencyAlerts() async {
    RbacGuard.assertAccess(
      role: UserRole.counsellor,
      resource: ResourceType.clinicalAssessmentDetail,
    );

    if (client != null) {
      try {
        final res = await client!
            .from('crisis_events')
            .select('''
              id,
              officer_id,
              trigger_source,
              status,
              desk_routed,
              triggered_at,
              officers (
                first_name,
                last_name,
                designation,
                service_number,
                units (name)
              )
            ''')
            .order('triggered_at', ascending: false)
            .limit(20);

        final list = res as List;
        if (list.isNotEmpty) {
          return list.map((c) {
            final officer = c['officers'] as Map<String, dynamic>?;
            final unit = officer?['units'] as Map<String, dynamic>?;
            final trigger = c['trigger_source']?.toString() ?? 'Direct SOS Alert';

            return {
              'id': c['id']?.toString() ?? '',
              'officer_name': officer != null
                  ? '${officer['designation'] ?? 'Officer'} ${officer['first_name']} ${officer['last_name'] ?? ''}'
                  : 'Officer ${c['officer_id']?.toString().substring(0, 8)}',
              'service_number': officer?['service_number']?.toString() ?? '—',
              'unit': unit?['name']?.toString() ?? 'Unit Forward Base',
              'trigger_source': trigger,
              'severity': trigger.contains('phq9') || trigger.contains('sos') ? 'imminent' : 'high',
              'status': c['status']?.toString() ?? 'escalated',
              'triggered_at': c['triggered_at']?.toString() ?? DateTime.now().toIso8601String(),
            };
          }).toList();
        }
      } catch (e) {
        AppLogger.warning('Failed to fetch emergency alerts from Supabase', error: e);
      }
    }

    return List.unmodifiable(_mockEmergencyAlerts);
  }

  @override
  Future<void> acknowledgeCrisisAlert(String alertId) async {
    if (client != null) {
      try {
        await client!
            .from('crisis_events')
            .update({
              'status': 'attending_by_counsellor',
            })
            .eq('id', alertId);
      } catch (e) {
        AppLogger.warning('Failed to acknowledge crisis alert on Supabase', error: e);
      }
    }

    for (final a in _mockEmergencyAlerts) {
      if (a['id'] == alertId) {
        a['status'] = 'attending_by_counsellor';
      }
    }
  }
}
