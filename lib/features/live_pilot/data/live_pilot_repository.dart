// lib/features/live_pilot/data/live_pilot_repository.dart
// Repository for Phase 20 Live Pilot Deployment, Control Unit Staging, KPI Impacts, Incidents, and Certification

import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/live_pilot_models.dart';
import '../domain/services/live_pilot_engine.dart';

abstract class ILivePilotRepository {
  Future<List<BattalionUnit>> getBattalionUnits();
  Future<PilotVsControlComparison> getPilotVsControlComparison();
  Future<List<LiveIncidentLog>> getLiveIncidents();
  Future<List<LiveTrustMeasurement>> getTrustMeasurements();
  Future<LivePilotCertification> getScaleCertification();
  Future<void> resolveIncident(String incidentId, String notes);
}

class LivePilotRepository implements ILivePilotRepository {
  final SupabaseClient? supabase;

  final List<BattalionUnit> _units = [
    const BattalionUnit(
      unitId: 'unit-p01',
      unitName: '42 Bn BSF (Pilot)',
      force: 'bsf',
      deploymentType: DeploymentType.counterInsurgency,
      activePersonnelCount: 1140,
      isPilotUnit: true,
      locationSector: 'Kupwara Sector, J&K',
    ),
    const BattalionUnit(
      unitId: 'unit-p02',
      unitName: '114 Bn CRPF (Pilot)',
      force: 'crpf',
      deploymentType: DeploymentType.internalSecurity,
      activePersonnelCount: 1080,
      isPilotUnit: true,
      locationSector: 'Anantnag Detachment, J&K',
    ),
    const BattalionUnit(
      unitId: 'unit-p03',
      unitName: '26 Sector Assam Rifles (Pilot)',
      force: 'assam_rifles',
      deploymentType: DeploymentType.highAltitudeBorder,
      activePersonnelCount: 960,
      isPilotUnit: true,
      locationSector: 'Moreh Border Hardship, Manipur',
    ),
    const BattalionUnit(
      unitId: 'unit-c01',
      unitName: '43 Bn BSF (Control)',
      force: 'bsf',
      deploymentType: DeploymentType.counterInsurgency,
      activePersonnelCount: 1120,
      isPilotUnit: false,
      locationSector: 'Rajouri Sector, J&K',
    ),
    const BattalionUnit(
      unitId: 'unit-c02',
      unitName: '115 Bn CRPF (Control)',
      force: 'crpf',
      deploymentType: DeploymentType.internalSecurity,
      activePersonnelCount: 1050,
      isPilotUnit: false,
      locationSector: 'Pulwama Detachment, J&K',
    ),
    const BattalionUnit(
      unitId: 'unit-c03',
      unitName: '27 Sector Assam Rifles (Control)',
      force: 'assam_rifles',
      deploymentType: DeploymentType.highAltitudeBorder,
      activePersonnelCount: 940,
      isPilotUnit: false,
      locationSector: 'Pallel Forward Area, Manipur',
    ),
  ];

  final List<LiveIncidentLog> _incidents = [
    LiveIncidentLog(
      incidentId: 'inc-901',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      unitName: '42 Bn BSF (Pilot)',
      incidentType: IncidentType.crisisIntercept,
      severity: IncidentSeverity.high,
      summary: 'Officer answered PHQ-9 Item 9 > 0. Immediate safety intercept engaged; routed to Tele-MANAS human clinician.',
      humanResponder: 'Dr. Maj Sharma (Regimental Medical Officer)',
      zeroAiVerified: true,
      isResolved: true,
      resolutionNotes: 'Officer safely received by regimental hospital. Safety plan and 14-day respite leave coordinated.',
    ),
    LiveIncidentLog(
      incidentId: 'inc-902',
      timestamp: DateTime.now().subtract(const Duration(hours: 18)),
      unitName: '114 Bn CRPF (Pilot)',
      incidentType: IncidentType.opsecMediaQuarantine,
      severity: IncidentSeverity.low,
      summary: 'Family video upload flagged with GPS coordinate metadata by automated OPSEC scanner.',
      humanResponder: 'Capt. R. Deshmukh (Security Reviewer)',
      zeroAiVerified: true,
      isResolved: true,
      resolutionNotes: 'EXIF GPS tags stripped; media cleared and safely delivered to troop Morale Vault.',
    ),
    LiveIncidentLog(
      incidentId: 'inc-903',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      unitName: '26 Sector AR (Pilot)',
      incidentType: IncidentType.breakGlassAccess,
      severity: IncidentSeverity.medium,
      summary: 'Emergency break-glass accessed by battalion clinician for acute medication allergy history.',
      humanResponder: 'Dr. T. Jamir (Force Clinician)',
      zeroAiVerified: true,
      isResolved: false,
      resolutionNotes: 'Pending post-hoc ethics board review at bi-weekly audit session.',
    ),
  ];

