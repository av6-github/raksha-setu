// lib/features/scale/presentation/scale_view_model.dart
// View model for Phase 21: Multi-Battalion Scaling, Tenant Isolation, Federated Learning, and Multilingual Showcase

import 'package:flutter/foundation.dart';
import '../data/scale_repository.dart';
import '../domain/models/scale_models.dart';

class ScaleViewModel extends ChangeNotifier {
  final IScaleRepository repository;

  bool _isLoading = false;
  String? _error;

  List<ForceTenant> _forces = [];
  List<MultiBattalionEntry> _battalions = [];
  List<FederatedLearningRound> _rounds = [];
  GovCloudMigrationStatus? _migrationStatus;
  CapacityScalingMetrics? _capacity;

  String _forceFilter = 'ALL';
  String _selectedLanguageCode = 'en';

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ForceTenant> get forces => List.unmodifiable(_forces);
  List<MultiBattalionEntry> get battalions {
    if (_forceFilter == 'ALL') return List.unmodifiable(_battalions);
    return _battalions.where((b) => b.forceId == _forceFilter).toList();
  }
  List<FederatedLearningRound> get rounds => List.unmodifiable(_rounds);
  GovCloudMigrationStatus? get migrationStatus => _migrationStatus;
  CapacityScalingMetrics? get capacity => _capacity;

  String get forceFilter => _forceFilter;
  String get selectedLanguageCode => _selectedLanguageCode;

  ScaleViewModel({required this.repository}) {
    loadMetrics();
  }

  void setForceFilter(String forceId) {
    _forceFilter = forceId;
    notifyListeners();
  }

  void setSelectedLanguage(String langCode) {
    _selectedLanguageCode = langCode;
    notifyListeners();
  }

  Future<void> loadMetrics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        repository.getForceTenants(),
        repository.getMultiBattalions(),
        repository.getFederatedLearningRounds(),
        repository.getGovCloudMigrationStatus(),
        repository.getCapacityScalingMetrics(),
      ]);

      _forces = results[0] as List<ForceTenant>;
      _battalions = List<MultiBattalionEntry>.from(results[1] as List<MultiBattalionEntry>);
      _rounds = List<FederatedLearningRound>.from(results[2] as List<FederatedLearningRound>);
      _migrationStatus = results[3] as GovCloudMigrationStatus;
      _capacity = results[4] as CapacityScalingMetrics;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> triggerFederatedRound(String targetGlobalModel) async {
    try {
      final newRound = await repository.triggerFederatedRound(targetGlobalModel: targetGlobalModel);
      _rounds.insert(0, newRound);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
