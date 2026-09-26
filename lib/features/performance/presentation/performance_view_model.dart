// lib/features/performance/presentation/performance_view_model.dart
// Presentation ViewModel managing operational performance, encouraging feedback, and ACR firewall validation

import 'package:flutter/foundation.dart';
import '../data/performance_repository.dart';
import '../domain/acr_context_note.dart';
import '../domain/performance_record.dart';
import '../domain/progress_update.dart';

class PerformanceViewModel extends ChangeNotifier {
  final IPerformanceRepository repository;
  final String officerId;

  List<PerformanceRecord> _records = [];
  PerformanceRecord? _latestRecord;
  List<ProgressUpdate> _progressUpdates = [];
  List<AcrContextNote> _acrNotes = [];
  String? _encouragingFeedback;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  PerformanceViewModel({
    required this.repository,
    required this.officerId,
  });

  List<PerformanceRecord> get records => _records;
  PerformanceRecord? get latestRecord => _latestRecord;
  List<ProgressUpdate> get progressUpdates => _progressUpdates;
  List<AcrContextNote> get acrNotes => _acrNotes;
  String? get encouragingFeedback => _encouragingFeedback;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final recs = await repository.getPerformanceRecords(officerId);
      final updates = await repository.getProgressUpdates(officerId);
      final notes = await repository.getAcrContextNotes(officerId);

      _records = recs;
      _latestRecord = recs.isNotEmpty ? recs.first : null;
      _progressUpdates = updates;
      _acrNotes = notes;

      if (_latestRecord != null) {
        _encouragingFeedback = await repository.getEncouragingFeedback(_latestRecord!);
      }
    } catch (e) {
      _errorMessage = 'Failed to load performance data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAcrContextNote({
    required int reportingPeriodYear,
    required String nonClinicalHrContext,
  }) async {
    _errorMessage = null;
    _successMessage = null;

    final note = AcrContextNote(
      id: 'acr-${DateTime.now().millisecondsSinceEpoch}',
      officerId: officerId,
      reportingPeriodYear: reportingPeriodYear,
      nonClinicalHrContext: nonClinicalHrContext,
      verifiedNoStressData: true,
      createdAt: DateTime.now(),
    );

    try {
      final saved = await repository.createAcrContextNote(note);
      _acrNotes.insert(0, saved);
      _successMessage = 'ACR context note verified & saved under Welfare-HR firewall.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
