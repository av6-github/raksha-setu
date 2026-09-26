// lib/core/storage/offline_queue_service.dart
// Offline queue management with idempotency key generation and persistent storage

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../logging/app_logger.dart';
import 'offline_queue_item.dart';

abstract class IOfflineQueueService {
  Future<OfflineQueueItem> enqueue(String endpoint, Map<String, dynamic> payload);
  Future<List<OfflineQueueItem>> getPendingItems();
  Future<void> markInFlight(String id);
  Future<void> markSynced(String id);
  Future<void> markFailed(String id, String error);
  Future<void> clear();
  int get queueLength;
}

class OfflineQueueService implements IOfflineQueueService {
  static const String _storageKey = 'raksha_offline_queue_v1';
  final SharedPreferences prefs;
  final _uuid = const Uuid();
  List<OfflineQueueItem> _items = [];

  OfflineQueueService({required this.prefs}) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final rawList = prefs.getStringList(_storageKey);
    if (rawList != null) {
      _items = rawList
          .map((itemStr) {
            try {
              return OfflineQueueItem.deserialize(itemStr);
            } catch (e) {
              AppLogger.error('Failed to parse queue item', error: e);
              return null;
            }
          })
          .whereType<OfflineQueueItem>()
          .toList();
    }
  }

  Future<void> _persist() async {
    final rawList = _items.map((item) => item.serialize()).toList();
    await prefs.setStringList(_storageKey, rawList);
  }


  String _generateIdempotencyKey(String endpoint, Map<String, dynamic> payload) {
    final rawString = '$endpoint:${jsonEncode(payload)}:${DateTime.now().millisecondsSinceEpoch}';
    return sha256.convert(utf8.encode(rawString)).toString();
  }

  @override
  Future<OfflineQueueItem> enqueue(String endpoint, Map<String, dynamic> payload) async {
    final item = OfflineQueueItem(
      id: _uuid.v4(),
      idempotencyKey: _generateIdempotencyKey(endpoint, payload),
      endpoint: endpoint,
      payload: payload,
      createdAt: DateTime.now(),
      status: QueueItemStatus.pending,
    );

    _items.add(item);
    await _persist();
    AppLogger.info('Enqueued offline mutation: ${item.endpoint} [id: ${item.id}]');
    return item;
  }

  @override
  Future<List<OfflineQueueItem>> getPendingItems() async {
    return _items
        .where((i) => i.status == QueueItemStatus.pending || i.status == QueueItemStatus.failed)
        .toList();
  }

  @override
  Future<void> markInFlight(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(status: QueueItemStatus.inFlight);
      await _persist();
    }
  }

  @override
  Future<void> markSynced(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _persist();
    AppLogger.info('Successfully synced and dequeued offline mutation [id: $id]');
  }

  @override
  Future<void> markFailed(String id, String error) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      final current = _items[index];
      _items[index] = current.copyWith(
        status: QueueItemStatus.failed,
        retryCount: current.retryCount + 1,
        lastError: error,
      );
      await _persist();
      AppLogger.warning('Offline mutation marked failed [id: $id, retry: ${current.retryCount + 1}]: $error');
    }
  }

  @override
  Future<void> clear() async {
    _items.clear();
    await prefs.remove(_storageKey);
  }

  @override
  int get queueLength => _items.length;
}
