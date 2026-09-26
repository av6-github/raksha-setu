// lib/features/interventions/presentation/intervention_view_model.dart
// State management for officer support interventions, voluntary choices, and return-to-duty tracking

import 'package:flutter/foundation.dart';
import '../data/intervention_repository.dart';
import '../domain/counselling_booking.dart';
import '../domain/return_to_duty_plan.dart';
import '../domain/support_intervention.dart';

class InterventionViewModel extends ChangeNotifier {
  final IInterventionRepository repository;
  final String officerId;

  List<SupportIntervention> _interventions = [];
  List<CounsellingBooking> _bookings = [];
  ReturnToDutyPlan? _rtdPlan;
  String _commanderDisclosedStatus = 'available';
  bool _isLoading = true;
  String? _errorMessage;

  InterventionViewModel({
    required this.repository,
    required this.officerId,
  }) {
    loadData();
  }

  List<SupportIntervention> get interventions => _interventions;
  List<CounsellingBooking> get bookings => _bookings;
  ReturnToDutyPlan? get rtdPlan => _rtdPlan;
  String get commanderDisclosedStatus => _commanderDisclosedStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _interventions = await repository.getOfficerInterventions(officerId);
      _bookings = await repository.getCounsellingBookings(officerId);
      _rtdPlan = await repository.getReturnToDutyPlan(officerId);
      _commanderDisclosedStatus = await repository.getCommanderDisclosedStatus(officerId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptIntervention(String id) async {
    try {
      final updated = await repository.acceptIntervention(id);
      final idx = _interventions.indexWhere((i) => i.id == id);
      if (idx != -1) {
        _interventions[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> declineIntervention(String id) async {
    try {
      final updated = await repository.declineIntervention(id);
      final idx = _interventions.indexWhere((i) => i.id == id);
      if (idx != -1) {
        _interventions[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> scheduleCounselling({
    required DateTime sessionDate,
    required String sessionType,
    bool isTeleCounselling = false,
  }) async {
    try {
      final booking = await repository.scheduleCounselling(
        officerId: officerId,
        sessionDate: sessionDate,
        sessionType: sessionType,
        isTeleCounselling: isTeleCounselling,
      );
      _bookings.add(booking);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
