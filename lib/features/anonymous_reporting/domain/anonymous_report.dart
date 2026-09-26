// lib/features/anonymous_reporting/domain/anonymous_report.dart
// Whistleblower report entity with cryptographic tracking token and zero identity linkage

import 'report_category.dart';

class AnonymousReport {
  final String id;
  final String trackingTokenHash;
  final ReportCategory category;
  final String reportTextEncrypted;
  final List<String> evidenceUrls;
  final String? unitIdentifierGeneral;
  final String status;
  final String? responseNotesEncrypted;
  final DateTime submittedAt;
  final DateTime updatedAt;

  const AnonymousReport({
    required this.id,
    required this.trackingTokenHash,
    required this.category,
    required this.reportTextEncrypted,
    this.evidenceUrls = const [],
    this.unitIdentifierGeneral,
    this.status = 'submitted',
    this.responseNotesEncrypted,
    required this.submittedAt,
    required this.updatedAt,
  });

  AnonymousReport copyWith({
    String? status,
    String? responseNotesEncrypted,
    DateTime? updatedAt,
  }) {
    return AnonymousReport(
      id: id,
      trackingTokenHash: trackingTokenHash,
      category: category,
      reportTextEncrypted: reportTextEncrypted,
      evidenceUrls: evidenceUrls,
      unitIdentifierGeneral: unitIdentifierGeneral,
      status: status ?? this.status,
      responseNotesEncrypted: responseNotesEncrypted ?? this.responseNotesEncrypted,
      submittedAt: submittedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tracking_token_hash': trackingTokenHash,
        'category': category.code,
        'report_text_encrypted': reportTextEncrypted,
        'evidence_urls': evidenceUrls,
        'unit_identifier_general': unitIdentifierGeneral,
        'status': status,
        'response_notes_encrypted': responseNotesEncrypted,
        'submitted_at': submittedAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory AnonymousReport.fromJson(Map<String, dynamic> json) {
    return AnonymousReport(
      id: json['id'] as String,
      trackingTokenHash: json['tracking_token_hash'] as String,
      category: ReportCategory.fromCode(json['category'] as String? ?? 'other_welfare_concern'),
      reportTextEncrypted: json['report_text_encrypted'] as String? ?? '',
      evidenceUrls: (json['evidence_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      unitIdentifierGeneral: json['unit_identifier_general'] as String?,
      status: json['status'] as String? ?? 'submitted',
      responseNotesEncrypted: json['response_notes_encrypted'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
