import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/core/networking/network_client.dart';
import 'package:raksha_welfare/core/storage/offline_queue_item.dart';
import 'package:raksha_welfare/core/storage/offline_queue_service.dart';
import 'package:raksha_welfare/features/assessments/data/assessment_repository.dart';
import 'package:raksha_welfare/features/assessments/presentation/assessment_screen.dart';
import 'package:raksha_welfare/features/assessments/presentation/assessment_view_model.dart';
import 'package:raksha_welfare/features/biometrics/data/biometric_repository.dart';
import 'package:raksha_welfare/features/biometrics/presentation/biometrics_screen.dart';
import 'package:raksha_welfare/features/biometrics/presentation/biometrics_view_model.dart';
import 'package:raksha_welfare/features/consent/data/consent_repository.dart';

class MockNetworkInfo implements INetworkInfo {
  @override
  Future<bool> get isConnected async => true;
  @override
  Stream<bool> get onConnectivityChanged => Stream.value(true);
}

class MockOfflineQueueService implements IOfflineQueueService {
  @override
  Future<OfflineQueueItem> enqueue(String endpoint, Map<String, dynamic> payload) async {
    return OfflineQueueItem(
      id: 'mock-id',
      endpoint: endpoint,
      payload: payload,
      idempotencyKey: 'mock-key',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<OfflineQueueItem>> getPendingItems() async => [];
  @override
  Future<void> markInFlight(String id) async {}
  @override
  Future<void> markSynced(String id) async {}
  @override
  Future<void> markFailed(String id, String error) async {}
  @override
  Future<void> clear() async {}
  @override
  int get queueLength => 0;
}


void main() {
  const testOfficerId = 'officer-test-w3';

  testWidgets('AssessmentScreen renders instrument selection and starts PHQ-9', (WidgetTester tester) async {
    final repo = AssessmentRepository(
      client: null,
      offlineQueue: MockOfflineQueueService(),
      networkInfo: MockNetworkInfo(),
    );
    final vm = AssessmentViewModel(repository: repo, officerId: testOfficerId);

    await tester.pumpWidget(
      MaterialApp(
        home: AssessmentScreen(viewModel: vm),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Validated Psychological Instruments'), findsOneWidget);
    expect(find.text('PHQ-9 Depression Inventory'), findsOneWidget);
    expect(find.text('GAD-7 Anxiety Scale'), findsOneWidget);

    // Tap to start PHQ-9
    await tester.tap(find.text('PHQ-9 Depression Inventory'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1 of 9'), findsOneWidget);
    expect(find.text('Little interest or pleasure in doing things'), findsOneWidget);
  });

  testWidgets('BiometricsScreen renders consent warning when not granted', (WidgetTester tester) async {
    final consentRepo = ConsentRepository(client: null);
    final bioRepo = BiometricRepository(
      client: null,
      offlineQueue: MockOfflineQueueService(),
      networkInfo: MockNetworkInfo(),
      consentRepository: consentRepo,
    );
    final vm = BiometricsViewModel(
      repository: bioRepo,
      consentRepository: consentRepo,
      officerId: testOfficerId,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BiometricsScreen(viewModel: vm),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wearable Biometrics Telemetry'), findsOneWidget);
    expect(find.text('Biometric Sync Disabled'), findsOneWidget);
    expect(find.text('Authorize Biometric Telemetry (Opt-In)'), findsOneWidget);
  });
}
