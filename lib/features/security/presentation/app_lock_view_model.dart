// lib/features/security/presentation/app_lock_view_model.dart
// State management for local app lock, PIN verification, and timeout settings

import 'package:flutter/foundation.dart';
import '../data/app_lock_service.dart';

class AppLockViewModel extends ChangeNotifier {
  final IAppLockService appLockService;

  bool _isLockEnabled = false;
  int _timeoutMinutes = 5;
  bool _isUnlocked = false;
  bool _isLoading = true;
  String? _errorMessage;

  AppLockViewModel({required this.appLockService}) {
    loadSettings();
  }

  bool get isLockEnabled => _isLockEnabled;
  int get timeoutMinutes => _timeoutMinutes;
  bool get isUnlocked => _isUnlocked;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isLockEnabled = await appLockService.isAppLockEnabled();
      _timeoutMinutes = await appLockService.getAutoLockTimeoutMinutes();
      // If lock is disabled, app is naturally unlocked
      if (!_isLockEnabled) {
        _isUnlocked = true;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setupPin(String pin) async {
    if (pin.length < 4) {
      _errorMessage = 'PIN must be at least 4 digits';
      notifyListeners();
      return false;
    }

    try {
      await appLockService.enableAppLock(pin);
      _isLockEnabled = true;
      _isUnlocked = true;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> disableLock() async {
    try {
      await appLockService.disableAppLock();
      _isLockEnabled = false;
      _isUnlocked = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> unlockWithPin(String pin) async {
    try {
      final isValid = await appLockService.verifyPin(pin);
      if (isValid) {
        _isUnlocked = true;
        _errorMessage = null;
      } else {
        _errorMessage = 'Incorrect PIN. Please try again.';
      }
      notifyListeners();
      return isValid;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void lock() {
    if (_isLockEnabled) {
      _isUnlocked = false;
      notifyListeners();
    }
  }
}
