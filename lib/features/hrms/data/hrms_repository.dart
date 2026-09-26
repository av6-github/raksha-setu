// lib/features/hrms/data/hrms_repository.dart
// Read-only repository for HRMS leaves, postings, and rosters with firewall write protections

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../core/errors/app_exceptions.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/deployment_record.dart';
import '../domain/duty_record.dart';
import '../domain/leave_record.dart';
import '../domain/organisational_signal.dart';
import 'hrms_mock_service.dart';

abstract class IHrmsRepository {
  Future<List<LeaveRecord>> getLeaveRecords(String officerId);
  Future<List<DeploymentRecord>> getDeploymentRecords(String officerId);
  Future<List<DutyRecord>> getDutyRecords(String officerId);
  Future<OrganisationalSignal> getOrganisationalSignal(String officerId);
  void assertReadOnly();
}

class HrmsRepository implements IHrmsRepository {
  final sp.SupabaseClient? client;
  final HrmsMockService mockService;

  HrmsRepository({
    this.client,
    HrmsMockService? mockService,
  }) : mockService = mockService ?? HrmsMockService();

  @override
  void assertReadOnly() {
    throw const FirewallViolationException(
      'Welfare-HR Firewall Violation: Ingestion of HRMS data is strictly read-only. '
      'Writing wellness scores or clinical assessments back to personnel records is legally prohibited.',
    );
  }

  @override
  Future<List<LeaveRecord>> getLeaveRecords(String officerId) async {
    if (client == null) {
      return mockService.getMockLeaves(officerId);
    }

    try {
      final res = await client!
          .from('leave_records')
          .select()
          .eq('officer_id', officerId)
          .order('start_date', ascending: false);

      final list = (res as List).map((m) => LeaveRecord.fromMap(m as Map<String, dynamic>)).toList();
      return list.isEmpty ? mockService.getMockLeaves(officerId) : list;
    } catch (e) {
      AppLogger.warning('Failed to fetch leave records from Supabase; using mock service', error: e);
      return mockService.getMockLeaves(officerId);
    }
  }

  @override
  Future<List<DeploymentRecord>> getDeploymentRecords(String officerId) async {
    if (client == null) {
      return mockService.getMockDeployments(officerId);
    }

    try {
      final res = await client!
          .from('deployments')
          .select()
          .eq('officer_id', officerId)
          .order('start_date', ascending: false);

      final list = (res as List).map((m) => DeploymentRecord.fromMap(m as Map<String, dynamic>)).toList();
      return list.isEmpty ? mockService.getMockDeployments(officerId) : list;
    } catch (e) {
      AppLogger.warning('Failed to fetch deployments from Supabase; using mock service', error: e);
      return mockService.getMockDeployments(officerId);
    }
  }

  @override
  Future<List<DutyRecord>> getDutyRecords(String officerId) async {
    if (client == null) {
      return mockService.getMockDutyRecords(officerId);
    }

    try {
      final res = await client!
          .from('duty_records')
          .select('*, shifts(name, is_night_shift)')
          .eq('officer_id', officerId)
          .order('date', ascending: false)
          .limit(30);

      final list = (res as List).map((m) => DutyRecord.fromMap(m as Map<String, dynamic>)).toList();
      return list.isEmpty ? mockService.getMockDutyRecords(officerId) : list;
    } catch (e) {
      AppLogger.warning('Failed to fetch duty records; using mock service', error: e);
      return mockService.getMockDutyRecords(officerId);
    }
  }

  @override
  Future<OrganisationalSignal> getOrganisationalSignal(String officerId) async {
    final leaves = await getLeaveRecords(officerId);
    final deployments = await getDeploymentRecords(officerId);
    final dutyRecords = await getDutyRecords(officerId);

    return OrganisationalSignal.compute(
      officerId: officerId,
      leaves: leaves,
      deployments: deployments,
      dutyRecords: dutyRecords,
    );
  }
}
