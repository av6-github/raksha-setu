// lib/features/welfare_rag/domain/rag_retrieval_result.dart
// Grounded RAG retrieval result with source citations and confidence metrics

class SourceCitation {
  final String schemeName;
  final String issuingAuthority;
  final String? officialReference;
  final String? url;
  final String excerpt;

  const SourceCitation({
    required this.schemeName,
    required this.issuingAuthority,
    this.officialReference,
    this.url,
    required this.excerpt,
  });

  Map<String, dynamic> toJson() => {
        'scheme_name': schemeName,
        'issuing_authority': issuingAuthority,
        'official_reference': officialReference,
        'url': url,
        'excerpt': excerpt,
      };

  factory SourceCitation.fromJson(Map<String, dynamic> json) {
    return SourceCitation(
      schemeName: json['scheme_name'] as String,
      issuingAuthority: json['issuing_authority'] as String,
      officialReference: json['official_reference'] as String?,
      url: json['url'] as String?,
      excerpt: json['excerpt'] as String,
    );
  }
}

class RagRetrievalResult {
  final String query;
  final String answer;
  final double confidenceScore;
  final bool isLowConfidence;
  final List<SourceCitation> sourceCitations;
  final String detectedLanguage; // 'en' or 'hi'

  const RagRetrievalResult({
    required this.query,
    required this.answer,
    required this.confidenceScore,
    required this.isLowConfidence,
    required this.sourceCitations,
    this.detectedLanguage = 'en',
  });

  static const double confidenceThreshold = 0.60;

  static const String lowConfidenceFallbackEn =
      'I cannot confirm this entitlement with high confidence from current official MHA/WARB documents. '
      'To prevent misinformation, please verify directly with your Unit Welfare Officer or the official welfare portal (mha.gov.in / warb.gov.in).';

  static const String lowConfidenceFallbackHi =
      'वर्तमान आधिकारिक गृह मंत्रालय (MHA)/WARB दस्तावेजों से इस पात्रता की पुष्टि उच्च सटीकता के साथ नहीं की जा सकती है। '
      'सटीक जानकारी के लिए कृपया अपने यूनिट कल्याण अधिकारी या आधिकारिक पोर्टल (mha.gov.in / warb.gov.in) से संपर्क करें।';
}
