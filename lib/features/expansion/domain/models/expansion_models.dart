// lib/features/expansion/domain/models/expansion_models.dart
// Domain models for Phase 22: Expansion into State Police, Disaster Response, Emergency Services, and High-Stress Workforces

enum ExpansionSector {
  statePolice,
  disasterResponse,
  emergencyServices,
  highStressGovernment,
  corporateWellness,
  internationalSecurity,
}

class SectorProfile {
  final ExpansionSector sector;
  final String title;
  final String description;
  final String iconKey;
  final List<String> operationalStressors;
  final List<String> hierarchyRanks;
  final List<String> welfareSchemes;
  final String crisisHotline;
  final String firewallStatutoryRule;
  final int projectedPersonnel;
  final bool isPlugAndPlay;
  final double readinessScore; // 0 - 100

  const SectorProfile({
    required this.sector,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.operationalStressors,
    required this.hierarchyRanks,
    required this.welfareSchemes,
    required this.crisisHotline,
    required this.firewallStatutoryRule,
    required this.projectedPersonnel,
    required this.isPlugAndPlay,
    required this.readinessScore,
  });
}

class SectorReadinessAudit {
  final int totalSectorsCataloged;
  final int fullyAdaptedSectors;
  final int aggregateWorkforceReach;
  final bool universalFirewallGuaranteed;
  final String auditSignoff;

  const SectorReadinessAudit({
    required this.totalSectorsCataloged,
    required this.fullyAdaptedSectors,
    required this.aggregateWorkforceReach,
    required this.universalFirewallGuaranteed,
    required this.auditSignoff,
  });
}
