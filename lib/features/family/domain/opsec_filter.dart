// lib/features/family/domain/opsec_filter.dart
// Automated Operational Security (OPSEC) filter for Morale Vault voice and video uploads

import 'morale_vault_item.dart';

class OpsecScanResult {
  final bool isSafe;
  final List<String> detectedFlags;
  final double riskScore; // 0.0 (clean) to 1.0 (high risk OPSEC breach)
  final MoraleMediaSecurityStatus recommendedStatus;

  const OpsecScanResult({
    required this.isSafe,
    required this.detectedFlags,
    required this.riskScore,
    required this.recommendedStatus,
  });
}

class OpsecFilter {
  // 1. Tactical Operational Terminology
  static const List<String> _tacticalTerms = [
    'patrol',
    'convoy',
    'forward post',
    'ammunition dump',
    'kote',
    'night ambush',
    'reconnaissance',
    'sentry watch',
    'battalion order',
    'mortar',
    'counter-insurgency op',
    'line of control',
    'lac',
    'loc',
    'weapon cache',
  ];

  // 2. Sensitive Forward Location Indicators
  static const List<String> _locationClues = [
    'forward picket',
    'outpost delta',
    'sector 4',
    'charlie ridge',
    'grid ref',
    'base camp 3',
    'border observation post',
    'bop',
  ];

  // 3. GPS Coordinate Regex
  static final RegExp _gpsPattern = RegExp(
    r"(\b\d{1,2}[°\s]\s*\d{1,2}['\s]\s*[NnSsEeWw]\b)|(\blat(itude)?\s*[:=]\s*\d{2}\.)",
    caseSensitive: false,
  );

  /// Evaluates caption, voice transcript, or metadata for operational security breaches.
  static OpsecScanResult scan({
    required String text,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    final lowerText = text.toLowerCase();
    final flags = <String>[];
    double riskAccumulator = 0.0;

    // A. Tactical keywords
    for (final term in _tacticalTerms) {
      if (lowerText.contains(term)) {
        flags.add('tactical_reference: $term');
        riskAccumulator += 0.35;
      }
    }

    // B. Location clues
    for (final clue in _locationClues) {
      if (lowerText.contains(clue)) {
        flags.add('location_leak: $clue');
        riskAccumulator += 0.45;
      }
    }

    // C. GPS patterns
    if (_gpsPattern.hasMatch(text)) {
      flags.add('gps_coordinates_detected');
      riskAccumulator += 0.60;
    }

    // D. Metadata checks (e.g. embedded EXIF GPS)
    if (metadata != null && (metadata.containsKey('gps') || metadata.containsKey('latitude'))) {
      flags.add('exif_geotag_leak');
      riskAccumulator += 0.50;
    }

    final totalRisk = riskAccumulator.clamp(0.0, 1.0);
    final isClean = flags.isEmpty;

    return OpsecScanResult(
      isSafe: isClean,
      detectedFlags: flags,
      riskScore: totalRisk,
      recommendedStatus: isClean
          ? MoraleMediaSecurityStatus.safe
          : MoraleMediaSecurityStatus.autoFlagged,
    );
  }
}
