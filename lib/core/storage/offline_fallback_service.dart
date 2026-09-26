// lib/core/storage/offline_fallback_service.dart
// SMS check-in payload generator and Interactive Voice Response (IVR) helpline fallback

class OfflineFallbackService {
  static const String designatedSmsGateway = '+91-11-2309-RAKSHA'; // Secure MHA SMS Gateway
  static const String teleManasTollFree = '14416'; // National Tele-MANAS 24x7
  static const String capfSupportHelpline = '1800-11-7257';

  /// Generates a structured SMS check-in message when 4G/5G/Wi-Fi is entirely unavailable
  /// Format: `RAKSHA CHK <ID_TOKEN> <PHQ2> <GAD2> <SLEEP_HRS> <WORKLOAD_SCORE>`
  static String generateSmsCheckInPayload({
    required String officerToken,
    required int phq2Score,
    required int gad2Score,
    required double sleepHours,
    required int workloadScore,
  }) {
    final sanitizedToken = officerToken.trim().replaceAll(' ', '');
    return 'RAKSHA CHK $sanitizedToken $phq2Score $gad2Score ${sleepHours.toStringAsFixed(1)} $workloadScore';
  }

  /// Parses an incoming/stored SMS payload to extract check-in values
  static Map<String, dynamic>? parseSmsCheckInPayload(String message) {
    final parts = message.trim().split(RegExp(r'\s+'));
    if (parts.length != 7 || parts[0] != 'RAKSHA' || parts[1] != 'CHK') {
      return null;
    }

    try {
      return {
        'token': parts[2],
        'phq2_score': int.parse(parts[3]),
        'gad2_score': int.parse(parts[4]),
        'sleep_hours': double.parse(parts[5]),
        'workload_score': int.parse(parts[6]),
      };
    } catch (_) {
      return null;
    }
  }

  /// Returns IVR routing instructions for frontline personnel in zero-data sectors
  static Map<String, String> getIvrRoutingInstructions() {
    return {
      'tele_manas': teleManasTollFree,
      'capf_welfare_helpline': capfSupportHelpline,
      'instruction': 'Dial 14416 from any basic GSM handset. Press 1 for Hindi, 2 for English. Dedicated to uniform personnel.',
    };
  }
}
