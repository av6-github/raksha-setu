// lib/features/live_pilot/domain/models/live_pilot_models.dart
// Domain models for Phase 20: Live Pilot Deployment, Control Unit Staging, Comparative KPIs, Incident Tracking, and Scale Certification

enum DeploymentType { counterInsurgency, highAltitudeBorder, internalSecurity, peaceStation }
enum IncidentType { crisisIntercept, breakGlassAccess, opsecMediaQuarantine, leaveFrictionSpike }
enum IncidentSeverity { low, medium, high, critical }
enum LivePilotStatus { inProgress, certifiedForScale, reviewRequired }

class BattalionUnit {
  final String unitId;
  final String unitName;
  final String force; // 'bsf', 'crpf', 'assam_rifles', 'itbp', 'cisf'
  final DeploymentType deploymentType;
  final int activePersonnelCount;
  final bool isPilotUnit; // true = Pilot with RakshaSetu, false = Matching Control SOP
  final String locationSector;

  const BattalionUnit({
    required this.unitId,
    required this.unitName,
    required this.force,
    required this.deploymentType,
    required this.activePersonnelCount,
    required this.isPilotUnit,
    required this.locationSector,
  });
}

class PilotVsControlMetricItem {
  final String metricName;
  final String pilotValueDisplay;
  final String controlValueDisplay;
  final double percentageImprovement; // Positive indicates beneficial outcome
  final String interpretation;

  const PilotVsControlMetricItem({
    required this.metricName,
    required this.pilotValueDisplay,
    required this.controlValueDisplay,
    required this.percentageImprovement,
    required this.interpretation,
  });
}

class PilotVsControlComparison {
  final String comparisonPeriod; // e.g. "6-Month Live Pilot (April - September 2026)"
  final int totalPilotPersonnel;
  final int totalControlPersonnel;
  final List<PilotVsControlMetricItem> metrics;

  const PilotVsControlComparison({
    required this.comparisonPeriod,
    required this.totalPilotPersonnel,
    required this.totalControlPersonnel,
    required this.metrics,
  });
}

class LiveIncidentLog {
  final String incidentId;
  final DateTime timestamp;
  final String unitName;
  final IncidentType incidentType;
  final IncidentSeverity severity;
  final String summary;
  final String humanResponder;
  final bool zeroAiVerified; // Strictly true: zero automated bot handling
  final bool isResolved;
  final String? resolutionNotes;

  const LiveIncidentLog({
    required this.incidentId,
    required this.timestamp,
    required this.unitName,
    required this.incidentType,
    required this.severity,
    required this.summary,
    required this.humanResponder,
    this.zeroAiVerified = true,
    required this.isResolved,
    this.resolutionNotes,
  });

  LiveIncidentLog copyWith({bool? isResolved, String? resolutionNotes}) {
    return LiveIncidentLog(
      incidentId: incidentId,
      timestamp: timestamp,
      unitName: unitName,
      incidentType: incidentType,
      severity: severity,
      summary: summary,
      humanResponder: humanResponder,
      zeroAiVerified: zeroAiVerified,
      isResolved: isResolved ?? this.isResolved,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
    );
  }
}

class LiveTrustMeasurement {
  final String milestone; // 'Month 1', 'Month 3', 'Month 6'
  final double pilotTrustScore; // 0 - 100
  final double controlTrustScore; // 0 - 100
  final double perceivedStigmaRate; // Low is better
  final double voluntaryCheckInRate; // High is better
  final DateTime recordedDate;

  const LiveTrustMeasurement({
    required this.milestone,
    required this.pilotTrustScore,
    required this.controlTrustScore,
    required this.perceivedStigmaRate,
    required this.voluntaryCheckInRate,
    required this.recordedDate,
  });
}

class LivePilotCertification {
  final String certificationId;
  final LivePilotStatus status;
  final String modelVersion;
  final double clinicalConcordanceRate;
  final double leaveFrictionReduction;
  final int totalTroopsProtected;
  final bool acrFirewallZeroBreachVerified;
  final bool crisisZeroAiVerified;
  final String clinicalChairpersonSignoff;
  final String defenceOmbudsmanSignoff;
  final String directorGeneralSignoff;
  final DateTime certifiedDate;
  final String remarks;

  const LivePilotCertification({
    required this.certificationId,
    required this.status,
    required this.modelVersion,
    required this.clinicalConcordanceRate,
    required this.leaveFrictionReduction,
    required this.totalTroopsProtected,
    required this.acrFirewallZeroBreachVerified,
    required this.crisisZeroAiVerified,
    required this.clinicalChairpersonSignoff,
    required this.defenceOmbudsmanSignoff,
    required this.directorGeneralSignoff,
    required this.certifiedDate,
    required this.remarks,
  });

  bool get isApprovedForScale =>
      status == LivePilotStatus.certifiedForScale &&
      acrFirewallZeroBreachVerified &&
      crisisZeroAiVerified &&
      clinicalConcordanceRate >= 0.90;
}
