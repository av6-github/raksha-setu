import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/core/networking/network_client.dart';
import 'package:raksha_welfare/core/storage/offline_queue_item.dart';
import 'package:raksha_welfare/core/storage/offline_queue_service.dart';
import 'package:raksha_welfare/features/assessments/data/assessment_repository.dart';
import 'package:raksha_welfare/features/assessments/domain/assessment_model.dart';
import 'package:raksha_welfare/features/assessments/presentation/assessment_view_model.dart';

class MockNetworkInfo implements INetworkInfo {
  bool connected = true;
  @override
  Future<bool> get isConnected async => connected;
  @override
  Stream<bool> get onConnectivityChanged => Stream.value(connected);
}

class MockOfflineQueueService implements IOfflineQueueService {
  final List<OfflineQueueItem> queued = [];

  @override
  Future<OfflineQueueItem> enqueue(String endpoint, Map<String, dynamic> payload) async {
    final item = OfflineQueueItem(
      id: 'mock-${queued.length}',
      endpoint: endpoint,
      payload: payload,
      idempotencyKey: 'idemp-${queued.length}',
      createdAt: DateTime.now(),
    );
    queued.add(item);
    return item;
  }

  @override
  Future<List<OfflineQueueItem>> getPendingItems() async => queued;
  @override
  Future<void> markInFlight(String id) async {}
  @override
  Future<void> markSynced(String id) async => queued.removeWhere((i) => i.id == id);
  @override
  Future<void> markFailed(String id, String error) async {}
  @override
  Future<void> clear() async => queued.clear();
  @override
  int get queueLength => queued.length;
}

void main() {
  group('Phase 3 — Assessment Scoring & Safety Protocol Tests', () {
    const testOfficerId = 'officer-test-phase3';
    late MockNetworkInfo mockNetwork;
    late MockOfflineQueueService mockQueue;
    late AssessmentRepository repository;
    late AssessmentViewModel viewModel;

    setUp(() {
      mockNetwork = MockNetworkInfo();
      mockQueue = MockOfflineQueueService();
      repository = AssessmentRepository(
        client: null,
        offlineQueue: mockQueue,
        networkInfo: mockNetwork,
      );
      viewModel = AssessmentViewModel(
        repository: repository,
        officerId: testOfficerId,
      );
    });

    test('PHQ-9 Scoring — Normal score (< 5)', () {
      final answers = {for (var i = 1; i <= 9; i++) 'PHQ9_Q$i': 0};
      final scored = AssessmentModel.scorePhq9(
        officerId: testOfficerId,
        triggerReason: 'quarterly_routine',
        answers: answers,
      );

      expect(scored.totalScore, 0.0);
      expect(scored.severityTier, 'normal');
      expect(scored.isCrisisFlagged, isFalse);
    });

    test('PHQ-9 Scoring — Moderate score (10–14)', () {
      final answers = {
        'PHQ9_Q1': 2,
        'PHQ9_Q2': 2,
        'PHQ9_Q3': 2,
        'PHQ9_Q4': 2,
        'PHQ9_Q5': 2,
        'PHQ9_Q6': 1,
        'PHQ9_Q7': 1,
        'PHQ9_Q8': 0,
        'PHQ9_Q9': 0, // No crisis
      };
      final scored = AssessmentModel.scorePhq9(
        officerId: testOfficerId,
        triggerReason: 'quarterly_routine',
        answers: answers,
      );

      expect(scored.totalScore, 12.0);
      expect(scored.severityTier, 'moderate');
      expect(scored.isCrisisFlagged, isFalse);
    });

    test('SAFETY PROTOCOL: PHQ-9 Item 9 > 0 immediately flags crisis', () {
      final answers = {
        'PHQ9_Q1': 1,
        'PHQ9_Q2': 1,
        'PHQ9_Q3': 0,
        'PHQ9_Q4': 0,
        'PHQ9_Q5': 0,
        'PHQ9_Q6': 0,
        'PHQ9_Q7': 0,
        'PHQ9_Q8': 0,
        'PHQ9_Q9': 1, // Thoughts of self-harm
      };
      final scored = AssessmentModel.scorePhq9(
        officerId: testOfficerId,
        triggerReason: 'quarterly_routine',
        answers: answers,
      );

      expect(scored.isCrisisFlagged, isTrue);
      expect(scored.severityTier, 'crisis');
      expect(scored.phq9Item9Score, 1);
    });

    test('AssessmentViewModel Item 9 safety intercept step transition', () {
      viewModel.startAssessment('phq9');

      // Answer first 8 questions with 0
      for (int i = 0; i < 8; i++) {
        viewModel.answerQuestion(0);
        expect(viewModel.isCrisisTriggered, isFalse);
      }

      // Answering Q9 (Item 9) with positive score triggers crisis intercept
      viewModel.answerQuestion(2);

      expect(viewModel.isCrisisTriggered, isTrue);
      expect(viewModel.step, AssessmentWizardStep.crisisIntercept);
    });

    test('GAD-7 Scoring — Severe Anxiety (>= 15)', () {
      final answers = {for (var i = 1; i <= 7; i++) 'GAD7_Q$i': 3};
      final scored = AssessmentModel.scoreGad7(
        officerId: testOfficerId,
        triggerReason: 'quarterly_routine',
        answers: answers,
      );

      expect(scored.totalScore, 21.0);
      expect(scored.severityTier, 'severe');
    });

    test('Offline Assessment Submission enqueues to OfflineQueueService', () async {
      mockNetwork.connected = false;

      final assessment = AssessmentModel(
        officerId: testOfficerId,
        assessmentType: 'phq9',
        triggerReason: 'quarterly_routine',
        totalScore: 8.0,
        severityTier: 'mild',
        completedAt: DateTime.now(),
      );

      await repository.submitAssessment(assessment);

      expect(mockQueue.queueLength, 1);
      expect(mockQueue.queued.first.endpoint, 'assessments');
      expect(mockQueue.queued.first.payload['severity_tier'], 'mild');
    });
  });
}
