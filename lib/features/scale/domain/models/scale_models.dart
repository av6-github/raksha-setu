// lib/features/scale/domain/models/scale_models.dart
// Domain models for Phase 21: Multi-Battalion Scaling, Tenant Isolation, Federated Learning, and Gov Cloud Migration

enum TenantIsolationStatus { activeStrict, configuring, auditPending }

class ForceTenant {
  final String forceId; // 'bsf', 'crpf', 'cisf', 'itbp', 'ssb', 'assam_rifles', 'nsg'
  final String forceName;
  final String acronym;
  final int activeBattalionsCount;
  final int totalTroopsCovered;
  final bool rlsPolicyActive;
  final String dedicatedKmsNamespace;
  final TenantIsolationStatus isolationStatus;

  const ForceTenant({
    required this.forceId,
    required this.forceName,
    required this.acronym,
    required this.activeBattalionsCount,
    required this.totalTroopsCovered,
    required this.rlsPolicyActive,
    required this.dedicatedKmsNamespace,
    required this.isolationStatus,
  });
}

class MultiBattalionEntry {
  final String battalionId;
  final String forceId;
  final String unitName;
  final String sector;
  final int activeStrength;
  final String connectivityTier; // 'Broadband Fibre', 'Tactical Satellite VSAT', 'Radio Cellular 4G'
  final bool edgeNodeActive;
  final String onDeviceModelVersion;

  const MultiBattalionEntry({
    required this.battalionId,
    required this.forceId,
    required this.unitName,
    required this.sector,
    required this.activeStrength,
    required this.connectivityTier,
    required this.edgeNodeActive,
    required this.onDeviceModelVersion,
  });
}

enum AggregationAlgorithm { fedAvg, secureAggregator, pkiConsensus }

class FederatedLearningRound {
  final String roundId;
  final int roundNumber;
  final DateTime timestamp;
  final String targetGlobalModel;
  final AggregationAlgorithm algorithm;
  final int participatingEdgeNodes;
  final int totalClientSamples;
  final double epsilonBudget; // Differential privacy epsilon (e.g. 1.2)
  final double deltaBudget; // Differential privacy delta (e.g. 1e-5)
  final double weightDeltaL2Norm;
  final bool zeroRawDataLeakVerified;
  final String status; // 'COMPLETED', 'IN_PROGRESS', 'FAILED'

  const FederatedLearningRound({
    required this.roundId,
    required this.roundNumber,
    required this.timestamp,
    required this.targetGlobalModel,
    required this.algorithm,
    required this.participatingEdgeNodes,
    required this.totalClientSamples,
    required this.epsilonBudget,
    required this.deltaBudget,
    required this.weightDeltaL2Norm,
    required this.zeroRawDataLeakVerified,
    required this.status,
  });
}

class EdgeModelMetadata {
  final String modelId;
  final String modelName;
  final String architecture; // 'Quantized LightGBM INT8' / 'On-Device MobileNet'
  final int modelSizeBytes;
  final double inferenceLatencyMs;
  final bool isEncryptedOnDisk;
  final String sha256Checksum;

  const EdgeModelMetadata({
    required this.modelId,
    required this.modelName,
    required this.architecture,
    required this.modelSizeBytes,
    required this.inferenceLatencyMs,
    required this.isEncryptedOnDisk,
    required this.sha256Checksum,
  });
}

enum MigrationReadiness { readyForMigration, migrationCompleted, inProgress, pendingAudit }

class GovCloudMigrationStatus {
  final String targetCloudProvider; // 'NIC MeghRaj Sovereign Cloud / C-DAC Enclave'
  final String dataSovereigntyZone; // 'IN-WEST-1 (Delhi NCR Data Centre)'
  final bool meityEmpanelled;
  final bool airGappedHsmReady;
  final bool stqcSecurityClearance;
  final bool zeroCrossBorderTransitVerified;
  final MigrationReadiness readiness;
  final int certifiedTroopCapacity;
  final String clearanceCertificateId;

  const GovCloudMigrationStatus({
    required this.targetCloudProvider,
    required this.dataSovereigntyZone,
    required this.meityEmpanelled,
    required this.airGappedHsmReady,
    required this.stqcSecurityClearance,
    required this.zeroCrossBorderTransitVerified,
    required this.readiness,
    required this.certifiedTroopCapacity,
    required this.clearanceCertificateId,
  });

  bool get isFullyCompliant =>
      meityEmpanelled &&
      airGappedHsmReady &&
      stqcSecurityClearance &&
      zeroCrossBorderTransitVerified;
}

class CapacityScalingMetrics {
  final int maxTroopCapacity;
  final int activeRegisteredTroops;
  final int currentConcurrentTps;
  final double p99LatencyMs;
  final int activeWorkerPods;
  final double redisCacheHitRate;
  final double databaseCpuUtilization;

  const CapacityScalingMetrics({
    required this.maxTroopCapacity,
    required this.activeRegisteredTroops,
    required this.currentConcurrentTps,
    required this.p99LatencyMs,
    required this.activeWorkerPods,
    required this.redisCacheHitRate,
    required this.databaseCpuUtilization,
  });
}