  LivePilotRepository({this.supabase});

  @override
  Future<List<BattalionUnit>> getBattalionUnits() async {
    return List.unmodifiable(_units);
  }

  @override
  Future<PilotVsControlComparison> getPilotVsControlComparison() async {
    return const PilotVsControlComparison(
      comparisonPeriod: '6-Month Field Trial (April - September 2026)',
      totalPilotPersonnel: 3180,
      totalControlPersonnel: 3110,
      metrics: [
        PilotVsControlMetricItem(
          metricName: 'Leave Friction Index',
          pilotValueDisplay: '0.19',
          controlValueDisplay: '0.34',
          percentageImprovement: 44.1,
          interpretation: '44.1% reduction in systemic operational leave bottlenecks through algorithmic respite matching.',
        ),
        PilotVsControlMetricItem(
          metricName: 'Early Distress Lead Time',
          pilotValueDisplay: '14.2 days before crisis',
          controlValueDisplay: '1.8 days post-crisis',
          percentageImprovement: 688.9,
          interpretation: 'Subclinical sleep compression detected on-device 2 weeks earlier than traditional command reports.',
        ),
        PilotVsControlMetricItem(
          metricName: 'Acute Crisis Escalation Rate',
          pilotValueDisplay: '0.4 per 1,000 troops',
          controlValueDisplay: '1.9 per 1,000 troops',
          percentageImprovement: 78.9,
          interpretation: '78.9% reduction in emergency psychiatric casualties through voluntary confidential interventions.',
        ),
        PilotVsControlMetricItem(
          metricName: 'Trust in Confidentiality',
          pilotValueDisplay: '89.2%',
          controlValueDisplay: '54.0%',
          percentageImprovement: 65.2,
          interpretation: 'Troop trust surged due to physical Welfare-HR firewall and strict ACR quarantine guarantee.',
        ),
        PilotVsControlMetricItem(
          metricName: 'Voluntary Check-In Participation',
          pilotValueDisplay: '86.2%',
          controlValueDisplay: '31.5%',
          percentageImprovement: 173.7,
          interpretation: 'Troops willingly submit wellness check-ins without fear of career repercussions.',
        ),
      ],
    );
  }

  @override
  Future<List<LiveIncidentLog>> getLiveIncidents() async {
    return List.unmodifiable(_incidents);
  }

  @override
  Future<List<LiveTrustMeasurement>> getTrustMeasurements() async {
    return [
      LiveTrustMeasurement(
        milestone: 'Month 1',
        pilotTrustScore: 74.2,
        controlTrustScore: 52.0,
        perceivedStigmaRate: 21.4,
        voluntaryCheckInRate: 64.0,
        recordedDate: DateTime.now().subtract(const Duration(days: 150)),
      ),
      LiveTrustMeasurement(
        milestone: 'Month 3',
        pilotTrustScore: 82.5,
        controlTrustScore: 53.5,
        perceivedStigmaRate: 15.0,
        voluntaryCheckInRate: 78.2,
        recordedDate: DateTime.now().subtract(const Duration(days: 90)),
      ),
      LiveTrustMeasurement(
        milestone: 'Month 6',
        pilotTrustScore: 89.2,
        controlTrustScore: 54.0,
        perceivedStigmaRate: 9.8,
        voluntaryCheckInRate: 86.2,
        recordedDate: DateTime.now(),
      ),
    ];
  }

  @override
  Future<LivePilotCertification> getScaleCertification() async {
    return LivePilotEngine.evaluateScaleCertification(
      certificationId: 'CERT-LIVE-PILOT-2026-FINAL',
      clinicalConcordanceRate: 0.932,
      leaveFrictionReduction: 44.1,
      totalTroopsProtected: 3180,
      acrFirewallZeroBreach: true,
      crisisZeroAiCompliant: true,
      clinicalChairpersonSignoff: 'Lt. Gen. Dr. A. Sengupta, DG Armed Forces Medical Services',
      defenceOmbudsmanSignoff: 'Justice S. Kaul (Retd), Defence Ethics Ombudsman',
      directorGeneralSignoff: 'Director General, Central Armed Police Forces',
      remarks: 'Live pilot benchmarks conclusively verified across 3 operational forces. Zero ACR leakage, zero AI crisis violations, 44.1% leave friction reduction. Certified for nationwide multi-battalion scaling under Phase 21.',
    );
  }

  @override
  Future<void> resolveIncident(String incidentId, String notes) async {
    final index = _incidents.indexWhere((i) => i.incidentId == incidentId);
    if (index != -1) {
      _incidents[index] = _incidents[index].copyWith(
        isResolved: true,
        resolutionNotes: notes,
      );
    }
  }
}
