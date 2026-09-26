// lib/features/bulletin/data/bulletin_recognition_repository.dart
// Repository for Bulletin Board Events, Officer Preferences, Recognitions, and Testimonials

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../domain/bulletin_event.dart';
import '../../recognition/domain/recognition_award.dart';

abstract class IBulletinRecognitionRepository {
  Future<List<BulletinEvent>> getEvents({
    EventCategory? category,
    String? location,
    bool freeTimeOnly = false,
    String? officerId,
  });

  Future<EventInterestPreference> getPreferences(String officerId);
  Future<void> savePreferences(EventInterestPreference preferences);
  Future<void> rsvpEvent(String eventId, String officerId, bool rsvp);

  Future<List<RecognitionAward>> getOfficerRecognitions(String officerId);
  Future<List<RecognitionAward>> getPublicWallRecognitions();
  Future<void> submitRecognition(RecognitionAward award);
  Future<void> updatePublicConsent(String recognitionId, bool consent);

  Future<List<Testimonial>> getApprovedTestimonials();
}

class BulletinRecognitionRepository implements IBulletinRecognitionRepository {
  final sp.SupabaseClient? client;

  // In-memory persistent caches for realistic stateful mock execution
  final List<BulletinEvent> _events = [];
  final Map<String, EventInterestPreference> _preferences = {};
  final List<RecognitionAward> _recognitions = [];
  final List<Testimonial> _testimonials = [];

  BulletinRecognitionRepository({this.client}) {
    _seedDefaultData();
  }

