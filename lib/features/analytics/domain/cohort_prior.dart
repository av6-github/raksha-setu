// lib/features/analytics/domain/cohort_prior.dart
// Normative cohort priors for new-joiner cold start and Bayesian shrinkage

class CohortPrior {
  final String cohortType; // e.g. 'general_duty', 'high_altitude_border', 'peace_station'
  final double sleepHoursMean;
  final double sleepHoursStd;
  final double dutyHoursMean;
  final double dutyHoursStd;
  final double checkInDistressMean;
  final double checkInDistressStd;
  final int pseudoCount; // Prior strength n0 (default 14 days)

  const CohortPrior({
    required this.cohortType,
    required this.sleepHoursMean,
    required this.sleepHoursStd,
    required this.dutyHoursMean,
    required this.dutyHoursStd,
    required this.checkInDistressMean,
    required this.checkInDistressStd,
    this.pseudoCount = 14,
  });

  /// Default baseline for general operational personnel
  factory CohortPrior.generalDuty() {
    return const CohortPrior(
      cohortType: 'general_duty',
      sleepHoursMean: 6.8,
      sleepHoursStd: 1.1,
      dutyHoursMean: 9.5,
      dutyHoursStd: 2.0,
      checkInDistressMean: 1.5,
      checkInDistressStd: 1.2,
      pseudoCount: 14,
    );
  }

  /// High-hazard / border outpost deployment prior
  factory CohortPrior.highAltitudeBorder() {
    return const CohortPrior(
      cohortType: 'high_altitude_border',
      sleepHoursMean: 6.2,
      sleepHoursStd: 1.3,
      dutyHoursMean: 11.5,
      dutyHoursStd: 2.5,
      checkInDistressMean: 2.2,
      checkInDistressStd: 1.4,
      pseudoCount: 14,
    );
  }

  /// Static or peace station posting prior
  factory CohortPrior.peaceStation() {
    return const CohortPrior(
      cohortType: 'peace_station',
      sleepHoursMean: 7.4,
      sleepHoursStd: 0.9,
      dutyHoursMean: 8.0,
      dutyHoursStd: 1.2,
      checkInDistressMean: 1.0,
      checkInDistressStd: 0.8,
      pseudoCount: 14,
    );
  }

  /// Resolves appropriate prior based on officer's current deployment or role
  factory CohortPrior.forContext({bool isHighHazard = false, bool isFieldPosting = true}) {
    if (isHighHazard) return CohortPrior.highAltitudeBorder();
    if (isFieldPosting) return CohortPrior.generalDuty();
    return CohortPrior.peaceStation();
  }
}
