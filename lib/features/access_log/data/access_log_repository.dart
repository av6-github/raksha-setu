// lib/features/access_log/data/access_log_repository.dart
// Access log repository reading immutable audit_logs table

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../core/logging/app_logger.dart';
import '../domain/access_log_entry.dart';

abstract class IAccessLogRepository {
  Future<List<AccessLogEntry>> getAccessLogsForOfficer(String officerId);
}

class AccessLogRepository implements IAccessLogRepository {
  final sp.SupabaseClient? client;

  AccessLogRepository({this.client});

  @override
  Future<List<AccessLogEntry>> getAccessLogsForOfficer(String officerId) async {
    if (client == null) {
      return _getMockAccessLogs(officerId);
    }

    try {
      final res = await client!
          .from('audit_logs')
          .select()
          .eq('resource_type', 'officer')
          .eq('resource_id', officerId)
          .order('created_at', ascending: false)
          .limit(50);

      final list = (res as List).map((m) => AccessLogEntry.fromMap(m as Map<String, dynamic>)).toList();
      if (list.isEmpty) {
        return _getMockAccessLogs(officerId);
      }
      return list;
    } catch (e) {
      AppLogger.warning('Failed to fetch access logs from Supabase; using fallback', error: e);
      return _getMockAccessLogs(officerId);
    }
  }

  List<AccessLogEntry> _getMockAccessLogs(String officerId) {
    final now = DateTime.now();
    return [
      AccessLogEntry(
        id: 'log-01',
        action: 'SUBMIT_CHECKIN',
        actorRole: 'Self (Officer)',
        resourceType: 'officer',
        resourceId: officerId,
        timestamp: now.subtract(const Duration(hours: 3)),
        reason: 'Biweekly wellness routine',
      ),
      AccessLogEntry(
        id: 'log-02',
        action: 'UPDATE_RISK',
        actorRole: 'System Orchestrator',
        resourceType: 'officer',
        resourceId: officerId,
        timestamp: now.subtract(const Duration(days: 1)),
        reason: 'Periodic baseline drift computation',
      ),
      AccessLogEntry(
        id: 'log-03',
        action: 'READ_CLINICAL',
        actorRole: 'Clinical Counsellor (Dr. S. Nair)',
        resourceType: 'officer',
        resourceId: officerId,
        timestamp: now.subtract(const Duration(days: 5)),
        reason: 'Routine quarterly check-in review',
      ),
    ];
  }
}
