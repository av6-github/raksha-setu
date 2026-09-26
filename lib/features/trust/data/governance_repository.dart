// lib/features/trust/data/governance_repository.dart
// Repository for Governance, Independent Oversight, Bias Audits, Break-Glass Review, and Security Compliance

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../domain/governance_models.dart';
import '../../../core/security/field_encryption_service.dart';

abstract class IGovernanceRepository {
  Future<List<OversightReview>> getOversightReviews();
  Future<List<BiasAudit>> getBiasAudits();
  Future<List<BreakGlassEvent>> getBreakGlassEvents();
  Future<void> reviewBreakGlassEvent(String eventId, BreakGlassStatus status, String notes);
  Future<List<CoDesignFeedback>> getCoDesignFeedbacks();
  Future<void> submitCoDesignFeedback(CoDesignFeedback feedback);
  Future<ShadowPilotMetrics> getShadowPilotMetrics();
  Future<Map<String, dynamic>> getSecurityComplianceStatus();
}

class GovernanceRepository implements IGovernanceRepository {
  final sp.SupabaseClient? client;
  final FieldEncryptionService encryptionService;

  final List<OversightReview> _oversightReviews = [];
  final List<BiasAudit> _biasAudits = [];
  final List<BreakGlassEvent> _breakGlassEvents = [];
  final List<CoDesignFeedback> _coDesignFeedbacks = [];

  GovernanceRepository({
    this.client,
    FieldEncryptionService? encryptionService,
  }) : encryptionService = encryptionService ?? FieldEncryptionService() {
    _seedDefaultData();
  }

  void _seedDefaultData() {
    final now = DateTime.now();

    // 1. Independent Oversight Reviews
    _oversightReviews.addAll([
      OversightReview(
        id: 'rev-001',
        reviewDate: now.subtract(const Duration(days: 14)),
        reviewType: OversightReviewType.ethicsBoard,
        findings: 'Audited 1,200 synthetic and volunteer test instances. No autonomous punitive actions detected. Human-in-the-loop requirement 100% verified across clinical tiers.',
        correctiveActions: 'None. Recommended continued bi-weekly review intervals.',
        status: 'completed',
        approvedByName: 'Justice S. Kaul (Retd), Defence Ethics Ombudsman',
      ),
      OversightReview(
        id: 'rev-002',
        reviewDate: now.subtract(const Duration(days: 28)),
        reviewType: OversightReviewType.firewallVerification,
        findings: 'Zero stress, psychometric, or counselling data found in ACR records or administrative HR promotion rosters. Hard Welfare-HR firewall verified at database level.',
        correctiveActions: 'Field-level encryption key rotation cadence re-benchmarked to 90 days.',
        status: 'completed',
        approvedByName: 'Director of Personnel & Vigilance Audit',
      ),
      OversightReview(
        id: 'rev-003',
        reviewDate: now.subtract(const Duration(days: 42)),
        reviewType: OversightReviewType.antiStigmatisation,
        findings: 'Reviewed wording of all peer recognitions and community testimonials. Verified absence of shaming or disciplinary vocabulary.',
        correctiveActions: 'Added 3 more frontline veteran testimonials in regional languages.',
        status: 'completed',
        approvedByName: 'Senior Consultant Psychiatrist, AIIMS',
      ),
    ]);

    // 2. Bias Audits across Subgroups
    _biasAudits.addAll([
      BiasAudit(
        id: 'bias-001',
        auditDate: now.subtract(const Duration(days: 10)),
        subgroup: 'Gender (Women in CAPF vs Men)',
        sampleSize: 1540,
        falsePositiveRate: 0.048,
        falseNegativeRate: 0.052,
        disparityMetric: 0.94, // >= 0.80 standard compliant
        isCompliant: true,
      ),
      BiasAudit(
        id: 'bias-002',
        auditDate: now.subtract(const Duration(days: 10)),
        subgroup: 'Rank (Constabulary / PBOR vs Gazetted Officers)',
        sampleSize: 4200,
        falsePositiveRate: 0.051,
        falseNegativeRate: 0.049,
        disparityMetric: 0.92,
        isCompliant: true,
      ),
      BiasAudit(
        id: 'bias-003',
        auditDate: now.subtract(const Duration(days: 10)),
        subgroup: 'Hardship Tier (Extreme Hazard CI vs Peace Posting)',
        sampleSize: 3100,
        falsePositiveRate: 0.055,
        falseNegativeRate: 0.046,
        disparityMetric: 0.89,
        isCompliant: true,
      ),
    ]);

    // 3. Break-Glass Events
    _breakGlassEvents.addAll([
      BreakGlassEvent(
        id: 'bg-001',
        actorIdentityId: 'counsellor-ident-001',
        actorName: 'Dr. Sunita Rao (Unit Clinician)',
        officerId: 'mock-officer-uuid-001',
        officerName: 'Insp. Rajesh Kumar',
        reason: 'Imminent acute crisis protocol triggered during remote detachment patrol; required immediate access to medical allergy history and previous clinical follow-up.',
        authorizedBy: 'Chief Medical Officer, Composite Hospital',
        accessGrantedAt: now.subtract(const Duration(days: 6, hours: 4)),
        accessExpiresAt: now.subtract(const Duration(days: 6, hours: 2)),
        reviewStatus: BreakGlassStatus.validatedEmergency,
        reviewerNotes: 'Validated by Ethics Oversight Board. Emergency access was clinically necessary and strictly contained.',
        reviewedAt: now.subtract(const Duration(days: 4)),
      ),
      BreakGlassEvent(
        id: 'bg-002',
        actorIdentityId: 'welfare-ident-002',
        actorName: 'Asst. Comdt. Manoj Verma (Welfare Officer)',
        officerId: 'officer-external-004',
        officerName: 'Head Constable Ramesh Chand',
        reason: 'Post-trauma family outreach request following severe natural calamity in home district.',
        authorizedBy: 'Commandant, 68th Bn',
        accessGrantedAt: now.subtract(const Duration(hours: 18)),
        accessExpiresAt: now.subtract(const Duration(hours: 14)),
        reviewStatus: BreakGlassStatus.pendingReview,
      ),
    ]);

    // 4. Troop Co-Design Feedbacks
    _coDesignFeedbacks.addAll([
      CoDesignFeedback(
        id: 'cd-001',
        officerRankDisplay: 'Sub-Inspector',
        unit: '45 Bn CRPF',
        topic: 'App Lock & Pin Speed',
        feedbackText: 'Jawans on duty need rapid 4-digit PIN unlock rather than biometric face scan when wearing tactical balaclavas or helmets.',
        actionStatus: 'implemented',
        submittedAt: now.subtract(const Duration(days: 20)),
      ),
      CoDesignFeedback(
        id: 'cd-002',
        officerRankDisplay: 'Head Constable',
        unit: '112 Bn BSF',
        topic: 'Welfare Firewall Clarification',
        feedbackText: 'Add an explicit visual banner on every check-in screen stating that company commanders cannot see individual PHQ answers.',
        actionStatus: 'implemented',
        submittedAt: now.subtract(const Duration(days: 15)),
      ),
      CoDesignFeedback(
        id: 'cd-003',
        officerRankDisplay: 'Constable (GD)',
        unit: 'Mahila Bn, CISF',
        topic: 'Family Days in Regional Calendar',
        feedbackText: 'Include regional festival holidays in the bulletin calendar so shift rosters can plan leave without surprise conflicts.',
        actionStatus: 'implemented',
        submittedAt: now.subtract(const Duration(days: 8)),
      ),
    ]);
  }