  void _seedDefaultData() {
    final now = DateTime.now();

    // 1. Seed Bulletin Events across all categories
    _events.addAll([
      BulletinEvent(
        id: 'event-sports-001',
        title: 'Battalion Inter-Coy Volleyball Championship',
        description: 'Annual inter-company volleyball tournament. Friendly sports event to build camaraderie and team spirit. Refreshments served.',
        category: EventCategory.sports,
        location: 'Battalion Sports Complex, Ground A',
        eventStart: now.add(const Duration(days: 2, hours: 16)),
        eventEnd: now.add(const Duration(days: 2, hours: 19)),
        isActive: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      BulletinEvent(
        id: 'event-family-002',
        title: 'Family Day & Bal Utsav Mela',
        description: 'Open to all families and children. Games, food stalls, magic show, and informal family interaction with senior leadership.',
        category: EventCategory.familyDay,
        location: 'Family Welfare Centre, Sector 4',
        eventStart: now.add(const Duration(days: 4, hours: 10)),
        eventEnd: now.add(const Duration(days: 4, hours: 15)),
        isActive: true,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      BulletinEvent(
        id: 'event-wellness-003',
        title: 'Comprehensive Cardiovascular & Sleep Health Camp',
        description: 'Free health screening conducted by Composite Hospital medical specialists. ECG, blood sugar, lipid profile, and sleep consultation.',
        category: EventCategory.wellnessCamp,
        location: 'Unit MI Room & Auditorium',
        eventStart: now.add(const Duration(days: 6, hours: 9)),
        eventEnd: now.add(const Duration(days: 6, hours: 14)),
        isActive: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      BulletinEvent(
        id: 'event-training-004',
        title: 'Financial Health & PMSS Scholarship Guidance Workshop',
        description: 'Interactive workshop on mutual funds, tax planning, and how to apply for PMSS scholarship for CAPF wards.',
        category: EventCategory.training,
        location: 'Briefing Hall 2, Admin Block',
        eventStart: now.add(const Duration(days: 8, hours: 17)),
        eventEnd: now.add(const Duration(days: 8, hours: 19)),
        isActive: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      BulletinEvent(
        id: 'event-cultural-005',
        title: 'Bada Khana & Cultural Talent Night',
        description: 'Traditional battalion Bada Khana accompanied by musical performances and skit presentations by troops.',
        category: EventCategory.cultural,
        location: 'Troops Mess Lawn',
        eventStart: now.add(const Duration(days: 10, hours: 19)),
        eventEnd: now.add(const Duration(days: 10, hours: 22)),
        isActive: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      BulletinEvent(
        id: 'event-community-006',
        title: 'Civil Action Blood Donation Drive',
        description: 'Voluntary blood donation camp in collaboration with Red Cross Society for local district hospital.',
        category: EventCategory.communityProgramme,
        location: 'Recreation Hall',
        eventStart: now.add(const Duration(days: 12, hours: 10)),
        eventEnd: now.add(const Duration(days: 12, hours: 16)),
        isActive: true,
        createdAt: now,
      ),
    ]);

    // 2. Seed Default Recognitions (Milestones, Commendations, Appreciations)
    _recognitions.addAll([
      RecognitionAward(
        id: 'rec-001',
        officerId: 'mock-officer-uuid-001',
        recipientName: 'Insp. Rajesh Kumar',
        awardedByName: 'Inspector General (Ops)',
        title: '15 Years Meritorious Duty Ribbon',
        citation: 'Awarded for 15 years of exemplary devotion to duty across high-altitude and counter-insurgency frontiers with spotless integrity.',
        category: RecognitionCategory.milestone,
        isInstitutionLevel: true,
        officerConsentForPublic: true,
        opsecCleared: true,
        awardedAt: now.subtract(const Duration(days: 45)),
      ),
      RecognitionAward(
        id: 'rec-002',
        officerId: 'mock-officer-uuid-001',
        recipientName: 'Insp. Rajesh Kumar',
        awardedByName: 'Commandant, 45th Bn',
        title: 'Leadership Commendation in Stress Management',
        citation: 'Demonstrated proactive empathetic leadership by fostering open communication and mentoring junior jawans during extended duties.',
        category: RecognitionCategory.leadershipCommendation,
        isInstitutionLevel: true,
        officerConsentForPublic: true,
        opsecCleared: true,
        awardedAt: now.subtract(const Duration(days: 20)),
      ),
      RecognitionAward(
        id: 'rec-003',
        officerId: 'mock-officer-uuid-001',
        recipientName: 'Insp. Rajesh Kumar',
        awardedByName: 'Sub-Inspector Sharma (Peer Buddy)',
        title: 'Peer Solidarity & Family Support Badge',
        citation: 'Rajesh stepped up to support my family during my mother\'s hospitalization while I was stationed in remote deployment.',
        category: RecognitionCategory.peerAppreciation,
        isInstitutionLevel: false,
        officerConsentForPublic: false, // Private by default until officer grants consent
        opsecCleared: true,
        awardedAt: now.subtract(const Duration(days: 5)),
      ),
      RecognitionAward(
        id: 'rec-004',
        officerId: 'officer-external-002',
        recipientName: 'Head Constable Vikram Singh',
        awardedByName: 'DIG, Sector HQ',
        title: 'Exemplary Endurance & Physical Agility Badge',
        citation: 'Secured first rank in the inter-battalion obstacle navigation course, inspiring the entire company.',
        category: RecognitionCategory.milestone,
        isInstitutionLevel: true,
        officerConsentForPublic: true,
        opsecCleared: true,
        awardedAt: now.subtract(const Duration(days: 12)),
      ),
      RecognitionAward(
        id: 'rec-005',
        officerId: 'officer-external-003',
        recipientName: 'Sub-Inspector Anita Devi',
        awardedByName: 'Commandant, Mahila Bn',
        title: 'Welfare Champion of the Quarter',
        citation: 'Spearheaded family health outreach and children\'s education initiatives across battalion family quarters.',
        category: RecognitionCategory.appreciationNote,
        isInstitutionLevel: true,
        officerConsentForPublic: true,
        opsecCleared: true,
        awardedAt: now.subtract(const Duration(days: 8)),
      ),
    ]);

    // 3. Seed Curated Testimonials to destigmatize mental health and welfare support
    _testimonials.addAll([
      Testimonial(
        id: 'test-001',
        title: 'Reaching out for help was the strongest step I ever took',
        content: 'During 2018 after prolonged deployment, insomnia and hyper-vigilance started affecting my patience with my children. Speaking to our unit welfare officer and Tele-MANAS gave me practical grounding exercises. Today I encourage every jawan in my company that seeking help is courage, not weakness.',
        authorRoleDisplay: 'Sub-Inspector, 45 Bn CRPF (Retired)',
        isApproved: true,
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      Testimonial(
        id: 'test-002',
        title: 'The Buddy System & Morale Vault kept our spirits high',
        content: 'When we were snowed in at a forward outpost, messages from our families via the Morale Vault kept the entire detachment smiling. Sharing off-duty worries with my buddy saved me from burnout.',
        authorRoleDisplay: 'Head Constable, 112 Bn BSF',
        isApproved: true,
        createdAt: now.subtract(const Duration(days: 35)),
      ),
      Testimonial(
        id: 'test-003',
        title: 'Taking leave on time made me a sharper commander',
        content: 'I used to believe continuous duty proved toughness. After burnout nearly degraded my decision-making, our Welfare Officer helped restructure leave cycles. Returning recharged made me a far better leader.',
        authorRoleDisplay: 'Assistant Commandant, CISF',
        isApproved: true,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ]);
  }

  @override
  Future<List<BulletinEvent>> getEvents({
    EventCategory? category,
    String? location,
    bool freeTimeOnly = false,
    String? officerId,
  }) async {
    EventInterestPreference? pref;
    if (officerId != null) {
      pref = await getPreferences(officerId);
    }

    // Attempt Supabase fetch if client available
    if (client != null) {
      try {
        final query = client!.from('bulletin_events').select().eq('is_active', true);
        final response = await query;
        if (response.isNotEmpty) {
          final fetched = response.map((item) => BulletinEvent.fromJson(item)).toList();
          return BulletinRecommendationEngine.filterEvents(
            events: fetched,
            preferences: pref,
            categoryFilter: category,
            locationQuery: location,
            freeTimeOnly: freeTimeOnly,
          );
        }
      } catch (_) {
        // Fallback to internal cache on DB error/offline
      }
    }

    return BulletinRecommendationEngine.filterEvents(
      events: _events,
      preferences: pref,
      categoryFilter: category,
      locationQuery: location,
      freeTimeOnly: freeTimeOnly,
    );
  }

  @override
  Future<EventInterestPreference> getPreferences(String officerId) async {
    if (_preferences.containsKey(officerId)) {
      return _preferences[officerId]!;
    }

    if (client != null) {
      try {
        final response = await client!
            .from('event_interest_preferences')
            .select()
            .eq('officer_id', officerId)
            .maybeSingle();
        if (response != null) {
          final pref = EventInterestPreference.fromJson(response);
          _preferences[officerId] = pref;
          return pref;
        }
      } catch (_) {
        // Fallback
      }
    }

    // Default preference
    final defaultPref = EventInterestPreference(
      id: 'pref-$officerId',
      officerId: officerId,
      interestedCategories: [
        EventCategory.sports,
        EventCategory.wellnessCamp,
        EventCategory.familyDay,
      ],
      locationPreference: 'Battalion HQ',
      notificationEnabled: true,
      createdAt: DateTime.now(),
    );
    _preferences[officerId] = defaultPref;
    return defaultPref;
  }

  @override
  Future<void> savePreferences(EventInterestPreference preferences) async {
    _preferences[preferences.officerId] = preferences;

    if (client != null) {
      try {
        await client!.from('event_interest_preferences').upsert(preferences.toJson());
      } catch (_) {
        // Handled via memory fallback
      }
    }
  }

  @override
  Future<void> rsvpEvent(String eventId, String officerId, bool rsvp) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      _events[index] = _events[index].copyWith(isRsvpd: rsvp);
    }
  }

  @override
  Future<List<RecognitionAward>> getOfficerRecognitions(String officerId) async {
    if (client != null) {
      try {
        final response = await client!
            .from('recognitions')
            .select()
            .eq('officer_id', officerId)
            .order('awarded_at', ascending: false);
        if (response.isNotEmpty) {
          return response.map((item) => RecognitionAward.fromJson(item)).toList();
        }
      } catch (_) {
        // Fallback
      }
    }

    return _recognitions.where((r) => r.officerId == officerId).toList();
  }

  @override
  Future<List<RecognitionAward>> getPublicWallRecognitions() async {
    if (client != null) {
      try {
        final response = await client!
            .from('recognitions')
            .select()
            .eq('officer_consent_for_public', true)
            .eq('opsec_cleared', true)
            .order('awarded_at', ascending: false);
        if (response.isNotEmpty) {
          return response.map((item) => RecognitionAward.fromJson(item)).toList();
        }
      } catch (_) {
        // Fallback
      }
    }

    // Filter by consent and OPSEC clearance
    return _recognitions.where((r) {
      return r.officerConsentForPublic && r.opsecCleared;
    }).toList();
  }

  @override
  Future<void> submitRecognition(RecognitionAward award) async {
    // 1. Anti-toxic and OPSEC validations
    RecognitionSafetyEngine.validateRecognition(
      title: award.title,
      citation: award.citation,
      category: award.category,
    );
    RecognitionSafetyEngine.assertOpsecCleared(award.citation);

    _recognitions.insert(0, award);

    if (client != null) {
      try {
        await client!.from('recognitions').insert(award.toJson());
      } catch (_) {
        // Handled via memory fallback
      }
    }
  }

  @override
  Future<void> updatePublicConsent(String recognitionId, bool consent) async {
    final index = _recognitions.indexWhere((r) => r.id == recognitionId);
    if (index != -1) {
      _recognitions[index] = _recognitions[index].copyWith(officerConsentForPublic: consent);
    }

    if (client != null) {
      try {
        await client!
            .from('recognitions')
            .update({'officer_consent_for_public': consent})
            .eq('id', recognitionId);
      } catch (_) {
        // Handled via memory fallback
      }
    }
  }

  @override
  Future<List<Testimonial>> getApprovedTestimonials() async {
    if (client != null) {
      try {
        final response = await client!
            .from('testimonials')
            .select()
            .eq('is_approved', true)
            .order('created_at', ascending: false);
        if (response.isNotEmpty) {
          return response.map((item) => Testimonial.fromJson(item)).toList();
        }
      } catch (_) {
        // Fallback
      }
    }

    return _testimonials.where((t) => t.isApproved).toList();
  }
}
