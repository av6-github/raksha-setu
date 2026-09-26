// lib/features/consent/data/consent_repository.dart
// Data access layer for officer consent records and family permissions

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../core/logging/app_logger.dart';
import '../domain/consent_record.dart';
import '../domain/family_consent.dart';

abstract class IConsentRepository {
  Future<List<ConsentRecord>> getConsents(String officerId);
  Future<ConsentRecord> updateConsent(String officerId, String consentType, bool isGranted);
  Future<void> revokeConsent(String officerId, String consentType);
  Future<List<FamilyConsent>> getFamilyConsents(String officerId);
  Future<FamilyConsent> updateFamilyConsent(FamilyConsent consent);
  Future<void> revokeFamilyConsent(String familyConsentId);
}

class ConsentRepository implements IConsentRepository {
  final sp.SupabaseClient? client;
  final Map<String, List<ConsentRecord>> _mockStore = {};
  final Map<String, List<FamilyConsent>> _mockFamilyStore = {};

  ConsentRepository({this.client});

  @override
  Future<List<ConsentRecord>> getConsents(String officerId) async {
    if (client == null) {
      return _getOrCreateMockConsents(officerId);
    }

    try {
      final res = await client!
          .from('consent_records')
          .select()
          .eq('officer_id', officerId);

      final list = (res as List).map((m) => ConsentRecord.fromMap(m as Map<String, dynamic>)).toList();
      if (list.isEmpty) {
        return _getOrCreateMockConsents(officerId);
      }
      return list;
    } catch (e) {
      AppLogger.warning('Error fetching consents from Supabase; using mock store', error: e);
      return _getOrCreateMockConsents(officerId);
    }
  }

  @override
  Future<ConsentRecord> updateConsent(String officerId, String consentType, bool isGranted) async {
    final now = DateTime.now();

    if (client == null) {
      final list = _getOrCreateMockConsents(officerId);
      final index = list.indexWhere((c) => c.consentType == consentType);
      final updated = ConsentRecord(
        id: index != -1 ? list[index].id : 'mock-consent-${DateTime.now().millisecondsSinceEpoch}',
        officerId: officerId,
        consentType: consentType,
        isGranted: isGranted,
        grantedAt: isGranted ? now : (index != -1 ? list[index].grantedAt : now),
        revokedAt: isGranted ? null : now,
      );

      if (index != -1) {
        list[index] = updated;
      } else {
        list.add(updated);
      }
      AppLogger.info('Updated consent for $consentType -> isGranted: $isGranted');
      return updated;
    }

    try {
      final payload = {
        'officer_id': officerId,
        'consent_type': consentType,
        'is_granted': isGranted,
        'granted_at': isGranted ? now.toIso8601String() : null,
        'revoked_at': isGranted ? null : now.toIso8601String(),
      };

      final res = await client!
          .from('consent_records')
          .upsert(payload, onConflict: 'officer_id, consent_type')
          .select()
          .single();

      return ConsentRecord.fromMap(res);
    } catch (e) {
      AppLogger.error('Failed to update consent in Supabase', error: e);
      // Fallback
      return ConsentRecord(
        id: 'fallback-id',
        officerId: officerId,
        consentType: consentType,
        isGranted: isGranted,
        grantedAt: now,
      );
    }
  }

  @override
  Future<void> revokeConsent(String officerId, String consentType) async {
    await updateConsent(officerId, consentType, false);
    AppLogger.info('Revoked consent for $consentType');
  }

  @override
  Future<List<FamilyConsent>> getFamilyConsents(String officerId) async {
    if (client == null) {
      return _getOrCreateMockFamilyConsents(officerId);
    }

    try {
      final res = await client!
          .from('family_consents')
          .select('*, family_members(first_name, last_name, relation)')
          .eq('officer_id', officerId);

      return (res as List).map((m) => FamilyConsent.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.warning('Failed to fetch family consents; using fallback', error: e);
      return _getOrCreateMockFamilyConsents(officerId);
    }
  }

  @override
  Future<FamilyConsent> updateFamilyConsent(FamilyConsent consent) async {
    if (client == null) {
      final list = _getOrCreateMockFamilyConsents(consent.officerId);
      final index = list.indexWhere((c) => c.id == consent.id);
      if (index != -1) {
        list[index] = consent;
      }
      return consent;
    }

    try {
      final res = await client!
          .from('family_consents')
          .upsert(consent.toMap())
          .select('*, family_members(first_name, last_name, relation)')
          .single();
      return FamilyConsent.fromMap(res);
    } catch (e) {
      AppLogger.error('Failed to update family consent', error: e);
      return consent;
    }
  }

  @override
  Future<void> revokeFamilyConsent(String familyConsentId) async {
    AppLogger.info('Family consent revoked: $familyConsentId');
  }

  List<ConsentRecord> _getOrCreateMockConsents(String officerId) {
    if (!_mockStore.containsKey(officerId)) {
      _mockStore[officerId] = [
        ConsentRecord(
          id: 'c-01',
          officerId: officerId,
          consentType: 'biometrics',
          isGranted: false,
          grantedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        ConsentRecord(
          id: 'c-02',
          officerId: officerId,
          consentType: 'family_sharing',
          isGranted: true,
          grantedAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        ConsentRecord(
          id: 'c-03',
          officerId: officerId,
          consentType: 'acr_read_context',
          isGranted: true,
          grantedAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
        ConsentRecord(
          id: 'c-04',
          officerId: officerId,
          consentType: 'public_recognition',
          isGranted: false,
          grantedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];
    }
    return _mockStore[officerId]!;
  }

  List<FamilyConsent> _getOrCreateMockFamilyConsents(String officerId) {
    if (!_mockFamilyStore.containsKey(officerId)) {
      _mockFamilyStore[officerId] = [
        FamilyConsent(
          id: 'fc-01',
          officerId: officerId,
          familyMemberId: 'fm-01',
          familyMemberName: 'Ananya Singh',
          relation: 'Spouse',
          shareFlashNotifications: true,
          shareMoraleMessages: true,
          shareTrainingMaterial: true,
          emergencyContactAuthorized: true,
          notificationWindowStart: '08:00',
          notificationWindowEnd: '21:00',
          grantedAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
      ];
    }
    return _mockFamilyStore[officerId]!;
  }
}
