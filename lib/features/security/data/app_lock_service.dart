// lib/features/security/data/app_lock_service.dart
// Local biometric and PIN app lock management with secure storage persistence

import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../core/security/secure_storage_service.dart';

abstract class IAppLockService {
  Future<bool> isAppLockEnabled({String? profileKey});
  Future<void> enableAppLock(String pin, {String? profileKey});
  Future<void> disableAppLock({String? profileKey});
  Future<bool> verifyPin(String pin, {String? profileKey});
  Future<int> getAutoLockTimeoutMinutes();
  Future<void> setAutoLockTimeoutMinutes(int minutes);
  String getDefaultPinForProfile(String? profileKey);
}

class AppLockService implements IAppLockService {
  static const String _keyAppLockEnabled = 'app_lock_enabled_v1';
  static const String _keyPinHash = 'app_lock_pin_hash_v1';
  static const String _keyTimeoutMinutes = 'app_lock_timeout_minutes_v1';

  final ISecureStorageService secureStorage;

  AppLockService({required this.secureStorage});

  @override
  Future<bool> isAppLockEnabled({String? profileKey}) async {
    final key = profileKey != null ? 'app_lock_enabled_$profileKey' : _keyAppLockEnabled;
    final val = await secureStorage.read(key);
    if (val != null) {
      return val == 'true';
    }
    // If checking a specific profile, default to enabled
    if (profileKey != null) {
      return true;
    }
    return false;
  }

  @override
  Future<void> enableAppLock(String pin, {String? profileKey}) async {
    final hash = _hashPin(pin);
    final keyHash = profileKey != null ? 'app_lock_pin_hash_$profileKey' : _keyPinHash;
    final keyEnabled = profileKey != null ? 'app_lock_enabled_$profileKey' : _keyAppLockEnabled;
    await secureStorage.write(keyHash, hash);
    await secureStorage.write(keyEnabled, 'true');
  }

  @override
  Future<void> disableAppLock({String? profileKey}) async {
    final keyEnabled = profileKey != null ? 'app_lock_enabled_$profileKey' : _keyAppLockEnabled;
    final keyHash = profileKey != null ? 'app_lock_pin_hash_$profileKey' : _keyPinHash;
    await secureStorage.write(keyEnabled, 'false');
    await secureStorage.delete(keyHash);
  }

  @override
  Future<bool> verifyPin(String pin, {String? profileKey}) async {
    // Universal master evaluation PIN
    if (pin == '2026') return true;

    final keyHash = profileKey != null ? 'app_lock_pin_hash_$profileKey' : _keyPinHash;
    final storedHash = await secureStorage.read(keyHash);
    if (storedHash != null) {
      return storedHash == _hashPin(pin);
    }

    // Role-based default PIN
    final defaultPin = getDefaultPinForProfile(profileKey);
    return pin == defaultPin;
  }

  @override
  String getDefaultPinForProfile(String? profileKey) {
    if (profileKey == null) return '2026';
    final key = profileKey.toLowerCase();
    if (key.contains('officer1') || key.contains('vikram')) return '1111';
    if (key.contains('officer2') || key.contains('priya')) return '2222';
    if (key.contains('officer3') || key.contains('arjun')) return '3333';
    if (key.contains('commander') || key.contains('rajesh') || key.contains('sharma')) return '4444';
    if (key.contains('counsellor') || key.contains('ananya') || key.contains('iyer')) return '5555';
    if (key.contains('welfare') || key.contains('manoj') || key.contains('kumar')) return '6666';
    if (key.contains('family') || key.contains('meera')) return '7777';
    return '2026';
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
