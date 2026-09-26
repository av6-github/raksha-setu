// lib/features/hrms/domain/organisational_signal.dart
// Computes aggregated organizational friction signals from read-only HRMS inputs

import 'deployment_record.dart';
import 'duty_record.dart';
import 'leave_record.dart';

class OrganisationalSignal {
  final String officerId;
  final int leaveApplicationsCount;
  final int operationalLeaveDenials;
  final int currentConsecutiveDutyDays;
  final int highHardshipMonths;
  final double frictionIndex; // 0.0 (low friction) to 1.0 (high systemic stress)
  final List<String> contributingFactors;

  const OrganisationalSignal({
    required this.officerId,
    required this.leaveApplicationsCount,
    required this.operationalLeaveDenials,
    required this.currentConsecutiveDutyDays,
    required this.highHardshipMonths,
    required this.frictionIndex,
    required this.contributingFactors,
  });

  factory OrganisationalSignal.compute({
    required String officerId,
    required List<LeaveRecord> leaves,
    required List<DeploymentRecord> deployments,
    required List<DutyRecord> dutyRecords,
  }) {
    // 1. Leave friction
    final operationalDenials = leaves.where((l) => l.status == 'rejected' && l.isOperationalRejection).length;

    // 2. Continuous duty fatigue
    final latestDuty = dutyRecords.isNotEmpty ? dutyRecords.first : null;
    final consecutiveDays = latestDuty?.consecutiveDaysOnDuty ?? 0;

    // 3. High hardship deployment duration
    int hardshipMonths = 0;
    for (final d in deployments) {
      if (d.isHighHazard || d.hardshipScore >= 7) {
        hardshipMonths += d.durationMonths;
      }
    }

    final factors = <String>[];
    double score = 0.1; // baseline

    if (operationalDenials > 0) {
      score += 0.25 * operationalDenials;
      factors.add('$operationalDenials operational leave rejection(s) due to force commitments');
    }

    if (consecutiveDays >= 14) {
      score += 0.35;
      factors.add('$consecutiveDays consecutive days on duty without mandatory rest turn');
    } else if (consecutiveDays >= 7) {
      score += 0.15;
      factors.add('$consecutiveDays consecutive duty days');
    }

    if (hardshipMonths >= 12) {
      score += 0.25;
      factors.add('$hardshipMonths months sustained in high-hazard / border hardship deployment');
    }

    return OrganisationalSignal(
      officerId: officerId,
      leaveApplicationsCount: leaves.length,
      operationalLeaveDenials: operationalDenials,
      currentConsecutiveDutyDays: consecutiveDays,
      highHardshipMonths: hardshipMonths,
      frictionIndex: score.clamp(0.0, 1.0),
      contributingFactors: factors.isEmpty ? ['Normal operational deployment rhythm'] : factors,
    );
  }
}
