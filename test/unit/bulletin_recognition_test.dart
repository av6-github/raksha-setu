// test/unit/bulletin_recognition_test.dart
// Unit tests for Phase 15: Bulletin Board, Recommendations, Recognitions, OPSEC & Anti-Toxicity

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/bulletin/data/bulletin_recognition_repository.dart';
import 'package:raksha_welfare/features/bulletin/domain/bulletin_event.dart';
import 'package:raksha_welfare/features/recognition/domain/recognition_award.dart';

void main() {
  group('Phase 15: BulletinEvent & Recommendation Engine', () {
    test('EventCategory properly converts to and from string and provides metadata', () {
      expect(EventCategory.sports.displayName, contains('Sports'));
      expect(EventCategory.wellnessCamp.displayName, contains('Wellness'));
      expect(EventCategory.fromString('wellness_camp'), equals(EventCategory.wellnessCamp));
      expect(EventCategory.fromString('family-day'), equals(EventCategory.familyDay));
      expect(EventCategory.fromString('unknown_val'), equals(EventCategory.communityProgramme));
      expect(EventCategory.sports.toDbValue(), equals('sports'));
    });

    test('BulletinRecommendationEngine.filterEvents filters by category and location', () {
      final now = DateTime.now();
      final events = [
        BulletinEvent(
          id: 'e1',
          title: 'Volleyball Cup',
          description: 'Fun tournament',
          category: EventCategory.sports,
          location: 'Sector 5 Ground',
          eventStart: now.add(const Duration(hours: 10)),
          eventEnd: now.add(const Duration(hours: 12)),
          createdAt: now,
        ),
        BulletinEvent(
          id: 'e2',
          title: 'Yoga Camp',
          description: 'Morning meditation and yoga',
          category: EventCategory.wellnessCamp,
          location: 'Battalion Auditorium',
          eventStart: now.add(const Duration(hours: 14)),
          eventEnd: now.add(const Duration(hours: 16)),
          createdAt: now,
        ),
      ];

      // Filter by category
      final sportsOnly = BulletinRecommendationEngine.filterEvents(
        events: events,
        categoryFilter: EventCategory.sports,
      );
      expect(sportsOnly.length, equals(1));
      expect(sportsOnly.first.title, equals('Volleyball Cup'));

      // Filter by location query
      final audOnly = BulletinRecommendationEngine.filterEvents(
        events: events,
        locationQuery: 'auditorium',
      );
      expect(audOnly.length, equals(1));
      expect(audOnly.first.title, equals('Yoga Camp'));
    });

    test('BulletinRecommendationEngine.filterEvents handles free-time slot filtering', () {
      final base = DateTime(2026, 10, 1, 10, 0);
      final events = [
        BulletinEvent(
          id: 'e1',
          title: 'Morning Match',
          description: 'Match',
          category: EventCategory.sports,
          location: 'Ground',
          eventStart: base,
          eventEnd: base.add(const Duration(hours: 2)), // 10:00 - 12:00
          createdAt: base,
        ),
        BulletinEvent(
          id: 'e2',
          title: 'Evening Health Talk',
          description: 'Talk',
          category: EventCategory.wellnessCamp,
          location: 'Hall',
          eventStart: base.add(const Duration(hours: 8)), // 18:00 - 19:30
          eventEnd: base.add(const Duration(hours: 9, minutes: 30)),
          createdAt: base,
        ),
      ];

      // Officer is off-duty from 17:00 to 21:00
      final offDutySlots = [
        DateTimeRange(
          start: base.add(const Duration(hours: 7)),
          end: base.add(const Duration(hours: 11)),
        ),
      ];

      final filtered = BulletinRecommendationEngine.filterEvents(
        events: events,
        freeTimeOnly: true,
        offDutySlots: offDutySlots,
      );

      expect(filtered.length, equals(1));
      expect(filtered.first.title, equals('Evening Health Talk'));
    });

    test('BulletinRecommendationEngine.assertNoOpsecLeakage blocks tactical and grid terms', () {
      // Safe event text
      expect(
        () => BulletinRecommendationEngine.assertNoOpsecLeakage('Battalion marathon starting from HQ gate.'),
        returnsNormally,
      );

      // Sensitive tactical movement
      expect(
        () => BulletinRecommendationEngine.assertNoOpsecLeakage('Meeting on the convoy route tomorrow at dawn.'),
        throwsA(isA<OpsecViolationException>()),
      );

      // Military grid reference
      expect(
        () => BulletinRecommendationEngine.assertNoOpsecLeakage('Troops assembly near GR 728194 for drill.'),
        throwsA(isA<OpsecViolationException>()),
      );
    });
  });

  group('Phase 15: RecognitionSafetyEngine & Anti-Toxicity Controls', () {
    test('validateRecognition permits positive morale-boosting awards', () {
      expect(
        () => RecognitionSafetyEngine.validateRecognition(
          title: 'Excellence in Unit Cohesion',
          citation: 'Officer displayed selfless dedication supporting peers during high-stress operational cycles.',
          category: RecognitionCategory.peerAppreciation,
        ),
        returnsNormally,
      );
    });

    test('validateRecognition rejects short citations or empty titles', () {
      expect(
        () => RecognitionSafetyEngine.validateRecognition(
          title: '',
          citation: 'Valid length citation here.',
          category: RecognitionCategory.peerAppreciation,
        ),
        throwsA(isA<RecognitionSafetyException>()),
      );

      expect(
        () => RecognitionSafetyEngine.validateRecognition(
          title: 'Good job',
          citation: 'Short',
          category: RecognitionCategory.peerAppreciation,
        ),
        throwsA(isA<RecognitionSafetyException>()),
      );
    });

    test('validateRecognition strictly blocks sarcastic, punitive, or toxic words', () {
      expect(
        () => RecognitionSafetyEngine.validateRecognition(
          title: 'Slow Worker Award',
          citation: 'Recognizing our slacker colleague who is always lazy and failing duties.',
          category: RecognitionCategory.peerAppreciation,
        ),
        throwsA(isA<RecognitionSafetyException>()),
      );

      expect(
        () => RecognitionSafetyEngine.validateRecognition(
          title: 'Demoted Officer Badge',
          citation: 'Awarded for facing disciplinary action and court martial proceedings.',
          category: RecognitionCategory.leadershipCommendation,
        ),
        throwsA(isA<RecognitionSafetyException>()),
      );
    });

    test('assertOpsecCleared blocks tactical terms in recognition citations', () {
      expect(
        () => RecognitionSafetyEngine.assertOpsecCleared(
          'Demonstrated courage while securing the live patrol route under adverse weather.',
        ),
        throwsA(isA<RecognitionSafetyException>()),
      );

      expect(
        () => RecognitionSafetyEngine.assertOpsecCleared(
          'Demonstrated exceptional mentoring and morale-building during camp activities.',
        ),
        returnsNormally,
      );
    });

    test('assertPublicConsentEnforced strictly enforces explicit officer consent for public wall', () {
      final now = DateTime.now();

      final privateAward = RecognitionAward(
        id: 'r1',
        officerId: 'off-1',
        recipientName: 'Insp. Rajesh',
        awardedByName: 'Peer',
        title: 'Peer Badge',
        citation: 'Great support during training session.',
        category: RecognitionCategory.peerAppreciation,
        officerConsentForPublic: false, // NO CONSENT
        opsecCleared: true,
        awardedAt: now,
      );

      expect(
        () => RecognitionSafetyEngine.assertPublicConsentEnforced(privateAward),
        throwsA(isA<ConsentViolationException>()),
      );

      final consentedAward = privateAward.copyWith(officerConsentForPublic: true);
      expect(
        () => RecognitionSafetyEngine.assertPublicConsentEnforced(consentedAward),
        returnsNormally,
      );
    });
  });

  group('Phase 15: BulletinRecognitionRepository Workflow', () {
    late BulletinRecognitionRepository repo;

    setUp(() {
      repo = BulletinRecognitionRepository(); // Standalone / offline mode
    });

    test('Initializes with seeded events across sports, family, wellness, training, and cultural', () async {
      final events = await repo.getEvents();
      expect(events.length, greaterThanOrEqualTo(5));
      expect(events.any((e) => e.category == EventCategory.sports), isTrue);
      expect(events.any((e) => e.category == EventCategory.wellnessCamp), isTrue);
      expect(events.any((e) => e.category == EventCategory.familyDay), isTrue);
    });

    test('Can RSVP to an event and toggle attendance state', () async {
      final events = await repo.getEvents();
      final eventId = events.first.id;

      await repo.rsvpEvent(eventId, 'mock-officer-uuid-001', true);
      final updatedEvents = await repo.getEvents();
      final target = updatedEvents.firstWhere((e) => e.id == eventId);
      expect(target.isRsvpd, isTrue);

      await repo.rsvpEvent(eventId, 'mock-officer-uuid-001', false);
      final reverted = await repo.getEvents();
      expect(reverted.firstWhere((e) => e.id == eventId).isRsvpd, isFalse);
    });

    test('Fetches only consented awards for the public wall', () async {
      final publicWall = await repo.getPublicWallRecognitions();
      expect(publicWall, isNotEmpty);
      for (final award in publicWall) {
        expect(award.officerConsentForPublic, isTrue);
        expect(award.opsecCleared, isTrue);
      }
    });

    test('Can submit new peer appreciation and update public consent', () async {
      final newAward = RecognitionAward(
        id: 'new-rec-99',
        officerId: 'mock-officer-uuid-001',
        recipientName: 'Insp. Rajesh Kumar',
        awardedByName: 'Sub-Inspector Verma',
        title: 'Outstanding Mentorship Award',
        citation: 'Insp. Rajesh spent extra hours mentoring recruits on radio communication protocols.',
        category: RecognitionCategory.peerAppreciation,
        officerConsentForPublic: false,
        opsecCleared: true,
        awardedAt: DateTime.now(),
      );

      await repo.submitRecognition(newAward);

      // Verify present in personal recognitions
      final myRecognitions = await repo.getOfficerRecognitions('mock-officer-uuid-001');
      expect(myRecognitions.any((r) => r.id == 'new-rec-99'), isTrue);

      // Verify NOT on public wall without consent
      var publicWall = await repo.getPublicWallRecognitions();
      expect(publicWall.any((r) => r.id == 'new-rec-99'), isFalse);

      // Grant consent
      await repo.updatePublicConsent('new-rec-99', true);
      publicWall = await repo.getPublicWallRecognitions();
      expect(publicWall.any((r) => r.id == 'new-rec-99'), isTrue);
    });

    test('Fetches approved testimonials for community mental health stigma reduction', () async {
      final testimonials = await repo.getApprovedTestimonials();
      expect(testimonials.length, greaterThanOrEqualTo(3));
      for (final t in testimonials) {
        expect(t.isApproved, isTrue);
        expect(t.content, isNotEmpty);
        expect(t.authorRoleDisplay, isNotEmpty);
      }
    });
  });
}
