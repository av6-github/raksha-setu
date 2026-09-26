// lib/features/welfare_dashboard/presentation/welfare_view_model.dart
// State management for Welfare Officer Console

import 'package:flutter/foundation.dart';
import '../../risk/domain/risk_score.dart';
import '../data/welfare_repository.dart';
import '../domain/pseudonymised_officer.dart';
import '../domain/welfare_escalation.dart';
import '../domain/family_pipeline_item.dart';

class WelfareViewModel extends ChangeNotifier {
  final IWelfareRepository repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<PseudonymisedOfficer> _officers = [];
  List<WelfareEscalation> _escalations = [];
  List<FamilyPipelineItem> _familyItems = [];
  RiskTier? _selectedTierFilter;

  WelfareViewModel({required this.repository}) {
    loadAll();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PseudonymisedOfficer> get officers => _officers;
  List<WelfareEscalation> get escalations => _escalations;
  List<FamilyPipelineItem> get familyItems => _familyItems;
  RiskTier? get selectedTierFilter => _selectedTierFilter;

  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _officers = await repository.getPseudonymisedOfficers(filterTier: _selectedTierFilter);
      _escalations = await repository.getEscalations();
      _familyItems = await repository.getFamilyPipeline();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByTier(RiskTier? tier) async {
    _selectedTierFilter = tier;
    _isLoading = true;
    notifyListeners();

    try {
      _officers = await repository.getPseudonymisedOfficers(filterTier: tier);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logOutreach({
    required String escalationId,
    required OutreachStatus status,
    required String notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.logOutreachAction(
        escalationId: escalationId,
        newStatus: status,
        notes: notes,
      );
      _escalations = await repository.getEscalations();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateFamilyStatus({
    required String itemId,
    required String newStatus,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.updateFamilyItemStatus(itemId: itemId, newStatus: newStatus);
      _familyItems = await repository.getFamilyPipeline();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
