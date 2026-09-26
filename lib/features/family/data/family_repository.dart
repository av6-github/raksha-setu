// lib/features/family/data/family_repository.dart
// Family support and Morale Vault data repository with OPSEC scanning,
// granular consent, and live connection to Supabase family_members and consents

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../core/logging/app_logger.dart';
import '../domain/family_member.dart';
import '../domain/family_consent.dart';
import '../domain/morale_vault_item.dart';
import '../domain/opsec_filter.dart';
import '../domain/family_training_module.dart';

abstract class IFamilyRepository {
  Future<List<FamilyMember>> getFamilyMembers(String officerId);
  Future<FamilyMember> inviteFamilyMember({
    required String officerId,
    required String relation,
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    bool isEmergencyContact = false,
  });
  Future<FamilyConsent> getFamilyConsent({
    required String officerId,
    required String familyMemberId,
  });
  Future<void> updateFamilyConsent(FamilyConsent consent);
  Future<void> revokeFamilyConsent({
    required String officerId,
    required String familyMemberId,
  });
  Future<List<MoraleVaultItem>> getMoraleVaultItems(
    String officerId, {
    bool includeQuarantined = false,
  });
  Future<MoraleVaultItem> uploadMoraleMedia({
    required String officerId,
    required String familyMemberId,
    required String familyMemberName,
    required String mediaType,
    required String mediaUrl,
    required String transcriptOrCaption,
    Map<String, dynamic>? metadata,
  });
  Future<void> reviewQuarantinedMedia({
    required String mediaId,
    required MoraleMediaSecurityStatus decision,
    required String reviewerId,
    String? notes,
  });
  Future<bool> sendCallHomePrompt({
    required String officerId,
    required String familyMemberId,
    required DateTime timestamp,
  });
  Future<List<FamilyTrainingModule>> getTrainingModules();
}

class FamilyRepository implements IFamilyRepository {
  final sp.SupabaseClient? client;

