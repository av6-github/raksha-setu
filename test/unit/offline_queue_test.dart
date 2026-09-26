import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raksha_welfare/core/storage/offline_queue_item.dart';
import 'package:raksha_welfare/core/storage/offline_queue_service.dart';

void main() {
  group('OfflineQueueService Tests', () {
    late SharedPreferences prefs;
    late OfflineQueueService queueService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      queueService = OfflineQueueService(prefs: prefs);
    });

    test('enqueue creates item with idempotency key and pending status', () async {
      final item = await queueService.enqueue('check_ins', {
        'phq2_score': 1,
        'gad2_score': 0,
        'sleep_quality_score': 4,
      });

      expect(item.id, isNotEmpty);
      expect(item.idempotencyKey, isNotEmpty);
      expect(item.status, QueueItemStatus.pending);
      expect(queueService.queueLength, 1);

      final pending = await queueService.getPendingItems();
      expect(pending.length, 1);
      expect(pending.first.id, item.id);
    });

    test('markFailed increments retryCount and records error', () async {
      final item = await queueService.enqueue('assessments', {'score': 5});
      await queueService.markFailed(item.id, 'Timeout connecting to backend');

      final pending = await queueService.getPendingItems();
      expect(pending.first.retryCount, 1);
      expect(pending.first.status, QueueItemStatus.failed);
      expect(pending.first.lastError, 'Timeout connecting to backend');
    });

    test('markSynced removes item from persistent queue', () async {
      final item = await queueService.enqueue('check_ins', {'status': 'done'});
      expect(queueService.queueLength, 1);

      await queueService.markSynced(item.id);
      expect(queueService.queueLength, 0);

      final pending = await queueService.getPendingItems();
      expect(pending, isEmpty);
    });
  });
}
