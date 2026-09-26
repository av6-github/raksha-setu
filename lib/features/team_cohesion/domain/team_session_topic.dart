// lib/features/team_cohesion/domain/team_session_topic.dart
// Pre-approved psychoeducational and cohesion topics for unit sessions

enum TeamSessionTopic {
  sleepHygiene,
  financialResilience,
  familyStress,
  operationalDecompression,
  physicalRecovery,
  peerSupportSkills;

  String get displayName {
    switch (this) {
      case TeamSessionTopic.sleepHygiene:
        return 'Tactical Sleep Hygiene & Circadian Recovery';
      case TeamSessionTopic.financialResilience:
        return 'Financial Planning & Pay/Pension Awareness';
      case TeamSessionTopic.familyStress:
        return 'Navigating Family Separation & Long Deployments';
      case TeamSessionTopic.operationalDecompression:
        return 'Post-Patrol Operational Decompression';
      case TeamSessionTopic.physicalRecovery:
        return 'Physical Conditioning & High-Altitude Acclimatization';
      case TeamSessionTopic.peerSupportSkills:
        return 'Buddy-Pair Support & Squad Cohesion Skills';
    }
  }

  String get description {
    switch (this) {
      case TeamSessionTopic.sleepHygiene:
        return 'Techniques for quality sleep in barracks, tactical sleep banking, and non-stimulant sleep onset routines.';
      case TeamSessionTopic.financialResilience:
        return 'Prudent financial management, military savings schemes, insurance, and retirement planning.';
      case TeamSessionTopic.familyStress:
        return 'Communication strategies during field duty, maintaining family bonds, and managing household worries.';
      case TeamSessionTopic.operationalDecompression:
        return 'Structured squad debriefs to release adrenaline and tension after continuous counter-insurgency patrols.';
      case TeamSessionTopic.physicalRecovery:
        return 'Nutrition, hydration, injury prevention, and tactical breathing for strenuous physical readiness.';
      case TeamSessionTopic.peerSupportSkills:
        return 'Practical steps for squad members to listen, look out for buddy pairs, and normalize mutual help.';
    }
  }
}
