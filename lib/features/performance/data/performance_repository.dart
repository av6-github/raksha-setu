// lib/features/performance/data/performance_repository.dart
// Repository for non-clinical operational performance, commander updates, and ACR context notes

import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/acr_context_note.dart';
import '../domain/acr_firewall_validator.dart';
import '../domain/encouraging_feedback_engine.dart';
import '../domain/performance_record.dart';
import '../domain/progress_update.dart';

abstract class IPerformanceRepository {
  Future<List<PerformanceRecord>> getPerformanceRecords(String officerId);
  Future<PerformanceRecord?> getLatestPerformance(String officerId);
  Future<List<ProgressUpdate>> getProgressUpdates(String officerId);
  Future<ProgressUpdate> createProgressUpdate(ProgressUpdate update);
  Future<List<AcrContextNote>> getAcrContextNotes(String officerId);
  Future<AcrContextNote> createAcrContextNote(AcrContextNote note);
  Future<String> getEncouragingFeedback(PerformanceRecord record);
  List<FeedbackGenerationLog> getFeedbackLogs(String officerId);
}

class PerformanceRepository implements IPerformanceRepository {
  final SupabaseClient? client;

  // In-memory mock records for offline and prototype operation
  final List<PerformanceRecord> _mockRecords = [
    PerformanceRecord(
      id: 'perf-001',
      officerId: 'mock-officer-uuid-001',
      periodStart: DateTime.now().subtract(const Duration(days: 90)),
      periodEnd: DateTime.now().subtract(const Duration(days: 1)),
      overallPerformanceScore: 86.5,
      evaluatedAreas: {
        'Weapon Handling & Drill': 92.0,
        'Tactical Terrain Navigation': 88.0,
        'Physical Conditioning & Endurance': 78.0,
        'Squad Communication & Teamwork': 89.0,
      },
      improvementSuggestions: 'Focus on progressive aerobic intervals to enhance steep-ridge endurance.',
      evaluatedByIdentityId: 'eval-identity-commander-01',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final List<ProgressUpdate> _mockProgressUpdates = [
    ProgressUpdate(
      id: 'prog-001',
      officerId: 'mock-officer-uuid-001',
      statusIndicator: 'improving',
      publicContextNote: 'Demonstrating solid operational focus and active leadership during platoon routine.',
      acrSynced: true,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  final List<AcrContextNote> _mockAcrNotes = [
    AcrContextNote(
      id: 'acr-001',
      officerId: 'mock-officer-uuid-001',
      reportingPeriodYear: 2026,
      nonClinicalHrContext: 'Officer successfully completed High-Altitude Warfare conditioning without administrative lapses. Punctual and technically proficient in radio relay operations.',
      verifiedNoStressData: true,
      approvedByIdentityId: 'admin-hr-officer-01',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  final List<FeedbackGenerationLog> _feedbackLogs = [];

  PerformanceRepository({this.client});

  @override
  Future<List<PerformanceRecord>> getPerformanceRecords(String officerId) async {
    final c = client;
    if (c != null) {
      try {
        final res = await c
            .from('performance_records')
            .select()
            .eq('officer_id', officerId)
            .order('period_end', ascending: false);
        return (res as List).map((row) => PerformanceRecord.fromJson(row)).toList();
      } catch (_) {
        // Fallback to mock
      }
    }
    return _mockRecords.where((r) => r.officerId == officerId).toList();
  }

  @override
  Future<PerformanceRecord?> getLatestPerformance(String officerId) async {
    final list = await getPerformanceRecords(officerId);
    return list.isNotEmpty ? list.first : null;
  }

  @override
  Future<List<ProgressUpdate>> getProgressUpdates(String officerId) async {
    final c = client;
    if (c != null) {
      try {
        final res = await c
            .from('progress_updates')
            .select()
            .eq('officer_id', officerId)
            .order('created_at', ascending: false);
        return (res as List).map((row) => ProgressUpdate.fromJson(row)).toList();
      } catch (_) {
        // Fallback
      }
    }
    return _mockProgressUpdates.where((u) => u.officerId == officerId).toList();
  }

  @override
  Future<ProgressUpdate> createProgressUpdate(ProgressUpdate update) async {
    // Assert zero clinical leaks in public note
    if (update.publicContextNote != null) {
      AcrFirewallValidator.assertNoStressInAcrContext(update.publicContextNote!);
    }

    final c = client;
    if (c != null) {
      try {
        final res = await c.from('progress_updates').insert(update.toJson()).select().single();
        return ProgressUpdate.fromJson(res);
      } catch (_) {
        // Fallback
      }
    }
    _mockProgressUpdates.insert(0, update);
    return update;
  }

  @override
  Future<List<AcrContextNote>> getAcrContextNotes(String officerId) async {
    final c = client;
    if (c != null) {
      try {
        final res = await c
            .from('acr_context_notes')
            .select()
            .eq('officer_id', officerId)
            .order('created_at', ascending: false);
        return (res as List).map((row) => AcrContextNote.fromJson(row)).toList();
      } catch (_) {
        // Fallback
      }
    }
    return _mockAcrNotes.where((n) => n.officerId == officerId).toList();
  }

  @override
  Future<AcrContextNote> createAcrContextNote(AcrContextNote note) async {
    // 1. Strict Welfare-HR Firewall: Assert no stress, counselling, or psychometric data
    AcrFirewallValidator.assertNoStressInAcrContext(note.nonClinicalHrContext);

    final c = client;
    if (c != null) {
      try {
        final res = await c.from('acr_context_notes').insert(note.toJson()).select().single();
        return AcrContextNote.fromJson(res);
      } catch (_) {
        // Fallback
      }
    }
    _mockAcrNotes.insert(0, note);
    return note;
  }

  @override
  Future<String> getEncouragingFeedback(PerformanceRecord record) async {
    // Check sensitive topic triggers first
    final routingCheck = EncouragingFeedbackEngine.checkSensitiveTopicRouting(
      record.improvementSuggestions ?? '',
    );
    if (routingCheck.requiresEmergencyRouting) {
      return 'Sensitive topic detected. Please connect immediately with the Regimental Medical Officer or 24x7 Tele-MANAS (14416).';
    }

    final feedback = EncouragingFeedbackEngine.generateFeedbackFromRecord(record);

    _feedbackLogs.add(
      FeedbackGenerationLog(
        id: 'log-${DateTime.now().millisecondsSinceEpoch}',
        officerId: record.officerId,
        promptTemplate: 'Operational Developmental Template v1',
        generatedFeedback: feedback,
        passedMedicalFilter: true,
        timestamp: DateTime.now(),
      ),
    );

    return feedback;
  }

  @override
  List<FeedbackGenerationLog> getFeedbackLogs(String officerId) {
    return _feedbackLogs.where((l) => l.officerId == officerId).toList();
  }
}
