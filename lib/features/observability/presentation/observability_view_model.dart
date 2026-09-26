// lib/features/observability/presentation/observability_view_model.dart
// State management for System Telemetry, Sync Monitoring, ML Drift, and Sanitized Alerting

import 'package:flutter/foundation.dart';
import '../data/observability_repository.dart';
import '../domain/models/observability_models.dart';

class ObservabilityViewModel extends ChangeNotifier {
  final IObservabilityRepository repository;

  bool _isLoading = false;
  String? _error;

  SystemHealthMetrics? _systemMetrics;
  SyncMonitoringMetrics? _syncMetrics;
  CrisisRoutingMetrics? _crisisMetrics;
  List<ModelDriftMetric> _driftMetrics = [];
  ModelCalibrationMetric? _calibrationMetric;
  List<SubgroupBiasMetric> _biasAudits = [];
  AuditLogHealthMetric? _auditLogHealth;
  List<ProviderHealthMetric> _providerHealth = [];
  List<ObservabilityAlert> _alerts = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  SystemHealthMetrics? get systemMetrics => _systemMetrics;
  SyncMonitoringMetrics? get syncMetrics => _syncMetrics;
  CrisisRoutingMetrics? get crisisMetrics => _crisisMetrics;
  List<ModelDriftMetric> get driftMetrics => List.unmodifiable(_driftMetrics);
  ModelCalibrationMetric? get calibrationMetric => _calibrationMetric;
  List<SubgroupBiasMetric> get biasAudits => List.unmodifiable(_biasAudits);
  AuditLogHealthMetric? get auditLogHealth => _auditLogHealth;
  List<ProviderHealthMetric> get providerHealth => List.unmodifiable(_providerHealth);
  List<ObservabilityAlert> get alerts => List.unmodifiable(_alerts);

  ObservabilityViewModel({required this.repository}) {
    loadMetrics();
  }

  Future<void> loadMetrics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        repository.getSystemHealthMetrics(),
        repository.getSyncMonitoringMetrics(),
        repository.getCrisisRoutingMetrics(),
        repository.getModelDriftMetrics(),
        repository.getLatestCalibrationMetric(),
        repository.getBiasAudits(),
        repository.getAuditLogHealth(),
        repository.getProviderHealthMetrics(),
        repository.getAlerts(),
      ]);

      _systemMetrics = results[0] as SystemHealthMetrics;
      _syncMetrics = results[1] as SyncMonitoringMetrics;
      _crisisMetrics = results[2] as CrisisRoutingMetrics;
      _driftMetrics = results[3] as List<ModelDriftMetric>;
      _calibrationMetric = results[4] as ModelCalibrationMetric;
      _biasAudits = results[5] as List<SubgroupBiasMetric>;
      _auditLogHealth = results[6] as AuditLogHealthMetric;
      _providerHealth = results[7] as List<ProviderHealthMetric>;
      _alerts = results[8] as List<ObservabilityAlert>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acknowledgeAlert(String alertId) async {
    try {
      await repository.acknowledgeAlert(alertId);
      final index = _alerts.indexWhere((a) => a.id == alertId);
      if (index != -1) {
        _alerts[index] = _alerts[index].copyWith(isAcknowledged: true);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> dispatchAlert({
    required AlertSeverity severity,
    required String source,
    required String title,
    required String details,
  }) async {
    try {
      final alert = await repository.dispatchSanitizedAlert(
        severity: severity,
        source: source,
        title: title,
        details: details,
      );
      _alerts.insert(0, alert);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
