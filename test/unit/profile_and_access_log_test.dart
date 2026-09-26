import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/access_log/data/access_log_repository.dart';
import 'package:raksha_welfare/features/data_retention/data/data_retention_repository.dart';
import 'package:raksha_welfare/features/profile/data/profile_repository.dart';
import 'package:raksha_welfare/features/profile/presentation/profile_view_model.dart';

void main() {
  group('Phase 2 — Profile, Access Log & Data Retention Unit Tests', () {
    const testOfficerId = 'mock-officer-uuid-001';

    test('ProfileRepository returns complete officer identity and self-data summary', () async {
      final repo = ProfileRepository(client: null);
      final vm = ProfileViewModel(repository: repo, officerId: testOfficerId);

      await vm.loadProfile();

      expect(vm.profile, isNotNull);
      expect(vm.profile!.fullName, 'Vikram Singh');
      expect(vm.profile!.serviceNumber, 'CRPF-2024-8891');
      expect(vm.profile!.dutyStatusDisplay, 'Full Active Duty');
      expect(vm.selfData?['firewall_status'], 'ACTIVE');
      expect(vm.selfData?['command_access_level'], contains('k >= 10'));
    });

    test('AccessLogRepository returns transparent audit records with action formatting', () async {
      final repo = AccessLogRepository(client: null);
      final logs = await repo.getAccessLogsForOfficer(testOfficerId);

      expect(logs.isNotEmpty, isTrue);
      expect(logs.any((l) => l.action == 'READ_CLINICAL'), isTrue);
      final clinicalLog = logs.firstWhere((l) => l.action == 'READ_CLINICAL');
      expect(clinicalLog.actionDisplay, 'Confidential Clinical Review');
      expect(clinicalLog.actorRole, contains('Clinical Counsellor'));
    });

    test('DataRetentionRepository submits purge requests for voluntary biometrics', () async {
      final repo = DataRetentionRepository(client: null);
      final submitted = await repo.submitDeletionRequest(
        testOfficerId,
        'voluntary_biometrics',
        'Officer requested deletion of wearable data',
      );

      expect(submitted.status, 'submitted');
      expect(submitted.typeDisplay, 'Purge All Biometric Data');

      final allRequests = await repo.getDeletionRequests(testOfficerId);
      expect(allRequests.any((r) => r.id == submitted.id), isTrue);
    });
  });
}
