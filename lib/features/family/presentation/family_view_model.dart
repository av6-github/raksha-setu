// lib/features/family/presentation/family_view_model.dart
// State management for Family Portal and Morale Vault

import 'package:flutter/foundation.dart';
import '../data/family_repository.dart';
import '../domain/family_member.dart';
import '../domain/morale_vault_item.dart';
import '../domain/family_training_module.dart';

class FamilyViewModel extends ChangeNotifier {
  final IFamilyRepository repository;
  final String officerId;
  final String currentFamilyMemberId;
  final String currentFamilyMemberName;

  bool _isLoading = false;
  String? _errorMessage;
  String? _callHomeStatusMessage;
  List<FamilyMember> _familyMembers = [];
  List<MoraleVaultItem> _moraleItems = [];
  List<FamilyTrainingModule> _trainingModules = [];
  MoraleVaultItem? _lastUploadedMedia;

  FamilyViewModel({
    required this.repository,
    this.officerId = 'mock-officer-uuid-001',
    this.currentFamilyMemberId = 'fam-member-001',
    this.currentFamilyMemberName = 'Ananya (Spouse)',
  }) {
    loadAll();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get callHomeStatusMessage => _callHomeStatusMessage;
  List<FamilyMember> get familyMembers => _familyMembers;
  List<MoraleVaultItem> get moraleItems => _moraleItems;
  List<FamilyTrainingModule> get trainingModules => _trainingModules;
  MoraleVaultItem? get lastUploadedMedia => _lastUploadedMedia;

  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _familyMembers = await repository.getFamilyMembers(officerId);
      _moraleItems = await repository.getMoraleVaultItems(officerId, includeQuarantined: true);
      _trainingModules = await repository.getTrainingModules();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<MoraleVaultItem?> uploadMedia({
    required String mediaType,
    required String mediaUrl,
    required String caption,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final item = await repository.uploadMoraleMedia(
        officerId: officerId,
        familyMemberId: currentFamilyMemberId,
        familyMemberName: currentFamilyMemberName,
        mediaType: mediaType,
        mediaUrl: mediaUrl,
        transcriptOrCaption: caption,
      );
      _lastUploadedMedia = item;
      _moraleItems = await repository.getMoraleVaultItems(officerId, includeQuarantined: true);
      return item;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> triggerCallHomePrompt({DateTime? simulatedTime}) async {
    _isLoading = true;
    _callHomeStatusMessage = null;
    notifyListeners();

    try {
      final time = simulatedTime ?? DateTime.now();
      final success = await repository.sendCallHomePrompt(
        officerId: officerId,
        familyMemberId: currentFamilyMemberId,
        timestamp: time,
      );

      if (success) {
        _callHomeStatusMessage = 'Call-Home reminder sent! Your officer will receive it during their rest window.';
      } else {
        _callHomeStatusMessage = 'Call-Home reminder held: Outside designated quiet hours or consent paused.';
      }
      return success;
    } catch (e) {
      _callHomeStatusMessage = 'Could not send reminder: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> revokeConsent(String familyMemberId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.revokeFamilyConsent(
        officerId: officerId,
        familyMemberId: familyMemberId,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
