// lib/features/assessments/data/assessment_repository.dart
// Assessment repository with crisis event interception and offline queue fallback

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../core/logging/app_logger.dart';
import '../../../core/networking/network_client.dart';
import '../../../core/storage/offline_queue_service.dart';
import '../domain/assessment_model.dart';
import '../domain/stressor_model.dart';

abstract class IAssessmentRepository {
  Future<AssessmentModel> submitAssessment(AssessmentModel assessment);
  Future<List<AssessmentModel>> getRecentAssessments(String officerId, {int limit = 5});
  Future<StressorModel> reportStressor(StressorModel stressor);
  Future<List<StressorModel>> getActiveStressors(String officerId);
}

class AssessmentRepository implements IAssessmentRepository {
  final sp.SupabaseClient? client;
  final IOfflineQueueService offlineQueue;
  final INetworkInfo networkInfo;
  final List<AssessmentModel> _localAssessments = [];
  final List<StressorModel> _localStressors = [];

  AssessmentRepository({
    this.client,
    required this.offlineQueue,
    required this.networkInfo,
  });

  @override
  Future<AssessmentModel> submitAssessment(AssessmentModel assessment) async {
    final isOnline = await networkInfo.isConnected;

    if (assessment.isCrisisFlagged) {
      AppLogger.warning('CRISIS PROTOCOL TRIGGERED — PHQ-9 Item 9 flagged [score: ${assessment.phq9Item9Score}]');
    }

    if (!isOnline || client == null) {
      // Queue offline
      await offlineQueue.enqueue('assessments', assessment.toDbPayload());
      _localAssessments.insert(0, assessment);
      AppLogger.info('Assessment queued for offline sync', data: {
        'type': assessment.assessmentType,
        'score': assessment.totalScore,
        'tier': assessment.severityTier,
      });
      return assessment;
    }

    try {
      final res = await client!
          .from('assessments')
          .insert(assessment.toDbPayload())
          .select()
          .single();

      final createdId = res['id'] as String;

      // Insert granular responses for clinical review
      if (assessment.responses.isNotEmpty) {
        final responsesPayload = assessment.responses.map((r) => {
          ...r.toMap(),
          'assessment_id': createdId,
        }).toList();

        await client!.from('assessment_responses').insert(responsesPayload);
      }

      final saved = AssessmentModel.fromMap(res, assessment.responses);
      _localAssessments.insert(0, saved);
      return saved;
    } catch (e, st) {
      AppLogger.error('Failed to submit assessment to Supabase; queueing offline', error: e, stackTrace: st);
      await offlineQueue.enqueue('assessments', assessment.toDbPayload());
      _localAssessments.insert(0, assessment);
      return assessment;
    }
  }

  @override
  Future<List<AssessmentModel>> getRecentAssessments(String officerId, {int limit = 5}) async {
    if (client == null) {
      return _localAssessments.where((a) => a.officerId == officerId).take(limit).toList();
    }

    try {
      final res = await client!
          .from('assessments')
          .select()
          .eq('officer_id', officerId)
          .order('completed_at', ascending: false)
          .limit(limit);

      return (res as List).map((m) => AssessmentModel.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.warning('Failed to fetch assessments from Supabase', error: e);
      return _localAssessments.where((a) => a.officerId == officerId).take(limit).toList();
    }
  }

  @override
  Future<StressorModel> reportStressor(StressorModel stressor) async {
    final isOnline = await networkInfo.isConnected;

    if (!isOnline || client == null) {
      await offlineQueue.enqueue('stressors', stressor.toDbPayload());
      _localStressors.add(stressor);
      return stressor;
    }

    try {
      final res = await client!
          .from('stressors')
          .insert(stressor.toDbPayload())
          .select()
          .single();
      final saved = StressorModel.fromMap(res);
      _localStressors.add(saved);
      return saved;
    } catch (e) {
      await offlineQueue.enqueue('stressors', stressor.toDbPayload());
      _localStressors.add(stressor);
      return stressor;
    }
  }

  @override
  Future<List<StressorModel>> getActiveStressors(String officerId) async {
    if (client == null) {
      return _localStressors.where((s) => s.officerId == officerId && s.isActive).toList();
    }

    try {
      final res = await client!
          .from('stressors')
          .select()
          .eq('officer_id', officerId)
          .eq('is_active', true)
          .order('reported_at', ascending: false);

      return (res as List).map((m) => StressorModel.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      return _localStressors.where((s) => s.officerId == officerId && s.isActive).toList();
    }
  }
}
