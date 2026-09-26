// lib/features/risk/presentation/risk_view_model.dart
// State management for explainable risk assessment and model transparency

import 'package:flutter/foundation.dart';
import '../../analytics/domain/deviation_event.dart';
import '../../analytics/domain/personal_baseline.dart';
import '../../hrms/domain/organisational_signal.dart';
import '../data/risk_repository.dart';
import '../domain/model_metrics.dart';
import '../domain/risk_score.dart';

class RiskViewModel extends ChangeNotifier {
  final IRiskRepository repository;
  final String officerId;

  RiskScore? _riskScore;
  ModelMetrics? _metrics;
  bool _isLoading = true;
  String? _errorMessage;

  RiskViewModel({
    required this.repository,
    required this.officerId,
  }) {
    loadData();
  }

  RiskScore? get riskScore => _riskScore;
  ModelMetrics? get metrics => _metrics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _riskScore = await repository.getLatestRiskScore(officerId);
      _metrics = await repository.getModelMetrics();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reevaluate({
    required PersonalBaseline baseline,
    required List<DeviationEvent> deviations,
    required OrganisationalSignal signal,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _riskScore = await repository.evaluateRisk(
        officerId: officerId,
        baseline: baseline,
        deviations: deviations,
        organisationalSignal: signal,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
