import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/core/networking/network_client.dart';
import 'package:raksha_welfare/core/storage/offline_queue_item.dart';
import 'package:raksha_welfare/core/storage/offline_queue_service.dart';
import 'package:raksha_welfare/features/biometrics/data/biometric_repository.dart';
import 'package:raksha_welfare/features/biometrics/domain/biometric_model.dart';
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
  group('Phase 3 — Biometrics Privacy & Consent Enforcement Tests', () {
    const testOfficerId = 'officer-bio-test';
    late ConsentRepository consentRepo;
    late BiometricRepository bioRepo;
    late BiometricsViewModel viewModel;

    setUp(() {
      consentRepo = ConsentRepository(client: null);
      bioRepo = BiometricRepository(
        client: null,
        offlineQueue: MockOfflineQueueService(),
        networkInfo: MockNetworkInfo(),
        consentRepository: consentRepo,
      );
      viewModel = BiometricsViewModel(
        repository: bioRepo,
        consentRepository: consentRepo,
        officerId: testOfficerId,
      );
    });

    test('Biometric sync is gated by consent — throws Exception if consent not granted', () async {
      // By default biometrics consent is false
      final model = BiometricModel(
        officerId: testOfficerId,
        recordedDate: DateTime.now(),
        sleepHours: 7.2,
        hrvRmssd: 50.0,
      );

      expect(
        () async => await bioRepo.recordBiometrics(model),
        throwsA(isA<Exception>()),
      );
    });

    test('Granting consent allows biometric sync and populates telemetry', () async {
      await viewModel.loadData();
      expect(viewModel.isConsentGranted, isFalse);

      // Grant consent and sync
      await viewModel.grantConsentAndSync();

      expect(viewModel.isConsentGranted, isTrue);
      expect(viewModel.history.isNotEmpty, isTrue);
      expect(viewModel.latest?.sleepHours, isNotNull);
    });

    test('Revoking consent purges all biometric records immediately', () async {
      // Grant consent first
      await viewModel.grantConsentAndSync();
      expect(viewModel.history.isNotEmpty, isTrue);

      // Revoke and purge
      await viewModel.revokeConsentAndPurge();

      expect(viewModel.isConsentGranted, isFalse);
      expect(viewModel.history.isEmpty, isTrue);
    });
  });
}