  final List<FamilyMember> _mockMembers = [
    FamilyMember(
      id: 'fam-member-001',
      officerId: 'mock-officer-uuid-001',
      relation: 'spouse',
      firstName: 'Ananya',
      lastName: 'Singh',
      phone: '+91 98765 43210',
      email: 'ananya.singh@example.com',
      isEmergencyContact: true,
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    FamilyMember(
      id: 'fam-member-002',
      officerId: 'mock-officer-uuid-001',
      relation: 'parent',
      firstName: 'Col (Retd) Raghuveer',
      lastName: 'Singh',
      phone: '+91 98765 43212',
      email: null,
      isEmergencyContact: false,
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    FamilyMember(
      id: 'fam-member-003',
      officerId: '3790a74c-61c7-4e69-9448-eac79eeac022',
      relation: 'spouse',
      firstName: 'Meera',
      lastName: 'Singh',
      phone: '+91 98765 43210',
      email: 'family1@raksha.gov.in',
      isEmergencyContact: true,
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
  ];

  final Map<String, FamilyConsent> _mockConsents = {
    'mock-officer-uuid-001:fam-member-001': FamilyConsent(
      id: 'consent-001',
      officerId: 'mock-officer-uuid-001',
      familyMemberId: 'fam-member-001',
      shareFlashNotifications: true,
      shareMoraleMessages: true,
      shareTrainingMaterial: true,
      emergencyContactAuthorized: true,
      notificationWindowStartHour: 18,
      notificationWindowEndHour: 22,
      isRevoked: false,
      grantedAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    'mock-officer-uuid-001:fam-member-002': FamilyConsent(
      id: 'consent-002',
      officerId: 'mock-officer-uuid-001',
      familyMemberId: 'fam-member-002',
      shareFlashNotifications: false,
      shareMoraleMessages: true,
      shareTrainingMaterial: true,
      emergencyContactAuthorized: true,
      notificationWindowStartHour: 10,
      notificationWindowEndHour: 14,
      isRevoked: false,
      grantedAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    '3790a74c-61c7-4e69-9448-eac79eeac022:fam-member-003': FamilyConsent(
      id: 'consent-003',
      officerId: '3790a74c-61c7-4e69-9448-eac79eeac022',
      familyMemberId: 'fam-member-003',
      shareFlashNotifications: true,
      shareMoraleMessages: true,
      shareTrainingMaterial: true,
      emergencyContactAuthorized: true,
      notificationWindowStartHour: 18,
      notificationWindowEndHour: 22,
      isRevoked: false,
      grantedAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
  };

  final List<MoraleVaultItem> _mockMedia = [
    MoraleVaultItem(
      id: 'media-001',
      officerId: 'mock-officer-uuid-001',
      familyMemberId: 'fam-member-001',
      familyMemberName: 'Ananya (Spouse)',
      mediaUrl: 'https://cloudinary.example.com/audio/morale_voice_note_1.mp3',
      mediaType: 'audio',
      securityStatus: MoraleMediaSecurityStatus.safe,
      transcriptOrCaption: 'Proud of you always. Kids made a drawing for you today and send their love!',
      opsecFlags: const [],
      uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    MoraleVaultItem(
      id: 'media-002',
      officerId: 'mock-officer-uuid-001',
      familyMemberId: 'fam-member-001',
      familyMemberName: 'Ananya (Spouse)',
      mediaUrl: 'https://cloudinary.example.com/video/family_annual_day.mp4',
      mediaType: 'video',
      securityStatus: MoraleMediaSecurityStatus.humanApproved,
      transcriptOrCaption: 'Aarav playing piano at the school annual function.',
      opsecFlags: const [],
      uploadedAt: DateTime.now().subtract(const Duration(days: 10)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 9)),
      reviewerNotes: 'Cleared: No tactical insignia or location indicators detected.',
    ),
    MoraleVaultItem(
      id: 'media-003',
      officerId: '3790a74c-61c7-4e69-9448-eac79eeac022',
      familyMemberId: 'fam-member-003',
      familyMemberName: 'Meera (Spouse)',
      mediaUrl: 'https://cloudinary.example.com/audio/morale_voice_note_1.mp3',
      mediaType: 'audio',
      securityStatus: MoraleMediaSecurityStatus.safe,
      transcriptOrCaption: 'Proud of you always. Kids made a drawing for you today and send their love!',
      opsecFlags: const [],
      uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final List<FamilyTrainingModule> _mockTraining = const [
    FamilyTrainingModule(
      id: 'mod-001',
      title: 'Navigating Prolonged Separation During Deployments',
      description: 'Coping strategies for military spouses handling extended high-altitude postings.',
      contentType: 'resilience_guide',
      durationMinutes: 12,
      targetAudience: 'spouse',
    ),
    FamilyTrainingModule(
      id: 'mod-002',
      title: 'Recognizing Operational Stress and Re-integration',
      description: 'Understanding combat fatigue symptoms and supportive communication when returning home on leave.',
      contentType: 'video_module',
      durationMinutes: 18,
      targetAudience: 'all',
    ),
    FamilyTrainingModule(
      id: 'mod-003',
      title: 'Tele-MANAS Family Support Resources',
      description: 'Free, confidential 24x7 mental health counselling access for service families (Toll-Free 14416).',
      contentType: 'article',
      durationMinutes: 8,
      targetAudience: 'all',
      resourceLink: 'tel:14416',
    ),
  ];

  FamilyRepository({this.client});

  @override
  Future<List<FamilyMember>> getFamilyMembers(String officerId) async {
    if (client != null) {
      try {
        final res = await client!
            .from('family_members')
            .select()
            .eq('officer_id', officerId)
            .order('created_at', ascending: true);

        final list = (res as List).map((m) => FamilyMember.fromJson(m as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) return list;
      } catch (e) {
        AppLogger.warning('Failed to fetch family members from Supabase; using local cache', error: e);
      }
    }
    return _mockMembers.where((m) => m.officerId == officerId).toList();
  }

  @override
  Future<FamilyMember> inviteFamilyMember({
    required String officerId,
    required String relation,
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    bool isEmergencyContact = false,
  }) async {
    final member = FamilyMember(
      id: 'fam-${DateTime.now().millisecondsSinceEpoch}',
      officerId: officerId,
      relation: relation,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      isEmergencyContact: isEmergencyContact,
      isVerified: true,
      createdAt: DateTime.now(),
    );

    if (client != null) {
      try {
        await client!.from('family_members').insert({
          'officer_id': officerId,
          'relation': relation,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'email': email,
          'is_emergency_contact': isEmergencyContact,
          'is_verified': true,
        });
        AppLogger.info('Saved invited family member to Supabase: ${member.fullName}');
      } catch (e) {
        AppLogger.warning('Failed to insert family member into Supabase', error: e);
      }
    }

    _mockMembers.add(member);
    _mockConsents['$officerId:${member.id}'] = FamilyConsent(
      id: 'consent-${DateTime.now().millisecondsSinceEpoch}',
      officerId: officerId,
      familyMemberId: member.id,
      grantedAt: DateTime.now(),
    );

    return member;
  }

  @override
  Future<FamilyConsent> getFamilyConsent({
    required String officerId,
    required String familyMemberId,
  }) async {
    final key = '$officerId:$familyMemberId';
    if (client != null) {
      try {
        final res = await client!
            .from('family_consents')
            .select()
            .eq('officer_id', officerId)
            .eq('family_member_id', familyMemberId)
            .maybeSingle();

        if (res != null) {
          return FamilyConsent(
            id: res['id'] as String,
            officerId: officerId,
            familyMemberId: familyMemberId,
            shareFlashNotifications: res['share_flash_notifications'] as bool? ?? false,
            shareMoraleMessages: res['share_morale_messages'] as bool? ?? true,
            shareTrainingMaterial: res['share_training_material'] as bool? ?? true,
            emergencyContactAuthorized: res['emergency_contact_authorized'] as bool? ?? true,
            isRevoked: res['is_revoked'] as bool? ?? false,
            grantedAt: DateTime.tryParse(res['granted_at'] as String? ?? '') ?? DateTime.now(),
            revokedAt: res['revoked_at'] != null ? DateTime.tryParse(res['revoked_at'] as String) : null,
          );
        }
      } catch (e) {
        AppLogger.warning('Failed to fetch family consent from Supabase', error: e);
      }
    }

    return _mockConsents[key] ??
        FamilyConsent(
          id: 'consent-$familyMemberId',
          officerId: officerId,
          familyMemberId: familyMemberId,
          grantedAt: DateTime.now(),
        );
  }

  @override
  Future<void> updateFamilyConsent(FamilyConsent consent) async {
    final key = '${consent.officerId}:${consent.familyMemberId}';
    _mockConsents[key] = consent;

    if (client != null) {
      try {
        await client!.from('family_consents').upsert({
          'officer_id': consent.officerId,
          'family_member_id': consent.familyMemberId,
          'share_flash_notifications': consent.shareFlashNotifications,
          'share_morale_messages': consent.shareMoraleMessages,
          'share_training_material': consent.shareTrainingMaterial,
          'emergency_contact_authorized': consent.emergencyContactAuthorized,
          'is_revoked': consent.isRevoked,
          'granted_at': consent.grantedAt.toIso8601String(),
        });
      } catch (e) {
        AppLogger.warning('Failed to upsert family consent to Supabase', error: e);
      }
    }
  }

  @override
  Future<void> revokeFamilyConsent({
    required String officerId,
    required String familyMemberId,
  }) async {
    final key = '$officerId:$familyMemberId';
    final existing = _mockConsents[key];
    if (existing != null) {
      _mockConsents[key] = existing.copyWith(
        isRevoked: true,
        revokedAt: DateTime.now(),
      );
    }

    if (client != null) {
      try {
        await client!.from('family_consents').update({
          'is_revoked': true,
          'revoked_at': DateTime.now().toIso8601String(),
        }).eq('officer_id', officerId).eq('family_member_id', familyMemberId);
      } catch (e) {
        AppLogger.warning('Failed to revoke family consent in Supabase', error: e);
      }
    }
  }

  @override
  Future<List<MoraleVaultItem>> getMoraleVaultItems(
    String officerId, {
    bool includeQuarantined = false,
  }) async {
    final items = _mockMedia.where((m) => m.officerId == officerId);
    if (!includeQuarantined) {
      return items.where((m) => m.isAvailableToOfficer).toList();
    }
    return items.toList();
  }

  @override
  Future<MoraleVaultItem> uploadMoraleMedia({
    required String officerId,
    required String familyMemberId,
    required String familyMemberName,
    required String mediaType,
    required String mediaUrl,
    required String transcriptOrCaption,
    Map<String, dynamic>? metadata,
  }) async {
    final scanResult = OpsecFilter.scan(
      text: transcriptOrCaption,
      metadata: metadata,
    );

    final item = MoraleVaultItem(
      id: 'media-${DateTime.now().millisecondsSinceEpoch}',
      officerId: officerId,
      familyMemberId: familyMemberId,
      familyMemberName: familyMemberName,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      securityStatus: scanResult.recommendedStatus,
      transcriptOrCaption: transcriptOrCaption,
      opsecFlags: scanResult.detectedFlags,
      uploadedAt: DateTime.now(),
    );

    _mockMedia.add(item);
    return item;
  }

  @override
  Future<void> reviewQuarantinedMedia({
    required String mediaId,
    required MoraleMediaSecurityStatus decision,
    required String reviewerId,
    String? notes,
  }) async {
    final index = _mockMedia.indexWhere((m) => m.id == mediaId);
    if (index != -1) {
      _mockMedia[index] = _mockMedia[index].copyWith(
        securityStatus: decision,
        reviewedAt: DateTime.now(),
        reviewerNotes: notes,
      );
    }
  }

  @override
  Future<bool> sendCallHomePrompt({
    required String officerId,
    required String familyMemberId,
    required DateTime timestamp,
  }) async {
    final consent = await getFamilyConsent(officerId: officerId, familyMemberId: familyMemberId);

    if (consent.isRevoked) {
      AppLogger.warning('Call-home prompt blocked: Consent has been revoked by officer.');
      return false;
    }

    if (!consent.isNotificationAllowedAt(timestamp)) {
      AppLogger.warning(
        'Call-home prompt blocked: Current timestamp outside notification window (${consent.notificationWindowStartHour}:00 - ${consent.notificationWindowEndHour}:00).',
      );
      return false;
    }

    AppLogger.info('Flash call-home prompt successfully dispatched to officer $officerId');
    return true;
  }

  @override
  Future<List<FamilyTrainingModule>> getTrainingModules() async {
    return List.unmodifiable(_mockTraining);
  }
}
