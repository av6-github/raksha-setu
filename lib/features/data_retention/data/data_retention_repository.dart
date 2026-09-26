// lib/features/data_retention/data/data_retention_repository.dart
// Officer data retention policies and purge requests

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../core/logging/app_logger.dart';

class DeletionRequestItem {
  final String id;
  final String requestType; // 'voluntary_biometrics', 'morale_vault_media', 'officer_separation'
  final String status; // 'submitted', 'processing', 'completed'
  final DateTime submittedAt;

  DeletionRequestItem({
    required this.id,
    required this.requestType,
    required this.status,
    required this.submittedAt,
  });

  String get typeDisplay {
    switch (requestType) {
      case 'voluntary_biometrics':
        return 'Purge All Biometric Data';
      case 'morale_vault_media':
        return 'Purge Morale Vault Media';
      case 'officer_separation':
        return 'Post-Separation Data Purge';
      default:
        return requestType;
    }
  }

  factory DeletionRequestItem.fromMap(Map<String, dynamic> map) {
    return DeletionRequestItem(
      id: map['id'] as String,
      requestType: map['request_type'] as String,
      status: map['status'] as String? ?? 'submitted',
      submittedAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

abstract class IDataRetentionRepository {
  Future<List<DeletionRequestItem>> getDeletionRequests(String officerId);
  Future<DeletionRequestItem> submitDeletionRequest(String officerId, String requestType, String justification);
}

class DataRetentionRepository implements IDataRetentionRepository {
  final sp.SupabaseClient? client;
  final List<DeletionRequestItem> _mockRequests = [];

  DataRetentionRepository({this.client});

  @override
  Future<List<DeletionRequestItem>> getDeletionRequests(String officerId) async {
    if (client == null) {
      return _mockRequests;
    }

    try {
      final res = await client!
          .from('deletion_requests')
          .select()
          .eq('officer_id', officerId)
          .order('created_at', ascending: false);

      return (res as List).map((m) => DeletionRequestItem.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.warning('Failed to load deletion requests; using local cache', error: e);
      return _mockRequests;
    }
  }

  @override
  Future<DeletionRequestItem> submitDeletionRequest(
    String officerId,
    String requestType,
    String justification,
  ) async {
    if (client == null) {
      final item = DeletionRequestItem(
        id: 'mock-del-${DateTime.now().millisecondsSinceEpoch}',
        requestType: requestType,
        status: 'submitted',
        submittedAt: DateTime.now(),
      );
      _mockRequests.add(item);
      AppLogger.info('Submitted mock deletion request for $requestType');
      return item;
    }

    try {
      final res = await client!
          .from('deletion_requests')
          .insert({
            'officer_id': officerId,
            'request_type': requestType,
            'justification': justification,
            'status': 'submitted',
          })
          .select()
          .single();

      return DeletionRequestItem.fromMap(res);
    } catch (e) {
      AppLogger.error('Failed to submit deletion request', error: e);
      final item = DeletionRequestItem(
        id: 'offline-del-${DateTime.now().millisecondsSinceEpoch}',
        requestType: requestType,
        status: 'submitted',
        submittedAt: DateTime.now(),
      );
      _mockRequests.add(item);
      return item;
    }
  }
}