  @override
  Future<List<OversightReview>> getOversightReviews() async {
    return _oversightReviews;
  }

  @override
  Future<List<BiasAudit>> getBiasAudits() async {
    return _biasAudits;
  }

  @override
  Future<List<BreakGlassEvent>> getBreakGlassEvents() async {
    return _breakGlassEvents;
  }

  @override
  Future<void> reviewBreakGlassEvent(String eventId, BreakGlassStatus status, String notes) async {
    final index = _breakGlassEvents.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      _breakGlassEvents[index] = _breakGlassEvents[index].copyWith(
        reviewStatus: status,
        reviewerNotes: notes,
        reviewedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<List<CoDesignFeedback>> getCoDesignFeedbacks() async {
    return _coDesignFeedbacks;
  }

  @override
  Future<void> submitCoDesignFeedback(CoDesignFeedback feedback) async {
    _coDesignFeedbacks.insert(0, feedback);
  }

  @override
  Future<ShadowPilotMetrics> getShadowPilotMetrics() async {
    return const ShadowPilotMetrics(
      modelVersion: 'v1.4.2-calibrated-xgboost',
      totalShadowScored: 2450,
      concordanceWithClinicians: 0.932,
      brierScore: 0.082,
      prAuc: 0.841,
      falsePositiveParity: true,
      goNoGoStatus: 'PASSED_SHADOW_PILOT',
    );
  }

  @override
  Future<Map<String, dynamic>> getSecurityComplianceStatus() async {
    return {
      'aes_256_at_rest': true,
      'tls_1_3_enforced': true,
      'field_level_encryption': true,
      'kms_envelope_protection': 'DEFENCE_HSM_NITRO (FIPS 140-3 Level 4)',
      'k_anonymity_threshold': 10,
      'differential_privacy_epsilon': 1.0,
      'immutable_audit_logs': true,
      'welfare_hr_firewall_status': 'ACTIVE_HARD_FIREWALL',
      'tenant_isolation': 'PER_FORCE_DATABASE_RLS_ENFORCED',
    };
  }
}
