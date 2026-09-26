// lib/features/anonymous_reporting/data/anonymous_report_repository.dart
// Independent Vigilance/Whistleblower pipeline repository with cryptographic token separation

import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/anonymity_engine.dart';
import '../domain/anonymous_report.dart';
import '../domain/report_category.dart';

abstract class IAnonymousReportRepository {
  /// Submits an anonymous report and returns the plaintext tracking token for the whistleblower
  Future<String> submitReport({
    required ReportCategory category,
    required String reportText,
    String? unitIdentifierGeneral,
    List<String> evidenceUrls,
    Map<String, dynamic>? extraMetadata,
  });

  /// Retrieves an existing report status using the whistleblower's plaintext tracking token
  Future<AnonymousReport?> trackReport(String plaintextToken);

  /// Retrieves all reports for the isolated Vigilance & Ethics Cell
  Future<List<AnonymousReport>> getVigilancePipelineReports();

  /// Updates report investigation status and adds response notes for the whistleblower
  Future<AnonymousReport> updateReportStatus({
    required String reportId,
    required String status,
    String? responseNotes,
  });
}

class AnonymousReportRepository implements IAnonymousReportRepository {
  final SupabaseClient? client;

  // In-memory fallback mock repository
  final List<AnonymousReport> _mockReports = [
    AnonymousReport(
      id: 'rep-mock-001',
      trackingTokenHash: AnonymityEngine.hashTrackingToken('TK-DEMO-SAFE-0001'),
      category: ReportCategory.unsafeConditions,
      reportTextEncrypted: 'Extreme cold clothing and sub-zero mittens are torn and deficient at the high altitude ridge post.',
      evidenceUrls: [],
      unitIdentifierGeneral: '14 Rajputana Rifles (Sector North)',
      status: 'under_review',
      responseNotesEncrypted: 'Vigilance Cell has logged this with Directorate of Ordnance and Logistics. Winter gear replenishment scheduled.',
      submittedAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  AnonymousReportRepository({this.client});

  @override
  Future<String> submitReport({
    required ReportCategory category,
    required String reportText,
    String? unitIdentifierGeneral,
    List<String> evidenceUrls = const [],
    Map<String, dynamic>? extraMetadata,
  }) async {
    // 1. Technical Identity Protection: Assert zero identity leaks in metadata
    if (extraMetadata != null) {
      AnonymityEngine.assertZeroIdentityLeak(extraMetadata);
    }

    // 2. Location sanitization: Reject granular platoons/pickets/bunkers
    final sanitizedUnit = AnonymityEngine.sanitizeUnitIdentifier(unitIdentifierGeneral);

    // 3. Cryptographic Token Generation
    final plaintextToken = AnonymityEngine.generateTrackingToken();
    final tokenHash = AnonymityEngine.hashTrackingToken(plaintextToken);

    final newReport = AnonymousReport(
      id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
      trackingTokenHash: tokenHash,
      category: category,
      reportTextEncrypted: reportText,
      evidenceUrls: evidenceUrls,
      unitIdentifierGeneral: sanitizedUnit,
      status: 'submitted',
      submittedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final c = client;
    if (c != null) {
      try {
        await c.from('anonymous_reports').insert(newReport.toJson());
        return plaintextToken;
      } catch (_) {
        // Fallback to mock
      }
    }

    _mockReports.add(newReport);
    return plaintextToken;
  }

  @override
  Future<AnonymousReport?> trackReport(String plaintextToken) async {
    final tokenHash = AnonymityEngine.hashTrackingToken(plaintextToken);

    final c = client;
    if (c != null) {
      try {
        final res = await c
            .from('anonymous_reports')
            .select()
            .eq('tracking_token_hash', tokenHash)
            .maybeSingle();
        if (res != null) {
          return AnonymousReport.fromJson(res);
        }
      } catch (_) {
        // Fallback to mock
      }
    }

    try {
      return _mockReports.firstWhere((r) => r.trackingTokenHash == tokenHash);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<AnonymousReport>> getVigilancePipelineReports() async {
    final c = client;
    if (c != null) {
      try {
        final res = await c
            .from('anonymous_reports')
            .select()
            .order('submitted_at', ascending: false);
        return (res as List).map((row) => AnonymousReport.fromJson(row)).toList();
      } catch (_) {
        // Fallback to mock
      }
    }

    return List.unmodifiable(_mockReports);
  }

  @override
  Future<AnonymousReport> updateReportStatus({
    required String reportId,
    required String status,
    String? responseNotes,
  }) async {
    final c = client;
    if (c != null) {
      try {
        final updateData = <String, dynamic>{
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        };
        if (responseNotes != null) {
          updateData['response_notes_encrypted'] = responseNotes;
        }
        final res = await c
            .from('anonymous_reports')
            .update(updateData)
            .eq('id', reportId)
            .select()
            .single();
        return AnonymousReport.fromJson(res);
      } catch (_) {
        // Fallback to mock
      }
    }

    final index = _mockReports.indexWhere((r) => r.id == reportId);
    if (index == -1) {
      throw StateError('Report with id "$reportId" not found in vigilance repository.');
    }

    final updated = _mockReports[index].copyWith(
      status: status,
      responseNotesEncrypted: responseNotes,
      updatedAt: DateTime.now(),
    );
    _mockReports[index] = updated;
    return updated;
  }
}
