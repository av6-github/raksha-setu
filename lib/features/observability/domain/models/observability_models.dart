// lib/features/observability/domain/models/observability_models.dart
// Observability, ML Monitoring, API/Sync metrics, Bias & Calibration Models

enum DriftLevel { stable, moderateDrift, severeDrift }
enum ProviderStatus { healthy, degraded, down }
enum AlertSeverity { info, warning, critical }

class SystemHealthMetrics {
  final double apiLatencyMsP95;
  final double apiLatencyMsP99;
  final int requestsPerMinute;
  final double errorRatePercent;
  final double uptimePercent;

  const SystemHealthMetrics({
    required this.apiLatencyMsP95,
    required this.apiLatencyMsP99,
    required this.requestsPerMinute,
    required this.errorRatePercent,
    required this.uptimePercent,
  });
}

class SyncMonitoringMetrics {
  final int pendingQueueDepth;
  final int queueCapacity;
  final double syncSuccessRatePercent;
  final double conflictRatePercent;
  final int backoffRetryCount;
  final int deadLetterCount;

  const SyncMonitoringMetrics({
    required this.pendingQueueDepth,
    required this.queueCapacity,
    required this.syncSuccessRatePercent,
    required this.conflictRatePercent,
    required this.backoffRetryCount,
    required this.deadLetterCount,
  });

  bool get isQueueOverloaded => pendingQueueDepth > (queueCapacity * 0.85);
}

class CrisisRoutingMetrics {
  final int totalCrisisDispatches;
  final int humanRoutedDispatches;
  final int zeroAiViolations; // Strictly must be 0
  final int avgTimeToContactSeconds;

  const CrisisRoutingMetrics({
    required this.totalCrisisDispatches,
    required this.humanRoutedDispatches,
    required this.zeroAiViolations,
    required this.avgTimeToContactSeconds,
  });

  bool get isCompliant => zeroAiViolations == 0 && (totalCrisisDispatches == 0 || humanRoutedDispatches == totalCrisisDispatches);
}

class ModelDriftMetric {
  final String modelVersionTag;
  final String featureName;
  final double psiScore;
  final double? ksStatistic;
  final bool driftDetected;
  final DriftLevel driftLevel;
  final DateTime computedAt;

  const ModelDriftMetric({
    required this.modelVersionTag,
    required this.featureName,
    required this.psiScore,
    this.ksStatistic,
    required this.driftDetected,
    required this.driftLevel,
    required this.computedAt,
  });
}

class ModelCalibrationMetric {
  final String modelVersionTag;
  final double brierScore; // Target: < 0.10
  final double prAuc; // Target: >= 0.80
  final double highRiskRecall; // Target: >= 0.90
  final double precisionAtK;
  final int windowDays;
  final bool isCalibrated;
  final DateTime recordedAt;

  const ModelCalibrationMetric({
    required this.modelVersionTag,
    required this.brierScore,
    required this.prAuc,
    required this.highRiskRecall,
    required this.precisionAtK,
    required this.windowDays,
    required this.isCalibrated,
    required this.recordedAt,
  });
}

class SubgroupBiasMetric {
  final String subgroup;
  final int sampleSize;
  final double falsePositiveRate;
  final double falseNegativeRate;
  final double disparityMetric; // Four-fifths rule: >= 0.80
  final bool isCompliant;
  final DateTime auditDate;

  const SubgroupBiasMetric({
    required this.subgroup,
    required this.sampleSize,
    required this.falsePositiveRate,
    required this.falseNegativeRate,
    required this.disparityMetric,
    required this.isCompliant,
    required this.auditDate,
  });
}

class AuditLogHealthMetric {
  final int totalAuditRecords;
  final int unadjudicatedBreakGlassCount;
  final bool tamperProofVerified;
  final DateTime lastAuditIntegrityCheck;

  const AuditLogHealthMetric({
    required this.totalAuditRecords,
    required this.unadjudicatedBreakGlassCount,
    required this.tamperProofVerified,
    required this.lastAuditIntegrityCheck,
  });
}

class ProviderHealthMetric {
  final String providerName;
  final ProviderStatus status;
  final int latencyMs;
  final String endpoint;
  final DateTime lastChecked;

  const ProviderHealthMetric({
    required this.providerName,
    required this.status,
    required this.latencyMs,
    required this.endpoint,
    required this.lastChecked,
  });
}

class ObservabilityAlert {
  final String id;
  final DateTime timestamp;
  final AlertSeverity severity;
  final String source;
  final String title;
  final String sanitizedDetails;
  final bool isAcknowledged;

  const ObservabilityAlert({
    required this.id,
    required this.timestamp,
    required this.severity,
    required this.source,
    required this.title,
    required this.sanitizedDetails,
    this.isAcknowledged = false,
  });

  ObservabilityAlert copyWith({bool? isAcknowledged}) {
    return ObservabilityAlert(
      id: id,
      timestamp: timestamp,
      severity: severity,
      source: source,
      title: title,
      sanitizedDetails: sanitizedDetails,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
    );
  }
}
