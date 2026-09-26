// lib/features/performance/domain/acr_firewall_validator.dart
// Strict Welfare-HR Firewall Enforcer: Blocks stress and clinical data from entering ACR records

class AcrFirewallViolationException implements Exception {
  final String message;
  const AcrFirewallViolationException(this.message);

  @override
  String toString() => 'AcrFirewallViolationException: $message';
}

class AcrFirewallValidator {
  static const Set<String> _prohibitedKeywords = {
    'stress',
    'distress',
    'depression',
    'depressed',
    'anxiety',
    'anxious',
    'phq',
    'phq-9',
    'phq-2',
    'gad',
    'gad-7',
    'gad-2',
    'cssrs',
    'c-ssrs',
    'suicide',
    'self-harm',
    'counselling',
    'counsellor',
    'counselor',
    'psychologist',
    'psychiatrist',
    'psychiatric',
    'psychotherapy',
    'therapy',
    'psych',
    'mental health',
    'burnout',
    'trauma',
    'ptsd',
    'break-glass',
    'vulnerability',
    'clinical',
    'stanley-brown',
  };

  /// Asserts that non-clinical HR context notes destined for ACR files are completely free
  /// of clinical, psychological, stress, and psychiatric records.
  static void assertNoStressInAcrContext(String note) {
    final lower = note.toLowerCase();
    for (final term in _prohibitedKeywords) {
      // Word boundary regex to avoid false positives on benign words
      final regex = RegExp(r'\b' + RegExp.escape(term) + r'\b', caseSensitive: false);
      if (regex.hasMatch(lower)) {
        throw AcrFirewallViolationException(
          'Welfare-HR Firewall Violation: ACR context note contains prohibited clinical/stress reference "$term". '
          'Under statutory welfare policies, clinical disclosures, counselling records, and stress scores '
          'must never enter Annual Confidential Reports (ACR) or influence promotions/postings.',
        );
      }
    }
  }

  /// Asserts that a performance record or data payload contains no clinical assessment scores
  static void assertNoClinicalScoreInAcr(Map<String, dynamic> data) {
    for (final key in data.keys) {
      final lowerKey = key.toLowerCase();
      for (final term in _prohibitedKeywords) {
        if (lowerKey.contains(term)) {
          throw AcrFirewallViolationException(
            'Welfare-HR Firewall Violation: Prohibited field "$key" cannot be synced to ACR or command HR systems.',
          );
        }
      }
    }
  }
}
