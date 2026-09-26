// lib/core/security/secure_storage_service.dart
// Encrypted local storage boundary using FlutterSecureStorage

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../logging/app_logger.dart';

abstract class ISecureStorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
  Future<bool> containsKey(String key);
}

class SecureStorageService implements ISecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                resetOnError: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e, st) {
      AppLogger.error('Failed to write to secure storage: $key', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e, st) {
      AppLogger.error('Failed to read from secure storage: $key', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e, st) {
      AppLogger.error('Failed to delete from secure storage: $key', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.info('Cleared all items from secure storage');
    } catch (e, st) {
      AppLogger.error('Failed to deleteAll from secure storage', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      return false;
    }
  }
}
