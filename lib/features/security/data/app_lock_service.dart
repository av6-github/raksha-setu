// lib/features/security/data/app_lock_service.dart
// Local biometric and PIN app lock management with secure storage persistence

import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../core/security/secure_storage_service.dart';

abstract class IAppLockService {
  Future<bool> isAppLockEnabled();
  Future<void> enableAppLock(String pin);
  Future<void> disableAppLock();
  Future<bool> verifyPin(String pin);
  Future<int> getAutoLockTimeoutMinutes();
  Future<void> setAutoLockTimeoutMinutes(int minutes);
}

class AppLockService implements IAppLockService {
  static const String _keyAppLockEnabled = 'app_lock_enabled_v1';
  static const String _keyPinHash = 'app_lock_pin_hash_v1';
  static const String _keyTimeoutMinutes = 'app_lock_timeout_minutes_v1';

  final ISecureStorageService secureStorage;

  AppLockService({required this.secureStorage});

  @override
  Future<bool> isAppLockEnabled() async {
    final val = await secureStorage.read(_keyAppLockEnabled);
    return val == 'true';
  }

  @override
  Future<void> enableAppLock(String pin) async {
    final hash = _hashPin(pin);
    await secureStorage.write(_keyPinHash, hash);
    await secureStorage.write(_keyAppLockEnabled, 'true');
  }

  @override
  Future<void> disableAppLock() async {
    await secureStorage.write(_keyAppLockEnabled, 'false');
    await secureStorage.delete(_keyPinHash);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final storedHash = await secureStorage.read(_keyPinHash);
    if (storedHash == null) return false;
    return storedHash == _hashPin(pin);
  }

  @override
  Future<int> getAutoLockTimeoutMinutes() async {
    final val = await secureStorage.read(_keyTimeoutMinutes);
    return val != null ? int.tryParse(val) ?? 5 : 5;
  }

  @override
  Future<void> setAutoLockTimeoutMinutes(int minutes) async {
    await secureStorage.write(_keyTimeoutMinutes, minutes.toString());
  }

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode('raksha_salt_2026_$pin')).toString();
  }
}
