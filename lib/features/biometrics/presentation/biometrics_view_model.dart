// lib/features/biometrics/presentation/biometrics_view_model.dart
// State management for voluntary wearable telemetry and consent enforcement

import 'package:flutter/foundation.dart';
import '../../consent/data/consent_repository.dart';
import '../data/biometric_repository.dart';
import '../domain/biometric_model.dart';

class BiometricsViewModel extends ChangeNotifier {
  final IBiometricRepository repository;
  final IConsentRepository consentRepository;
  final String officerId;

  List<BiometricModel> _history = [];
  bool _isConsentGranted = false;
  bool _isLoading = true;
  String? _errorMessage;

  BiometricsViewModel({
    required this.repository,
    required this.consentRepository,
    required this.officerId,
  }) {
    loadData();
  }

  List<BiometricModel> get history => _history;
  bool get isConsentGranted => _isConsentGranted;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BiometricModel? get latest => _history.isNotEmpty ? _history.first : null;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final consents = await consentRepository.getConsents(officerId);
      final bioConsent = consents.firstWhere(
        (c) => c.consentType == 'biometrics',
        orElse: () => throw Exception('Consent record missing'),
      );
      _isConsentGranted = bioConsent.isGranted;

      if (_isConsentGranted) {
        _history = await repository.getRecentBiometrics(officerId);
      } else {
        _history = [];
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> grantConsentAndSync() async {
    _isLoading = true;
    notifyListeners();

    try {
      await consentRepository.updateConsent(officerId, 'biometrics', true);
      _isConsentGranted = true;
      _history = await repository.getRecentBiometrics(officerId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> revokeConsentAndPurge() async {
    _isLoading = true;
    notifyListeners();

    try {
      await consentRepository.revokeConsent(officerId, 'biometrics');
      await repository.purgeBiometrics(officerId);
      _isConsentGranted = false;
      _history = [];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
