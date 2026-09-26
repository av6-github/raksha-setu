// lib/features/live_pilot/domain/services/live_pilot_engine.dart
// Live pilot verification engine: Comparative impact calculation, firewall zero-breach audit, crisis zero-AI assertion, and scale certification evaluation

import '../models/live_pilot_models.dart';

class LivePilotEngine {
  /// Computes relative percentage improvement between control unit baseline and pilot unit
  static double computeRelativeImprovement({
    required double controlValue,
    required double pilotValue,
    bool lowerIsBetter = true,
  }) {
    if (controlValue == 0) return 0.0;

    final diff = lowerIsBetter
        ? (controlValue - pilotValue) / controlValue
        : (pilotValue - controlValue) / controlValue;

    return double.parse((diff * 100).toStringAsFixed(1));
  }

  /// Asserts that zero clinical or distress records entered ACR or administrative promotion files
  static void assertFirewallZeroBreach({required bool dataEnteredAcr}) {
    if (dataEnteredAcr) {
      throw StateError(
        'Critical Firewall Violation: Wellness data, clinical scores, or distress indicators must NEVER enter ACR or administrative promotion records.',
      );
    }
  }

  /// Verifies that all operational crisis and safety incidents were handled strictly by verified human responders
  static bool verifyCrisisHumanRouting(List<LiveIncidentLog> incidents) {
    if (incidents.isEmpty) return true;
    for (final inc in incidents) {
      if (!inc.zeroAiVerified || inc.humanResponder.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Evaluates readiness to graduate from live pilot to force-wide multi-battalion scale (Phase 21)
  static LivePilotCertification evaluateScaleCertification({
    required String certificationId,
    required double clinicalConcordanceRate,
    required double leaveFrictionReduction,
    required int totalTroopsProtected,
    required bool acrFirewallZeroBreach,
    required bool crisisZeroAiCompliant,
    required String clinicalChairpersonSignoff,
    required String defenceOmbudsmanSignoff,
    required String directorGeneralSignoff,
    required String remarks,
  }) {
    assertFirewallZeroBreach(dataEnteredAcr: !acrFirewallZeroBreach);

    final isEligible = clinicalConcordanceRate >= 0.90 &&
        leaveFrictionReduction >= 20.0 &&
        acrFirewallZeroBreach &&
        crisisZeroAiCompliant;

    return LivePilotCertification(
      certificationId: certificationId,
      status: isEligible ? LivePilotStatus.certifiedForScale : LivePilotStatus.reviewRequired,
      modelVersion: 'v1.4.2-lightgbm',
      clinicalConcordanceRate: clinicalConcordanceRate,
      leaveFrictionReduction: leaveFrictionReduction,
      totalTroopsProtected: totalTroopsProtected,
      acrFirewallZeroBreachVerified: acrFirewallZeroBreach,
      crisisZeroAiVerified: crisisZeroAiCompliant,
      clinicalChairpersonSignoff: clinicalChairpersonSignoff,
      defenceOmbudsmanSignoff: defenceOmbudsmanSignoff,
      directorGeneralSignoff: directorGeneralSignoff,
      certifiedDate: DateTime.now(),
      remarks: remarks,
    );
  }
}
