// lib/features/auth/presentation/auth_view_model.dart
// State management for authentication status and user roles

import 'package:flutter/foundation.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/user_role.dart';

class AuthViewModel extends ChangeNotifier {
  final IAuthRepository authRepository;
  AppUser? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  AuthViewModel({required this.authRepository}) {
    _init();
  }

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserRole get currentRole => _currentUser?.role ?? UserRole.unknown;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await authRepository.getCurrentUser();
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    authRepository.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await authRepository.signInWithPassword(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signInAsDemo(UserRole role, {String? customEmail, String? specificOfficerId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    String email = customEmail ?? '${role.name}@raksha.gov.in';
    if (role == UserRole.officer && customEmail == null) {
      email = 'officer1@raksha.gov.in';
    } else if (role == UserRole.welfareOfficer && customEmail == null) {
      email = 'welfare@raksha.gov.in';
    } else if (role == UserRole.family && customEmail == null) {
      email = 'family1@raksha.gov.in';
    }

    try {
      final user = await authRepository.signInWithPassword(email, 'RakshaSecure@2026');
      _currentUser = user;
    } catch (_) {
      // Offline / fallback with exact seeded database records
      String fallbackOfficerId = specificOfficerId ?? '3790a74c-61c7-4e69-9448-eac79eeac022';
      String firstName = 'Vikram';
      String lastName = 'Singh';
      String serviceNumber = 'CRPF-2026-7788';

      if (email.contains('officer2')) {
        fallbackOfficerId = '10ff6159-a26e-420a-9f81-f1b1ec9c39ad';
        firstName = 'Priya';
        lastName = 'Nair';
        serviceNumber = 'CRPF-2022-4421';
      } else if (email.contains('officer3')) {
        fallbackOfficerId = '9ba7cd91-fe4b-46a6-8011-38c183c55e70';
        firstName = 'Arjun';
        lastName = 'Thakur';
        serviceNumber = 'BSF-2018-9932';
      } else if (role == UserRole.commander) {
        firstName = 'Col. Rajesh';
        lastName = 'Sharma';
        serviceNumber = 'CRPF-CMD-001';
      } else if (role == UserRole.counsellor) {
        firstName = 'Dr. Ananya';
        lastName = 'Iyer';
        serviceNumber = 'MED-PSY-102';
      } else if (role == UserRole.welfareOfficer) {
        firstName = 'Insp. Manoj';
        lastName = 'Kumar';
        serviceNumber = 'WLF-DIR-007';
      } else if (role == UserRole.family) {
        firstName = 'Meera';
        lastName = 'Singh';
        serviceNumber = 'FAM-7788';
      }

      _currentUser = AppUser(
        id: 'user-$email',
        email: email,
        role: role,
        officerId: role == UserRole.officer ? fallbackOfficerId : null,
        firstName: firstName,
        lastName: lastName,
        serviceNumber: serviceNumber,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await authRepository.signOut();

    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }
}
