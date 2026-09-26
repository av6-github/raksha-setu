// lib/features/hrms/presentation/hrms_view_model.dart
// State management for organizational signals, HRMS postings, and dynamic leave submission

import 'package:flutter/foundation.dart';
import '../data/hrms_repository.dart';
import '../domain/deployment_record.dart';
import '../domain/duty_record.dart';
import '../domain/leave_record.dart';
import '../domain/organisational_signal.dart';

class HrmsViewModel extends ChangeNotifier {
  final IHrmsRepository repository;
  final String officerId;

  List<LeaveRecord> _leaves = [];
  List<DeploymentRecord> _deployments = [];
  List<DutyRecord> _dutyRecords = [];
  OrganisationalSignal? _signal;
  bool _isLoading = true;
  String? _errorMessage;

  HrmsViewModel({
    required this.repository,
    required this.officerId,
  }) {
    loadData();
  }

  List<LeaveRecord> get leaves => _leaves;
  List<DeploymentRecord> get deployments => _deployments;
  List<DutyRecord> get dutyRecords => _dutyRecords;
  OrganisationalSignal? get signal => _signal;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _leaves = await repository.getLeaveRecords(officerId);
      _deployments = await repository.getDeploymentRecords(officerId);
      _dutyRecords = await repository.getDutyRecords(officerId);
      _signal = await repository.getOrganisationalSignal(officerId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyLeave({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newRecord = await repository.applyForLeave(
        officerId: officerId,
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );
      _leaves = [newRecord, ..._leaves.where((l) => l.id != newRecord.id)];
      _signal = await repository.getOrganisationalSignal(officerId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
