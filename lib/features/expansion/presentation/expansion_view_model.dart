// lib/features/expansion/presentation/expansion_view_model.dart
// View model for Phase 22: Expansion Sectors, Adaptation Profiles, and Universal Firewall Audit

import 'package:flutter/foundation.dart';
import '../data/expansion_repository.dart';
import '../domain/models/expansion_models.dart';

class ExpansionViewModel extends ChangeNotifier {
  final IExpansionRepository repository;

  bool _isLoading = false;
  String? _error;

  List<SectorProfile> _profiles = [];
  SectorReadinessAudit? _audit;
  SectorProfile? _activeProfile;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<SectorProfile> get profiles => List.unmodifiable(_profiles);
  SectorReadinessAudit? get audit => _audit;
  SectorProfile? get activeProfile => _activeProfile;

  ExpansionViewModel({required this.repository}) {
    loadMetrics();
  }

  Future<void> loadMetrics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        repository.getSectorProfiles(),
        repository.getSectorReadinessAudit(),
        repository.getActiveSector(),
      ]);

      _profiles = results[0] as List<SectorProfile>;
      _audit = results[1] as SectorReadinessAudit;
      _activeProfile = results[2] as SectorProfile;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectSector(ExpansionSector sector) async {
    try {
      await repository.setActiveSector(sector);
      _activeProfile = _profiles.firstWhere((p) => p.sector == sector);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
