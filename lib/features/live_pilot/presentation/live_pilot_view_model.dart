// lib/features/live_pilot/presentation/live_pilot_view_model.dart
// State management for Phase 20 Live Pilot, Control Unit Comparisons, Incident Logs, and Scale Certification

import 'package:flutter/foundation.dart';
import '../data/live_pilot_repository.dart';
import '../domain/models/live_pilot_models.dart';

class LivePilotViewModel extends ChangeNotifier {
  final ILivePilotRepository repository;

  bool _isLoading = false;
  String? _error;

  List<BattalionUnit> _units = [];
  PilotVsControlComparison? _comparison;
  List<LiveIncidentLog> _incidents = [];
  List<LiveTrustMeasurement> _trustMeasurements = [];
  LivePilotCertification? _certification;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BattalionUnit> get units => List.unmodifiable(_units);
  PilotVsControlComparison? get comparison => _comparison;
  List<LiveIncidentLog> get incidents => List.unmodifiable(_incidents);
  List<LiveTrustMeasurement> get trustMeasurements => List.unmodifiable(_trustMeasurements);
  LivePilotCertification? get certification => _certification;

  LivePilotViewModel({required this.repository}) {
    loadMetrics();
  }

  Future<void> loadMetrics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        repository.getBattalionUnits(),
        repository.getPilotVsControlComparison(),
        repository.getLiveIncidents(),
        repository.getTrustMeasurements(),
        repository.getScaleCertification(),
      ]);

      _units = results[0] as List<BattalionUnit>;
      _comparison = results[1] as PilotVsControlComparison;
      _incidents = List<LiveIncidentLog>.from(results[2] as List<LiveIncidentLog>);
      _trustMeasurements = results[3] as List<LiveTrustMeasurement>;
      _certification = results[4] as LivePilotCertification;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resolveIncident(String incidentId, String notes) async {
    try {
      await repository.resolveIncident(incidentId, notes);
      final index = _incidents.indexWhere((i) => i.incidentId == incidentId);
      if (index != -1) {
        _incidents[index] = _incidents[index].copyWith(
          isResolved: true,
          resolutionNotes: notes,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
