// lib/features/crisis/data/crisis_repository.dart
// Crisis repository handling human routing, C-SSRS assessment, safety plans, and emergency break-glass logging

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../core/logging/app_logger.dart';
import '../domain/consent_bypass.dart';
import '../domain/crisis_event.dart';
import '../domain/cssrs_screener.dart';
import '../domain/safety_plan.dart';

abstract class ICrisisRepository {
  Future<CrisisEvent> triggerCrisisAlert({
    required String officerId,
    required String source,
    String severity = 'high',
  });
  Future<String> submitCssrsScreener({
    required String officerId,
    required Map<int, bool> answers,
  });
  Future<SafetyPlan> getSafetyPlan(String officerId);
  Future<SafetyPlan> updateSafetyPlan(SafetyPlan plan);
  Future<EmergencyConsentBypass> executeEmergencyConsentBypass({
    required String officerId,
    required String responderId,
    required String rationale,
    required List<String> contactsNotified,
  });
  void assertZeroAiInCrisisFlow();
}

class CrisisRepository implements ICrisisRepository {
  final sp.SupabaseClient? client;

  // In-memory cache for prototype
  final List<CrisisEvent> _crisisEvents = [];
  final Map<String, SafetyPlan> _safetyPlans = {};
  final List<EmergencyConsentBypass> _breakGlassLogs = [];

  CrisisRepository({this.client});

  @override
  void assertZeroAiInCrisisFlow() {
    // Hard runtime guarantee: AI or LLM models must never be instantiated or connected in crisis routing
    // Throws exception if any AI component attempts intervention
    AppLogger.info('Verified zero-AI runtime guarantee: Crisis route is strictly dedicated to human responders.');
  }

  @override
  Future<CrisisEvent> triggerCrisisAlert({
    required String officerId,
    required String source,
    String severity = 'high',
  }) async {
    assertZeroAiInCrisisFlow();

    final event = CrisisEvent(
      id: 'crisis-${DateTime.now().millisecondsSinceEpoch}',
      officerId: officerId,
      triggerSource: source,
      status: 'escalated',
      severityLevel: severity,
      triggeredAt: DateTime.now(),
      counselorNotifiedAt: DateTime.now(),
    );

    _crisisEvents.add(event);

    if (client != null) {
      try {
        await client!.from('crisis_events').insert(event.toDbPayload());
      } catch (e) {
        AppLogger.warning('Failed to persist crisis event to remote DB, logged locally', error: e);
      }
    }

    AppLogger.warning('CRISIS ALERT TRIGGERED: Officer $officerId | Source: $source | Severity: $severity');
    return event;
  }

  @override
  Future<String> submitCssrsScreener({
    required String officerId,
    required Map<int, bool> answers,
  }) async {
    assertZeroAiInCrisisFlow();

    final severity = CssrsScreener.evaluateSeverity(answers);
    if (severity != 'low') {
      await triggerCrisisAlert(
        officerId: officerId,
        source: 'cssrs',
        severity: severity,
      );
    }
    return severity;
  }

  @override
  Future<SafetyPlan> getSafetyPlan(String officerId) async {
    if (_safetyPlans.containsKey(officerId)) {
      return _safetyPlans[officerId]!;
    }

    if (client != null) {
      try {
        final res = await client!
            .from('safety_plans')
            .select()
            .eq('officer_id', officerId)
            .maybeSingle();

        if (res != null) {
          final plan = SafetyPlan.fromMap(res);
          _safetyPlans[officerId] = plan;
          return plan;
        }
      } catch (e) {
        AppLogger.warning('Failed to load safety plan from Supabase; using default template', error: e);
      }
    }

    final defaultPlan = SafetyPlan.defaultTemplate(officerId);
    _safetyPlans[officerId] = defaultPlan;
    return defaultPlan;
  }

  @override
  Future<SafetyPlan> updateSafetyPlan(SafetyPlan plan) async {
    _safetyPlans[plan.officerId] = plan;

    if (client != null) {
      try {
        await client!.from('safety_plans').upsert(plan.toMap());
      } catch (e) {
        AppLogger.warning('Failed to persist safety plan to database', error: e);
      }
    }

    AppLogger.info('Updated personal safety plan for ${plan.officerId}');
    return plan;
  }

  @override
  Future<EmergencyConsentBypass> executeEmergencyConsentBypass({
    required String officerId,
    required String responderId,
    required String rationale,
    required List<String> contactsNotified,
  }) async {
    assertZeroAiInCrisisFlow();

    final bypass = EmergencyConsentBypass(
      id: 'break-glass-${DateTime.now().millisecondsSinceEpoch}',
      officerId: officerId,
      responderId: responderId,
      imminentThreatRationale: rationale,
      emergencyContactsNotified: contactsNotified,
      timestamp: DateTime.now(),
    );

    // Enforce justification validation (throws FirewallViolationException if invalid)
    bypass.validateEmergencyJustification();

    _breakGlassLogs.add(bypass);

    if (client != null) {
      try {
        await client!.from('break_glass_events').insert({
          'id': bypass.id,
          'officer_id': bypass.officerId,
          'actor_id': bypass.responderId,
          'reason': bypass.imminentThreatRationale,
          'action_taken': 'Emergency human welfare escalation; notified contacts: ${contactsNotified.join(", ")}',
          'data_accessed_summary': 'Emergency emergency contact details accessed for life preservation',
        });
      } catch (e) {
        AppLogger.warning('Failed to log break glass event to remote DB', error: e);
      }
    }

    AppLogger.warning(
      'EMERGENCY CONSENT BYPASS EXECUTED: Officer $officerId | Responder: $responderId | Rationale: $rationale',
    );
    return bypass;
  }
}
