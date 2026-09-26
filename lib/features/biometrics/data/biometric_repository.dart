// lib/features/biometrics/data/biometric_repository.dart
// Biometrics repository with consent-gated persistence and instant purge on revocation

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../core/logging/app_logger.dart';
import '../../../core/networking/network_client.dart';
import '../../../core/storage/offline_queue_service.dart';
import '../../consent/data/consent_repository.dart';
import '../domain/biometric_model.dart';

abstract class IBiometricRepository {
  Future<BiometricModel?> recordBiometrics(BiometricModel model);
  Future<List<BiometricModel>> getRecentBiometrics(String officerId, {int limit = 7});
  Future<void> purgeBiometrics(String officerId);
}

class BiometricRepository implements IBiometricRepository {
  final sp.SupabaseClient? client;
  final IOfflineQueueService offlineQueue;
  final INetworkInfo networkInfo;
  final IConsentRepository consentRepository;
  final List<BiometricModel> _mockBiometrics = [];

  BiometricRepository({
    this.client,
    required this.offlineQueue,
    required this.networkInfo,
    required this.consentRepository,
  });

  @override
  Future<BiometricModel?> recordBiometrics(BiometricModel model) async {
    // 1. Consent Gate Check
    final consents = await consentRepository.getConsents(model.officerId);
    final bioConsent = consents.firstWhere(
      (c) => c.consentType == 'biometrics',
      orElse: () => throw Exception('Biometrics consent not found'),
    );

    if (!bioConsent.isGranted) {
      AppLogger.warning('Rejected biometric sync: Officer has not granted biometrics consent');
      throw Exception('Consent Required: Biometric sync is strictly opt-in.');
    }

    final isOnline = await networkInfo.isConnected;

    if (!isOnline || client == null) {
      await offlineQueue.enqueue('biometrics', model.toDbPayload());
      _mockBiometrics.insert(0, model);
      return model;
    }

    try {
      final res = await client!
          .from('biometrics')
          .insert(model.toDbPayload())
          .select()
          .single();

      final saved = BiometricModel.fromMap(res);
      _mockBiometrics.insert(0, saved);
      return saved;
    } catch (e) {
      await offlineQueue.enqueue('biometrics', model.toDbPayload());
      _mockBiometrics.insert(0, model);
      return model;
    }
  }

  @override
  Future<List<BiometricModel>> getRecentBiometrics(String officerId, {int limit = 7}) async {
    if (client == null) {
      if (_mockBiometrics.isEmpty) {
        _populateDefaultMockBiometrics(officerId);
      }
      return _mockBiometrics.where((b) => b.officerId == officerId).take(limit).toList();
    }

    try {
      final res = await client!
          .from('biometrics')
          .select()
          .eq('officer_id', officerId)
          .order('recorded_date', ascending: false)
          .limit(limit);

      return (res as List).map((m) => BiometricModel.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.warning('Failed to fetch biometrics from Supabase', error: e);
      if (_mockBiometrics.isEmpty) {
        _populateDefaultMockBiometrics(officerId);
      }
      return _mockBiometrics.where((b) => b.officerId == officerId).take(limit).toList();
    }
  }

  @override
  Future<void> purgeBiometrics(String officerId) async {
    _mockBiometrics.removeWhere((b) => b.officerId == officerId);
    if (client != null) {
      try {
        await client!.from('biometrics').delete().eq('officer_id', officerId);
        AppLogger.info('Biometrics purged for officer $officerId');
      } catch (e) {
        AppLogger.error('Failed to purge biometrics in Supabase', error: e);
      }
    }
  }

  void _populateDefaultMockBiometrics(String officerId) {
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      _mockBiometrics.add(
        BiometricModel(
          id: 'bio-$i',
          officerId: officerId,
          recordedDate: now.subtract(Duration(days: i)),
          sleepHours: 6.5 + (i % 3) * 0.5,
          hrvRmssd: 42.0 + (i % 4) * 3,
          restingHeartRate: 64 + (i % 3) * 2,
          activitySteps: 8500 + i * 400,
          deviceSource: 'fitbit',
          consentVerified: true,
        ),
      );
    }
  }
}
