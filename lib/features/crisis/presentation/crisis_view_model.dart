// lib/features/crisis/presentation/crisis_view_model.dart
// State management for crisis response, human escalation, and safety planning

import 'package:flutter/foundation.dart';
import '../data/crisis_repository.dart';
import '../domain/safety_plan.dart';

class CrisisViewModel extends ChangeNotifier {
  final ICrisisRepository repository;
  final String officerId;

  SafetyPlan? _safetyPlan;
  bool _isAlertSent = false;
  String? _activeAlertSeverity;
  bool _isLoading = false;
  String? _errorMessage;

  CrisisViewModel({
    required this.repository,
    required this.officerId,
  }) {
    loadSafetyPlan();
  }

  SafetyPlan? get safetyPlan => _safetyPlan;
  bool get isAlertSent => _isAlertSent;
  String? get activeAlertSeverity => _activeAlertSeverity;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSafetyPlan() async {
    _isLoading = true;
    notifyListeners();

    try {
      _safetyPlan = await repository.getSafetyPlan(officerId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> triggerDirectSafetyAlert({String severity = 'high'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.triggerCrisisAlert(
        officerId: officerId,
        source: 'direct_disclosure',
        severity: severity,
      );
      _isAlertSent = true;
      _activeAlertSeverity = severity;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> submitCssrs(Map<int, bool> answers) async {
    _isLoading = true;
    notifyListeners();

    try {
      final severity = await repository.submitCssrsScreener(
        officerId: officerId,
        answers: answers,
      );
      if (severity != 'low') {
        _isAlertSent = true;
        _activeAlertSeverity = severity;
      }
      return severity;
    } catch (e) {
      _errorMessage = e.toString();
      return 'error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
