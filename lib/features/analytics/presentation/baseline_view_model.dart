// lib/features/analytics/presentation/baseline_view_model.dart
// State management for personal baseline analytics, CUSUM alerts, and aggregate insights

import 'package:flutter/foundation.dart';
import '../data/baseline_repository.dart';
import '../domain/cohort_prior.dart';
import '../domain/deviation_event.dart';
import '../domain/personal_baseline.dart';
import '../domain/unit_aggregate_signal.dart';

class BaselineViewModel extends ChangeNotifier {
  final IBaselineRepository repository;
  final String officerId;
  final String unitId;
  final String unitName;

  PersonalBaseline? _baseline;
  List<DeviationEvent> _deviations = [];
  UnitAggregateSignal? _unitAggregate;
  bool _isLoading = true;
  String? _errorMessage;

  BaselineViewModel({
    required this.repository,
    required this.officerId,
    this.unitId = 'unit-17-rajput',
    this.unitName = '17 Rajputana Rifles',
  }) {
    loadData();
  }

  PersonalBaseline? get baseline => _baseline;
  List<DeviationEvent> get deviations => _deviations;
  UnitAggregateSignal? get unitAggregate => _unitAggregate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final base = await repository.getPersonalBaseline(officerId);
      final devs = await repository.getDeviationEvents(officerId, base);
      final unitSig = await repository.getUnitAggregate(unitId: unitId, unitName: unitName);

      _baseline = base;
      _deviations = devs;
      _unitAggregate = unitSig;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recalibrate({
    required List<double> sleepObs,
    required List<double> dutyObs,
    required List<double> distressObs,
    required CohortPrior cohortPrior,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _baseline = await repository.recalibrateBaseline(
        officerId: officerId,
        sleepObs: sleepObs,
        dutyObs: dutyObs,
        distressObs: distressObs,
        cohortPrior: cohortPrior,
      );
      _deviations = await repository.getDeviationEvents(officerId, _baseline!);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
