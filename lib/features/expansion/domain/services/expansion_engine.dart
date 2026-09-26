// lib/features/expansion/domain/services/expansion_engine.dart
// Expansion engine: Validates cross-sector plug-and-play adaptability and enforces universal Welfare-HR firewall integrity

import '../models/expansion_models.dart';

class SectorAdapterEngine {
  /// Asserts that any sector profile strictly enforces the non-negotiable Welfare-HR firewall
  static void assertUniversalFirewall(SectorProfile profile) {
    if (profile.firewallStatutoryRule.trim().isEmpty) {
      throw StateError(
        'Critical Policy Violation: Sector "${profile.title}" must define a legally binding statutory firewall rule.',
      );
    }

    final lower = profile.firewallStatutoryRule.toLowerCase();
    if (!lower.contains('acr') &&
        !lower.contains('service book') &&
        !lower.contains('appraisal') &&
        !lower.contains('disciplinary')) {
      throw StateError(
        'Firewall Inadequacy: Sector "${profile.title}" firewall rule must explicitly prohibit stress data from entering ACR, service book, appraisals, or disciplinary files.',
      );
    }
  }

  /// Validates structural integrity of a sector profile for plug-and-play deployment
  static bool validateSectorProfile(SectorProfile profile) {
    assertUniversalFirewall(profile);

    return profile.title.isNotEmpty &&
        profile.operationalStressors.length >= 3 &&
        profile.hierarchyRanks.length >= 3 &&
        profile.welfareSchemes.isNotEmpty &&
        profile.crisisHotline.isNotEmpty &&
        profile.readinessScore >= 80.0;
  }
}
