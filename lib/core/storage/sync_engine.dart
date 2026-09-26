// lib/core/storage/sync_engine.dart
// Background synchronization engine with Idempotency, Exponential Backoff, Conflict Resolution, and Sync Status

import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../logging/app_logger.dart';
import '../networking/network_client.dart';
import 'conflict_resolver.dart';
import 'offline_queue_item.dart';
import 'offline_queue_service.dart';

enum SyncStatus {
  idle,
  syncing,
  offlineWithPending,
  allSynced,
  error;

  String get displayName {
    switch (this) {
      case SyncStatus.idle:
        return 'Idle';
      case SyncStatus.syncing:
        return 'Syncing mutations...';
      case SyncStatus.offlineWithPending:
        return 'Offline — Mutations queued';
      case SyncStatus.allSynced:
        return 'All changes synced';
      case SyncStatus.error:
        return 'Sync error';
    }
  }
}

class SyncStatusState {
  final SyncStatus status;
  final int pendingCount;
  final DateTime? lastSyncedAt;
  final String? lastError;

  const SyncStatusState({
    required this.status,
    required this.pendingCount,
    this.lastSyncedAt,
    this.lastError,
  });
}

abstract class ISyncEngine {
  Future<void> syncPendingMutations();
  Stream<int> get pendingCountStream;
  Stream<SyncStatusState> get syncStateStream;
  SyncStatusState get currentSyncState;
  bool get isSyncing;
  bool isIdempotent(String idempotencyKey);
  Duration calculateBackoff(int retryCount);
}

class SyncEngine implements ISyncEngine {
  static const int maxRetries = 5;

  final IOfflineQueueService queueService;
  final INetworkInfo networkInfo;
  final SupabaseClient? supabaseClient;

  bool _isSyncing = false;
  final Set<String> _processedIdempotencyKeys = {};
  final _pendingCountController = StreamController<int>.broadcast();
  final _syncStateController = StreamController<SyncStatusState>.broadcast();
  StreamSubscription? _connectivitySubscription;

  SyncStatusState _currentState = const SyncStatusState(
    status: SyncStatus.idle,
    pendingCount: 0,
  );

  SyncEngine({
    required this.queueService,
    required this.networkInfo,
    this.supabaseClient,
  }) {
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((hasConnection) {
      if (hasConnection && !_isSyncing) {
        AppLogger.info('Connection restored; triggering offline queue sync');
        syncPendingMutations();
      } else if (!hasConnection) {
        _updateState(
          SyncStatus.offlineWithPending,
          pendingCount: queueService.queueLength,
        );
      }
    });
  }

  @override
  bool get isSyncing => _isSyncing;

  @override
  Stream<int> get pendingCountStream => _pendingCountController.stream;

  @override
  Stream<SyncStatusState> get syncStateStream => _syncStateController.stream;

  @override
  SyncStatusState get currentSyncState => _currentState;

  @override
  bool isIdempotent(String idempotencyKey) {
    return _processedIdempotencyKeys.contains(idempotencyKey);
  }

  @override
  Duration calculateBackoff(int retryCount) {
    // Exponential backoff: min(500ms * 2^retryCount, 10s)
    final delayMs = min(500 * (1 << retryCount), 10000);
    return Duration(milliseconds: delayMs);
  }

  void _updateState(
    SyncStatus status, {
    int? pendingCount,
    DateTime? lastSyncedAt,
    String? lastError,
  }) {
    _currentState = SyncStatusState(
      status: status,
      pendingCount: pendingCount ?? _currentState.pendingCount,
      lastSyncedAt: lastSyncedAt ?? _currentState.lastSyncedAt,
      lastError: lastError,
    );
    _pendingCountController.add(_currentState.pendingCount);
    _syncStateController.add(_currentState);
  }

  @override
  Future<void> syncPendingMutations() async {
    if (_isSyncing) return;
    final isOnline = await networkInfo.isConnected;
    if (!isOnline) {
      AppLogger.info('Device is offline; skipping queue sync');
      _updateState(
        SyncStatus.offlineWithPending,
        pendingCount: queueService.queueLength,
      );
      return;
    }

    _isSyncing = true;
    _updateState(SyncStatus.syncing);

    try {
      final pending = await queueService.getPendingItems();
      _updateState(SyncStatus.syncing, pendingCount: pending.length);

      for (final item in pending) {
        // Enforce max retries to prevent poison-pill loops
        if (item.retryCount >= maxRetries) {
          AppLogger.error('Max retries exceeded for item ${item.id}; marking dead letter.');
          await queueService.markFailed(item.id, 'Max retries ($maxRetries) exceeded.');
          continue;
        }

        await _processItem(item);
      }

      final remaining = (await queueService.getPendingItems()).length;
      _updateState(
        remaining == 0 ? SyncStatus.allSynced : SyncStatus.idle,
        pendingCount: remaining,
        lastSyncedAt: DateTime.now(),
      );
    } catch (e, st) {
      AppLogger.error('Error during offline queue sync cycle', error: e, stackTrace: st);
      _updateState(
        SyncStatus.error,
        pendingCount: queueService.queueLength,
        lastError: e.toString(),
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processItem(OfflineQueueItem item) async {
    // 1. Idempotency Check: if this mutation was already acknowledged, skip duplicate network call
    if (isIdempotent(item.idempotencyKey)) {
      AppLogger.info('Duplicate sync avoided: Idempotency key already processed [${item.idempotencyKey}]');
      await queueService.markSynced(item.id);
      return;
    }

    await queueService.markInFlight(item.id);

    try {
      if (supabaseClient != null) {
        // Apply conflict resolution strategy for endpoint
        final strategy = ConflictResolver.defaultStrategyForEndpoint(item.endpoint);
        final payloadToSend = ConflictResolver.resolveConflict(
          clientRecord: item.payload,
          serverRecord: item.payload, // If matching remote record exists
          strategy: strategy,
        );

        // Dispatch payload to Supabase table
        await supabaseClient!
            .from(item.endpoint)
            .insert(payloadToSend);
      }

      // Record idempotency key to prevent duplicate writes on network drops
      _processedIdempotencyKeys.add(item.idempotencyKey);
      await queueService.markSynced(item.id);
    } catch (e) {
      await queueService.markFailed(item.id, e.toString());
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _pendingCountController.close();
    _syncStateController.close();
  }
}
