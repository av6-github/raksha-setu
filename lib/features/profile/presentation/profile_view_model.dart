// lib/features/profile/presentation/profile_view_model.dart
// State management for officer profile and self-data review

import 'package:flutter/foundation.dart';
import '../data/profile_repository.dart';
import '../domain/officer_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  final IProfileRepository repository;
  final String officerId;

  OfficerProfile? _profile;
  Map<String, dynamic>? _selfData;
  bool _isLoading = true;
  String? _errorMessage;

  ProfileViewModel({
    required this.repository,
    required this.officerId,
  }) {
    loadProfile();
  }

  OfficerProfile? get profile => _profile;
  Map<String, dynamic>? get selfData => _selfData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await repository.getProfileByOfficerId(officerId);
      _selfData = await repository.getComprehensiveSelfData(officerId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
