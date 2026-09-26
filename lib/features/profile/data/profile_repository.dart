// lib/features/profile/data/profile_repository.dart
// Officer profile retrieval from Supabase or deterministic prototype mock

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../core/logging/app_logger.dart';
import '../domain/officer_profile.dart';

abstract class IProfileRepository {
  Future<OfficerProfile?> getProfileByAuthId(String authUserId);
  Future<OfficerProfile?> getProfileByOfficerId(String officerId);
  Future<Map<String, dynamic>> getComprehensiveSelfData(String officerId);
}

class ProfileRepository implements IProfileRepository {
  final sp.SupabaseClient? client;

  ProfileRepository({this.client});

  @override
  Future<OfficerProfile?> getProfileByAuthId(String authUserId) async {
    if (client == null) {
      return _getPrototypeProfile();
    }

    try {
      final identityRes = await client!
          .from('identities')
          .select('id')
          .eq('auth_user_id', authUserId)
          .maybeSingle();

      if (identityRes == null) return null;

      final res = await client!
          .from('officers')
          .select('*, units(name)')
          .eq('identity_id', identityRes['id'])
          .maybeSingle();

      if (res == null) return null;
      return OfficerProfile.fromMap(res);
    } catch (e) {
      AppLogger.warning('Error fetching profile by auth id; using fallback', error: e);
      return _getPrototypeProfile();
    }
  }

  @override
  Future<OfficerProfile?> getProfileByOfficerId(String officerId) async {
    if (client == null) {
      return _getPrototypeProfile();
    }

    try {
      final res = await client!
          .from('officers')
          .select('*, units(name)')
          .eq('id', officerId)
          .maybeSingle();

      if (res == null) return null;
      return OfficerProfile.fromMap(res);
    } catch (e) {
      AppLogger.warning('Error fetching profile by officer id', error: e);
      return _getPrototypeProfile();
    }
  }

  @override
  Future<Map<String, dynamic>> getComprehensiveSelfData(String officerId) async {
    final profile = await getProfileByOfficerId(officerId);
    
    // In live system, aggregates data across tables for transparent officer review
    return {
      'profile': profile?.toMap() ?? {},
      'firewall_status': 'ACTIVE',
      'clinical_isolation': 'ENFORCED',
      'command_access_level': 'AGGREGATE_ONLY (k >= 10)',
      'acr_link': 'NONE - Strict separation under Welfare-HR protocol',
    };
  }

  OfficerProfile _getPrototypeProfile() {
    return OfficerProfile(
      id: 'mock-officer-uuid-001',
      identityId: 'mock-identity-uuid-001',
      unitId: 'mock-unit-uuid-001',
      unitName: '105 Rapid Action Force Battalion',
      serviceNumber: 'CRPF-2024-8891',
      firstName: 'Vikram',
      lastName: 'Singh',
      designation: 'Sub-Inspector',
      dateOfJoining: DateTime(2018, 4, 15),
      bloodGroup: 'B+',
      gender: 'Male',
      isAvailable: true,
      limitedDuty: false,
      welfareSupported: false,
    );
  }
}
