// lib/features/commander_dashboard/presentation/commander_view_model.dart
// State management for Commander Unit Overview

import 'package:flutter/foundation.dart';
import '../data/commander_repository.dart';
import '../domain/unit_operational_metrics.dart';
import '../domain/roster_recommendation.dart';

class CommanderViewModel extends ChangeNotifier {
  final ICommanderRepository repository;
  String _selectedUnitCode;

  bool _isLoading = false;
  String? _errorMessage;
  UnitOperationalMetrics? _metrics;
  List<RosterRecommendation> _recommendations = [];
  Map<String, String> _availabilityRoster = {};
  List<Map<String, dynamic>> _unitReports = [];

  CommanderViewModel({
    required this.repository,
    String defaultUnitCode = '12-BN-CHARLIE',
  }) : _selectedUnitCode = defaultUnitCode {
    loadUnitData(_selectedUnitCode);
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedUnitCode => _selectedUnitCode;
  UnitOperationalMetrics? get metrics => _metrics;
  List<RosterRecommendation> get recommendations => _recommendations;
  Map<String, String> get availabilityRoster => _availabilityRoster;
  List<Map<String, dynamic>> get unitReports => _unitReports;

  Future<void> loadUnitData(String unitCode) async {
    _selectedUnitCode = unitCode;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _metrics = await repository.getUnitMetrics(unitCode);
      _recommendations = await repository.getRosterRecommendations(unitCode);
      _availabilityRoster = await repository.getOperationalAvailabilityRoster(unitCode);
      _unitReports = await repository.getUnitReports(unitCode);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acknowledgeReport(String reportId) async {
    try {
      await repository.acknowledgeReport(reportId);
      _unitReports = await repository.getUnitReports(_selectedUnitCode);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> acknowledgeRecommendation(String recId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.acknowledgeRecommendation(recId);
      _recommendations = await repository.getRosterRecommendations(_selectedUnitCode);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> attemptForbiddenClinicalInspection(String officerId) async {
    try {
      await repository.attemptForbiddenClinicalInspection(officerId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
