// test/unit/offline_hardening_test.dart
// Unit tests for Phase 17: Offline-First Hardening, Encrypted Local Storage, Idempotency, Retry, Conflict Resolution, On-Device Baseline & Fallbacks

import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/core/networking/network_client.dart';
import 'package:raksha_welfare/core/security/screen_security_service.dart';
import 'package:raksha_welfare/core/storage/conflict_resolver.dart';
import 'package:raksha_welfare/core/storage/encrypted_local_storage_service.dart';
import 'package:raksha_welfare/core/storage/offline_fallback_service.dart';
import 'package:raksha_welfare/core/storage/offline_queue_item.dart';
import 'package:raksha_welfare/core/storage/offline_queue_service.dart';
import 'package:raksha_welfare/core/storage/on_device_baseline_engine.dart';
import 'package:raksha_welfare/core/storage/sync_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeNetworkInfo implements INetworkInfo {
  bool isConnectedValue;
  FakeNetworkInfo({this.isConnectedValue = true});

  @override
  Future<bool> get isConnected async => isConnectedValue;

  @override
  Stream<bool> get onConnectivityChanged => Stream.value(isConnectedValue);
}

void main() {
  group('Phase 17: EncryptedLocalStorageService & Device Restart Test', () {
    late SharedPreferences prefs;
    late EncryptedLocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      storage = EncryptedLocalStorageService(prefs: prefs);
    });

    test('Writes encrypted key-value and raw SharedPreferences contains enc:v1 prefix', () async {
      await storage.writeEncrypted('secret_note', 'Tactical rest order');
      final decrypted = await storage.readEncrypted('secret_note');
      expect(decrypted, equals('Tactical rest order'));

      // Check raw SharedPreferences to prove it is NOT plaintext
      final rawStored = prefs.getString('raksha_enc_store_v1_secret_note');
      expect(rawStored, isNotNull);
      expect(rawStored!.startsWith('enc:v1:'), isTrue);
      expect(rawStored, isNot(contains('Tactical rest order')));
    });

    test('Saves, retrieves, updates, and deletes offline table records', () async {
      final checkIn1 = {
        'id': 'chk-001',
        'sleep_hours': 6.5,
        'workload_score': 10,
        'created_at': DateTime.now().toIso8601String(),
      };
      await storage.saveOfflineRecord('check_ins', 'chk-001', checkIn1);

      var records = await storage.getOfflineRecords('check_ins');
      expect(records.length, equals(1));
      expect(records.first['id'], equals('chk-001'));
      expect(records.first['sleep_hours'], equals(6.5));

      // Update existing record
      final checkIn1Updated = Map<String, dynamic>.from(checkIn1)..['sleep_hours'] = 7.0;
      await storage.saveOfflineRecord('check_ins', 'chk-001', checkIn1Updated);
      records = await storage.getOfflineRecords('check_ins');
      expect(records.length, equals(1));
      expect(records.first['sleep_hours'], equals(7.0));

      // Delete record
      await storage.deleteOfflineRecord('check_ins', 'chk-001');
      records = await storage.getOfflineRecords('check_ins');
      expect(records.isEmpty, isTrue);
    });

    test('Device restart simulation: data persists and decrypts across service instances', () async {
      await storage.writeEncrypted('restart_key', 'Persistent after app reboot');

      // Re-instantiate service simulating device restart
      final reloadedStorage = EncryptedLocalStorageService(prefs: prefs);
      final val = await reloadedStorage.readEncrypted('restart_key');
      expect(val, equals('Persistent after app reboot'));
    });
  });

  group('Phase 17: ConflictResolver Strategies', () {
    final clientRecord = {
      'id': 'rec-1',
      'phq_score': 8,
      'updated_at': '2026-10-01T10:00:00Z',
    };
    final serverRecord = {
      'id': 'rec-1',
      'phq_score': 5,
      'updated_at': '2026-10-01T12:00:00Z',
    };

    test('clientWins selects client record', () {
      final res = ConflictResolver.resolveConflict(
        clientRecord: clientRecord,
        serverRecord: serverRecord,
        strategy: ConflictResolutionStrategy.clientWins,
      );
      expect(res['phq_score'], equals(8));
    });

    test('serverWins selects server record', () {
      final res = ConflictResolver.resolveConflict(
        clientRecord: clientRecord,
        serverRecord: serverRecord,
        strategy: ConflictResolutionStrategy.serverWins,
      );
      expect(res['phq_score'], equals(5));
    });

    test('latestTimestampWins picks newer server record when server timestamp is later', () {
      final res = ConflictResolver.resolveConflict(
        clientRecord: clientRecord,
        serverRecord: serverRecord,
        strategy: ConflictResolutionStrategy.latestTimestampWins,
      );
      expect(res['phq_score'], equals(5));
    });

    test('defaultStrategyForEndpoint selects serverWins for rosters and clientWins for check-ins', () {
      expect(
        ConflictResolver.defaultStrategyForEndpoint('unit_rosters'),
        equals(ConflictResolutionStrategy.serverWins),
      );
      expect(
        ConflictResolver.defaultStrategyForEndpoint('check_ins'),
        equals(ConflictResolutionStrategy.clientWins),
      );
      expect(
        ConflictResolver.defaultStrategyForEndpoint('assessments'),
        equals(ConflictResolutionStrategy.clientWins),
      );
    });
  });

  group('Phase 17: SyncEngine Idempotency & Backoff', () {
    late SharedPreferences prefs;
    late OfflineQueueService queueService;
    late FakeNetworkInfo fakeNetwork;
    late SyncEngine syncEngine;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      queueService = OfflineQueueService(prefs: prefs);
      fakeNetwork = FakeNetworkInfo(isConnectedValue: true);
      syncEngine = SyncEngine(
        queueService: queueService,
        networkInfo: fakeNetwork,
      );
    });

    test('Calculates exponential backoff capped at 10 seconds', () {
      expect(syncEngine.calculateBackoff(0), equals(const Duration(milliseconds: 500)));
      expect(syncEngine.calculateBackoff(1), equals(const Duration(milliseconds: 1000)));
      expect(syncEngine.calculateBackoff(2), equals(const Duration(milliseconds: 2000)));
      expect(syncEngine.calculateBackoff(3), equals(const Duration(milliseconds: 4000)));
      expect(syncEngine.calculateBackoff(4), equals(const Duration(milliseconds: 8000)));
      expect(syncEngine.calculateBackoff(5), equals(const Duration(milliseconds: 10000)));
      expect(syncEngine.calculateBackoff(10), equals(const Duration(milliseconds: 10000)));
    });

    test('Guarantees idempotency: re-syncing processed item skips duplicate processing', () async {
      final item = await queueService.enqueue('check_ins', {'score': 2});
      expect(syncEngine.isIdempotent(item.idempotencyKey), isFalse);

      await syncEngine.syncPendingMutations();

      expect(syncEngine.isIdempotent(item.idempotencyKey), isTrue);
      expect(queueService.queueLength, equals(0));

      // Attempting to process same idempotency key again returns immediately without error
      final duplicateItem = OfflineQueueItem(
        id: 'dup-1',
        idempotencyKey: item.idempotencyKey,
        endpoint: 'check_ins',
        payload: {'score': 2},
        createdAt: DateTime.now(),
      );
      await queueService.enqueue(duplicateItem.endpoint, duplicateItem.payload);
      await syncEngine.syncPendingMutations();
      expect(syncEngine.isIdempotent(item.idempotencyKey), isTrue);
    });

    test('Handles airplane mode and skips queue sync when offline', () async {
      fakeNetwork.isConnectedValue = false;
      await queueService.enqueue('assessments', {'phq': 4});

      await syncEngine.syncPendingMutations();
      expect(queueService.queueLength, equals(1));
      expect(syncEngine.currentSyncState.status, equals(SyncStatus.offlineWithPending));
    });
  });

  group('Phase 17: OnDeviceBaselineEngine Offline CUSUM Alerts', () {
    test('Computes normal baseline when no significant shift occurs', () {
      final stableCheckIns = [
        {'sleep_hours': 7.0, 'workload_score': 8},
        {'sleep_hours': 7.2, 'workload_score': 8},
        {'sleep_hours': 6.8, 'workload_score': 9},
        {'sleep_hours': 7.0, 'workload_score': 8},
        {'sleep_hours': 7.1, 'workload_score': 8},
      ];

      final baseline = OnDeviceBaselineEngine.computeLocalBaseline(
        localCheckIns: stableCheckIns,
      );

      expect(baseline.sampleCount, equals(5));
      expect(baseline.meanSleep, closeTo(7.0, 0.2));
      expect(baseline.sleepShiftAlert, isFalse);
      expect(baseline.workloadSpikeAlert, isFalse);
    });

    test('Detects sustained downward sleep shift offline via CUSUM', () {
      final sleepDeprivedCheckIns = [
        {'sleep_hours': 7.5, 'workload_score': 8},
        {'sleep_hours': 7.0, 'workload_score': 8},
        {'sleep_hours': 7.5, 'workload_score': 8},
        {'sleep_hours': 7.2, 'workload_score': 8},
        {'sleep_hours': 7.0, 'workload_score': 8},
        {'sleep_hours': 7.2, 'workload_score': 8},
        // Sudden persistent collapse in sleep
        {'sleep_hours': 3.5, 'workload_score': 14},
        {'sleep_hours': 3.0, 'workload_score': 15},
        {'sleep_hours': 3.2, 'workload_score': 14},
        {'sleep_hours': 3.0, 'workload_score': 16},
        {'sleep_hours': 2.8, 'workload_score': 15},
      ];

      final baseline = OnDeviceBaselineEngine.computeLocalBaseline(
        localCheckIns: sleepDeprivedCheckIns,
      );

      expect(baseline.sleepShiftAlert, isTrue);
      expect(baseline.workloadSpikeAlert, isTrue);
    });
  });

  group('Phase 17: Offline Fallbacks & Screen Security', () {
    test('Generates and parses SMS check-in payload', () {
      final payload = OfflineFallbackService.generateSmsCheckInPayload(
        officerToken: 'TK-8492-4102-9912',
        phq2Score: 1,
        gad2Score: 2,
        sleepHours: 6.5,
        workloadScore: 11,
      );

      expect(payload, equals('RAKSHA CHK TK-8492-4102-9912 1 2 6.5 11'));

      final parsed = OfflineFallbackService.parseSmsCheckInPayload(payload);
      expect(parsed, isNotNull);
      expect(parsed!['token'], equals('TK-8492-4102-9912'));
      expect(parsed['phq2_score'], equals(1));
      expect(parsed['gad2_score'], equals(2));
      expect(parsed['sleep_hours'], equals(6.5));
      expect(parsed['workload_score'], equals(11));
    });

    test('Returns Tele-MANAS IVR instructions', () {
      final ivr = OfflineFallbackService.getIvrRoutingInstructions();
      expect(ivr['tele_manas'], equals('14416'));
      expect(ivr['instruction'], contains('Dial 14416'));
    });

    test('ScreenSecurityService toggles screenshot block protection', () {
      final screenSec = ScreenSecurityService();
      expect(screenSec.isScreenshotBlocked, isTrue);

      screenSec.setScreenshotProtection(false);
      expect(screenSec.isScreenshotBlocked, isFalse);

      screenSec.setScreenshotProtection(true);
      expect(screenSec.isScreenshotBlocked, isTrue);
    });
  });
}
