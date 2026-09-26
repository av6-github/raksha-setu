// lib/features/trust/presentation/governance_view_model.dart
// ViewModel for Trust, Ethics, Security, Break-Glass Oversight, and Differential Privacy

import 'package:flutter/material.dart';
import '../data/governance_repository.dart';
import '../domain/differential_privacy_engine.dart';
import '../domain/governance_models.dart';

class GovernanceViewModel extends ChangeNotifier {
  final IGovernanceRepository repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  List<OversightReview> _oversightReviews = [];
  List<OversightReview> get oversightReviews => _oversightReviews;

  List<BiasAudit> _biasAudits = [];
  List<BiasAudit> get biasAudits => _biasAudits;

  List<BreakGlassEvent> _breakGlassEvents = [];
  List<BreakGlassEvent> get breakGlassEvents => _breakGlassEvents;

  List<CoDesignFeedback> _coDesignFeedbacks = [];
  List<CoDesignFeedback> get coDesignFeedbacks => _coDesignFeedbacks;

  ShadowPilotMetrics? _shadowMetrics;
  ShadowPilotMetrics? get shadowMetrics => _shadowMetrics;

  Map<String, dynamic> _complianceStatus = {};
  Map<String, dynamic> get complianceStatus => _complianceStatus;

  GovernanceViewModel({required this.repository}) {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _oversightReviews = await repository.getOversightReviews();
      _biasAudits = await repository.getBiasAudits();
      _breakGlassEvents = await repository.getBreakGlassEvents();
      _coDesignFeedbacks = await repository.getCoDesignFeedbacks();
      _shadowMetrics = await repository.getShadowPilotMetrics();
      _complianceStatus = await repository.getSecurityComplianceStatus();
    } catch (e) {
      _errorMessage = 'Failed to load governance data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reviewBreakGlass({
    required String eventId,
    required BreakGlassStatus status,
    required String notes,
  }) async {
    try {
      await repository.reviewBreakGlassEvent(eventId, status, notes);
      _successMessage = 'Break-glass review recorded. Status updated to ${status.displayName}.';
      _breakGlassEvents = await repository.getBreakGlassEvents();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update break-glass review: $e';
      notifyListeners();
    }
  }

  Future<bool> submitCoDesignFeedback({
    required String officerRankDisplay,
    required String unit,
    required String topic,
    required String feedbackText,
  }) async {
    try {
      final feedback = CoDesignFeedback(
        id: 'cd-${DateTime.now().millisecondsSinceEpoch}',
        officerRankDisplay: officerRankDisplay.trim(),
        unit: unit.trim(),
        topic: topic.trim(),
        feedbackText: feedbackText.trim(),
        actionStatus: 'under_review',
        submittedAt: DateTime.now(),
      );
      await repository.submitCoDesignFeedback(feedback);
      _successMessage = 'Co-design suggestion submitted for ethics & usability committee review.';
      _coDesignFeedbacks = await repository.getCoDesignFeedbacks();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit co-design feedback: $e';
      notifyListeners();
      return false;
    }
  }

  Map<String, dynamic> testDifferentialPrivacy(int cohortSize) {
    return DifferentialPrivacyEngine.generateDifferentiallyPrivateSummary(
      unitName: 'Alpha Company, 45 Bn',
      cohortSize: cohortSize,
      averageSleepHours: 6.4,
      averageWorkloadHours: 11.2,
      checkInCompletionRate: 0.88,
      epsilon: 1.0,
    );
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
