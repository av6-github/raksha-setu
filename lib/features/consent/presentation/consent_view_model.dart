// lib/features/consent/presentation/consent_view_model.dart
// State management for officer consent and family granular sharing

import 'package:flutter/foundation.dart';
import '../data/consent_repository.dart';
import '../domain/consent_record.dart';
import '../domain/family_consent.dart';

class ConsentViewModel extends ChangeNotifier {
  final IConsentRepository repository;
  final String officerId;

  List<ConsentRecord> _consents = [];
  List<FamilyConsent> _familyConsents = [];
  bool _isLoading = true;
  String? _errorMessage;

  ConsentViewModel({
    required this.repository,
    required this.officerId,
  }) {
    loadConsents();
  }

  List<ConsentRecord> get consents => _consents;
  List<FamilyConsent> get familyConsents => _familyConsents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadConsents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _consents = await repository.getConsents(officerId);
      _familyConsents = await repository.getFamilyConsents(officerId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleConsent(String consentType, bool newValue) async {
    try {
      final updated = await repository.updateConsent(officerId, consentType, newValue);
      final index = _consents.indexWhere((c) => c.consentType == consentType);
      if (index != -1) {
        _consents[index] = updated;
      } else {
        _consents.add(updated);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> revokeConsent(String consentType) async {
    await toggleConsent(consentType, false);
  }

  Future<void> toggleFamilyFlashNotifications(String familyConsentId, bool newValue) async {
    final index = _familyConsents.indexWhere((c) => c.id == familyConsentId);
    if (index != -1) {
      final updated = _familyConsents[index].copyWith(shareFlashNotifications: newValue);
      _familyConsents[index] = await repository.updateFamilyConsent(updated);
      notifyListeners();
    }
  }

  Future<void> toggleFamilyMoraleMessages(String familyConsentId, bool newValue) async {
    final index = _familyConsents.indexWhere((c) => c.id == familyConsentId);
    if (index != -1) {
      final updated = _familyConsents[index].copyWith(shareMoraleMessages: newValue);
      _familyConsents[index] = await repository.updateFamilyConsent(updated);
      notifyListeners();
    }
  }

  Future<void> updateNotificationWindow(String familyConsentId, String start, String end) async {
    final index = _familyConsents.indexWhere((c) => c.id == familyConsentId);
    if (index != -1) {
      final updated = _familyConsents[index].copyWith(
        notificationWindowStart: start,
        notificationWindowEnd: end,
      );
      _familyConsents[index] = await repository.updateFamilyConsent(updated);
      notifyListeners();
    }
  }
}
