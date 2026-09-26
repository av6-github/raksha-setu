// lib/features/shadow_pilot/presentation/shadow_pilot_view_model.dart
// State management for Phase 19 Shadow Pilot, Clinician Concordance, Error Analysis, and Go/No-Go Gate

import 'package:flutter/foundation.dart';
import '../data/shadow_pilot_repository.dart';
import '../domain/models/shadow_pilot_models.dart';
import '../../trust/domain/governance_models.dart';

class ShadowPilotViewModel extends ChangeNotifier {
  final IShadowPilotRepository repository;

  bool _isLoading = false;
  String? _error;

  SyntheticValidationReport? _syntheticReport;
  List<SilentPredictionRecord> _silentPredictions = [];
  CounsellorComparisonReport? _counsellorComparison;
  ErrorAnalysisReport? _errorAnalysis;
  TrustSurveyReport? _trustSurvey;
  KpiBaselineMetrics? _kpiBaseline;
  GoNoGoGateReview? _gateReview;
  List<CoDesignFeedback> _coDesignFeedbacks = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  SyntheticValidationReport? get syntheticReport => _syntheticReport;
  List<SilentPredictionRecord> get silentPredictions => List.unmodifiable(_silentPredictions);
  CounsellorComparisonReport? get counsellorComparison => _counsellorComparison;
  ErrorAnalysisReport? get errorAnalysis => _errorAnalysis;
  TrustSurveyReport? get trustSurvey => _trustSurvey;
  KpiBaselineMetrics? get kpiBaseline => _kpiBaseline;
  GoNoGoGateReview? get gateReview => _gateReview;
  List<CoDesignFeedback> get coDesignFeedbacks => List.unmodifiable(_coDesignFeedbacks);

  ShadowPilotViewModel({required this.repository}) {
    loadMetrics();
  }

  Future<void> loadMetrics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        repository.getSyntheticValidationReport(),
        repository.getSilentPredictions(),
        repository.getCounsellorComparison(),
        repository.getErrorAnalysis(),
        repository.getTrustSurvey(),
        repository.getKpiBaseline(),
        repository.getGoNoGoGate(),
        repository.getCoDesignFeedbacks(),
      ]);

      _syntheticReport = results[0] as SyntheticValidationReport;
      _silentPredictions = results[1] as List<SilentPredictionRecord>;
      _counsellorComparison = results[2] as CounsellorComparisonReport;
      _errorAnalysis = results[3] as ErrorAnalysisReport;
      _trustSurvey = results[4] as TrustSurveyReport;
      _kpiBaseline = results[5] as KpiBaselineMetrics;
      _gateReview = results[6] as GoNoGoGateReview;
      _coDesignFeedbacks = results[7] as List<CoDesignFeedback>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitFeedback({
    required String rank,
    required String unit,
    required String topic,
    required String feedbackText,
  }) async {
    try {
      final feedback = CoDesignFeedback(
        id: 'fb-${DateTime.now().millisecondsSinceEpoch}',
        officerRankDisplay: rank,
        unit: unit,
        topic: topic,
        feedbackText: feedbackText,
        actionStatus: 'under_review',
        submittedAt: DateTime.now(),
      );

      await repository.submitCoDesignFeedback(feedback);
      _coDesignFeedbacks.insert(0, feedback);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
