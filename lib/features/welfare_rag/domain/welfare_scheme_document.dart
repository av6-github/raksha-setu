// lib/features/welfare_rag/domain/welfare_scheme_document.dart
// Authoritative welfare policy and scheme metadata

class WelfareSchemeDocument {
  final String id;
  final String schemeName;
  final String issuingAuthority;
  final String? officialReferenceNumber;
  final String? documentUrl;
  final String language;
  final String? documentVersion;
  final DateTime? effectiveDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WelfareSchemeDocument({
    required this.id,
    required this.schemeName,
    required this.issuingAuthority,
    this.officialReferenceNumber,
    this.documentUrl,
    this.language = 'en',
    this.documentVersion,
    this.effectiveDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'scheme_name': schemeName,
        'issuing_authority': issuingAuthority,
        'official_reference_number': officialReferenceNumber,
        'document_url': documentUrl,
        'language': language,
        'document_version': documentVersion,
        'effective_date': effectiveDate?.toIso8601String().split('T').first,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory WelfareSchemeDocument.fromJson(Map<String, dynamic> json) {
    return WelfareSchemeDocument(
      id: json['id'] as String,
      schemeName: json['scheme_name'] as String,
      issuingAuthority: json['issuing_authority'] as String,
      officialReferenceNumber: json['official_reference_number'] as String?,
      documentUrl: json['document_url'] as String?,
      language: json['language'] as String? ?? 'en',
      documentVersion: json['document_version'] as String?,
      effectiveDate: json['effective_date'] != null
          ? DateTime.tryParse(json['effective_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
