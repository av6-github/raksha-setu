// lib/core/storage/offline_queue_item.dart
// Data model for queued offline mutations

import 'dart:convert';

enum QueueItemStatus { pending, inFlight, failed, synced }

class OfflineQueueItem {
  final String id;
  final String idempotencyKey;
  final String endpoint; // e.g., 'check_ins', 'assessments', 'stressors'
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final QueueItemStatus status;
  final String? lastError;

  const OfflineQueueItem({
    required this.id,
    required this.idempotencyKey,
    required this.endpoint,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.status = QueueItemStatus.pending,
    this.lastError,
  });

  OfflineQueueItem copyWith({
    int? retryCount,
    QueueItemStatus? status,
    String? lastError,
  }) {
    return OfflineQueueItem(
      id: id,
      idempotencyKey: idempotencyKey,
      endpoint: endpoint,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idempotencyKey': idempotencyKey,
      'endpoint': endpoint,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'status': status.name,
      'lastError': lastError,
    };
  }

  factory OfflineQueueItem.fromJson(Map<String, dynamic> map) {
    return OfflineQueueItem(
      id: map['id'] as String,
      idempotencyKey: map['idempotencyKey'] as String,
      endpoint: map['endpoint'] as String,
      payload: Map<String, dynamic>.from(map['payload'] as Map),
      createdAt: DateTime.parse(map['createdAt'] as String),
      retryCount: map['retryCount'] as int? ?? 0,
      status: QueueItemStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => QueueItemStatus.pending,
      ),
      lastError: map['lastError'] as String?,
    );
  }

  String serialize() => jsonEncode(toJson());
  factory OfflineQueueItem.deserialize(String jsonStr) =>
      OfflineQueueItem.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}
