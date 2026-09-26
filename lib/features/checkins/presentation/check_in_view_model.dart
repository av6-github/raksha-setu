// lib/features/checkins/presentation/check_in_view_model.dart
// State management for biweekly check-in submission workflow

import 'package:flutter/foundation.dart';
import '../data/check_in_repository.dart';
import '../domain/check_in_model.dart';

enum CheckInStep { intro, phq2, gad2, sleep, workload, freeText, submitting, done, error }

class CheckInViewModel extends ChangeNotifier {
  final ICheckInRepository repository;
  final String officerId;

  CheckInStep _step = CheckInStep.intro;
  int _phq2Score = 0;
  int _gad2Score = 0;
  int _sleepQualityScore = 3;
  int _workloadScore = 3;
  String? _freeText;
  CheckInModel? _submitted;
  String? _errorMessage;

  CheckInViewModel({
    required this.repository,
    required this.officerId,
  });


  CheckInStep get step => _step;
  int get phq2Score => _phq2Score;
  int get gad2Score => _gad2Score;
  int get sleepQualityScore => _sleepQualityScore;
  int get workloadScore => _workloadScore;
  String? get freeText => _freeText;
  CheckInModel? get submitted => _submitted;
  String? get errorMessage => _errorMessage;
  bool get isElevated => _submitted?.isElevated ?? false;

  void start() {
    _step = CheckInStep.phq2;
    notifyListeners();
  }

  void setPhq2Score(int score) {
    _phq2Score = score.clamp(0, 6);
    _step = CheckInStep.gad2;
    notifyListeners();
  }

  void setGad2Score(int score) {
    _gad2Score = score.clamp(0, 6);
    _step = CheckInStep.sleep;
    notifyListeners();
  }

  void setSleepScore(int score) {
    _sleepQualityScore = score.clamp(1, 5);
    _step = CheckInStep.workload;
    notifyListeners();
  }

  void setWorkloadScore(int score) {
    _workloadScore = score.clamp(1, 5);
    _step = CheckInStep.freeText;
    notifyListeners();
  }

  void setFreeText(String? text) {
    _freeText = text;
  }

  void skipFreeText() {
    _freeText = null;
    _submit();
  }

  Future<void> submitWithText(String? text) async {
    _freeText = text;
    await _submit();
  }

  Future<void> _submit() async {
    _step = CheckInStep.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final checkIn = CheckInModel(
        officerId: officerId,
        phq2Score: _phq2Score,
        gad2Score: _gad2Score,
        sleepQualityScore: _sleepQualityScore,
        workloadScore: _workloadScore,
        freeTextEncrypted: _freeText,
        checkInDate: DateTime.now(),
      );

      _submitted = await repository.submitCheckIn(checkIn);
      _step = CheckInStep.done;
    } catch (e) {
      _errorMessage = e.toString();
      _step = CheckInStep.error;
    }

    notifyListeners();
  }
}
