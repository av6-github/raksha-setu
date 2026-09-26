// lib/core/storage/encrypted_local_storage_service.dart
// Encrypted Local Database storage using AES-256 for offline mutations and local cached data

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../security/field_encryption_service.dart';

abstract class IEncryptedLocalStorageService {
  Future<void> writeEncrypted(String key, String value);
  Future<String?> readEncrypted(String key);
  Future<void> saveOfflineRecord(String table, String id, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getOfflineRecords(String table);
  Future<void> deleteOfflineRecord(String table, String id);
  Future<void> clearTable(String table);
  Future<void> clearAll();
}

class EncryptedLocalStorageService implements IEncryptedLocalStorageService {
  static const String _keyPrefix = 'raksha_enc_store_v1_';
  final SharedPreferences prefs;
  final FieldEncryptionService encryptionService;

  EncryptedLocalStorageService({
    required this.prefs,
    FieldEncryptionService? encryptionService,
  }) : encryptionService = encryptionService ?? FieldEncryptionService();

  @override
  Future<void> writeEncrypted(String key, String value) async {
    final encrypted = encryptionService.encryptField(value);
    await prefs.setString('$_keyPrefix$key', encrypted);
  }

  @override
  Future<String?> readEncrypted(String key) async {
    final raw = prefs.getString('$_keyPrefix$key');
    if (raw == null) return null;
    return encryptionService.decryptField(raw);
  }

  @override
  Future<void> saveOfflineRecord(String table, String id, Map<String, dynamic> data) async {
    final key = '${table}_records';
    final existingList = await getOfflineRecords(table);

    // Update existing or append new
    final updatedList = List<Map<String, dynamic>>.from(existingList);
    final index = updatedList.indexWhere((r) => r['id'] == id);
    if (index != -1) {
      updatedList[index] = data;
    } else {
      updatedList.add(data);
    }

    final serialized = jsonEncode(updatedList);
    await writeEncrypted(key, serialized);
  }

  @override
  Future<List<Map<String, dynamic>>> getOfflineRecords(String table) async {
    final key = '${table}_records';
    final decrypted = await readEncrypted(key);
    if (decrypted == null || decrypted.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(decrypted);
      if (decoded is List) {
        return decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    } catch (_) {
      // In case of corrupt payload
    }
    return [];
  }

  @override
  Future<void> deleteOfflineRecord(String table, String id) async {
    final key = '${table}_records';
    final existingList = await getOfflineRecords(table);
    final updatedList = existingList.where((r) => r['id'] != id).toList();
    await writeEncrypted(key, jsonEncode(updatedList));
  }

  @override
  Future<void> clearTable(String table) async {
    final key = '${table}_records';
    await prefs.remove('$_keyPrefix$key');
  }

  @override
  Future<void> clearAll() async {
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}
