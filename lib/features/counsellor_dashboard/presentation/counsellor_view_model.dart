// lib/features/counsellor_dashboard/presentation/counsellor_view_model.dart
// State management for Clinical Counsellor Portal

import 'package:flutter/foundation.dart';
import '../../crisis/domain/safety_plan.dart';
import '../../../core/security/rbac_guard.dart';
import '../data/counsellor_repository.dart';
import '../domain/clinical_case.dart';
import '../domain/clinical_follow_up.dart';

class CounsellorViewModel extends ChangeNotifier {
  final ICounsellorRepository repository;
  final String counsellorId;

  bool _isLoading = false;
  String? _errorMessage;
  List<ClinicalCase> _cases = [];
  ClinicalCase? _selectedCase;
  List<ClinicalFollowUp> _followUps = [];
  SafetyPlan? _currentSafetyPlan;
  BreakGlassEvent? _lastBreakGlassEvent;
  List<Map<String, dynamic>> _officerAssessments = [];
  List<Map<String, dynamic>> _emergencyAlerts = [];

  CounsellorViewModel({
    required this.repository,
    this.counsellorId = 'counsellor-staff-001',
  }) {
    loadCases();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ClinicalCase> get cases => _cases;
  ClinicalCase? get selectedCase => _selectedCase;
  List<ClinicalFollowUp> get followUps => _followUps;
  SafetyPlan? get currentSafetyPlan => _currentSafetyPlan;
  BreakGlassEvent? get lastBreakGlassEvent => _lastBreakGlassEvent;
  List<Map<String, dynamic>> get officerAssessments => _officerAssessments;
  List<Map<String, dynamic>> get emergencyAlerts => _emergencyAlerts;

  Future<void> loadCases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cases = await repository.getActiveCases();
      if (_cases.isNotEmpty && _selectedCase == null) {
        await selectCase(_cases.first.caseId);
      }
      _officerAssessments = await repository.getOfficerAssessments();
      _emergencyAlerts = await repository.getEmergencyAlerts();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acknowledgeCrisisAlert(String alertId) async {
    try {
      await repository.acknowledgeCrisisAlert(alertId);
      _emergencyAlerts = await repository.getEmergencyAlerts();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> selectCase(String caseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedCase = await repository.getCaseDetail(caseId);
      _followUps = await repository.getFollowUps(caseId);
      _currentSafetyPlan = await repository.getSafetyPlanForOfficer(_selectedCase!.officerId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFollowUpNote({
    required String caseId,
    required String note,
    required String rtdRecommendation,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.addFollowUpNote(
        caseId: caseId,
        note: note,
        rtdRecommendation: rtdRecommendation,
      );
      _selectedCase = await repository.getCaseDetail(caseId);
      _followUps = await repository.getFollowUps(caseId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> triggerEmergencyBreakGlass({
    required String targetOfficerId,
    required String reasonCode,
    required String justification,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _lastBreakGlassEvent = await repository.emergencyBreakGlass(
        counsellorId: counsellorId,
        targetOfficerId: targetOfficerId,
        reasonCode: reasonCode,
        justification: justification,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
