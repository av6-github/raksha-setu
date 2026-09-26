// test/unit/anonymous_reporting_test.dart
// Unit tests for Phase 12: Anonymous Reporting, Technical Identity Separation, and Cryptographic Token Lookup

import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/anonymous_reporting/data/anonymous_report_repository.dart';
import 'package:raksha_welfare/features/anonymous_reporting/domain/anonymity_engine.dart';
import 'package:raksha_welfare/features/anonymous_reporting/domain/report_category.dart';

void main() {
  group('Phase 12: AnonymityEngine (Technical Identity Protection)', () {
    test('generateTrackingToken creates valid 16-character format TK-XXXX-XXXX-XXXX', () {
      final token = AnonymityEngine.generateTrackingToken();
      expect(token, startsWith('TK-'));
      expect(token.length, equals(17)); // 'TK-' (3) + 4 + '-' + 4 + '-' + 4 = 17 chars
      final segments = token.split('-');
      expect(segments.length, equals(4));
      expect(segments[0], equals('TK'));
      expect(segments[1].length, equals(4));
      expect(segments[2].length, equals(4));
      expect(segments[3].length, equals(4));
    });

    test('hashTrackingToken produces consistent 64-char SHA-256 hex string', () {
      final token = 'TK-ABCD-EFGH-JKMN';
      final hash1 = AnonymityEngine.hashTrackingToken(token);
      final hash2 = AnonymityEngine.hashTrackingToken('tk-abcd-efgh-jkmn'); // Case-insensitive
      final hash3 = AnonymityEngine.hashTrackingToken('TK ABCDEFGHJKMN'); // Space-tolerant

      expect(hash1.length, equals(64));
      expect(hash1, equals(hash2));
      expect(hash1, equals(hash3));
    });

    test('assertZeroIdentityLeak throws IdentityLeakException for forbidden identifying keys', () {
      expect(
        () => AnonymityEngine.assertZeroIdentityLeak({'officer_id': '12345'}),
        throwsA(isA<IdentityLeakException>()),
      );
      expect(
        () => AnonymityEngine.assertZeroIdentityLeak({'userId': 'uuid-abc'}),
        throwsA(isA<IdentityLeakException>()),
      );
      expect(
        () => AnonymityEngine.assertZeroIdentityLeak({'phone': '+919999999999'}),
        throwsA(isA<IdentityLeakException>()),
      );
      expect(
        () => AnonymityEngine.assertZeroIdentityLeak({'device_id': 'imei-999'}),
        throwsA(isA<IdentityLeakException>()),
      );
      expect(
        () => AnonymityEngine.assertZeroIdentityLeak({'ip_address': '192.168.1.1'}),
        throwsA(isA<IdentityLeakException>()),
      );
    });

    test('assertZeroIdentityLeak passes for non-identifying telemetry-free payloads', () {
      expect(
        () => AnonymityEngine.assertZeroIdentityLeak({
          'category': 'unsafe_conditions',
          'description': 'Winter gear deficit',
        }),
        returnsNormally,
      );
    });

    test('sanitizeUnitIdentifier blocks fine-grained platoons, pickets, or bunkers', () {
      expect(
        () => AnonymityEngine.sanitizeUnitIdentifier('Platoon 3, Alpha Company'),
        throwsA(isA<IdentityLeakException>()),
      );
      expect(
        () => AnonymityEngine.sanitizeUnitIdentifier('Picket 4 sentry post'),
        throwsA(isA<IdentityLeakException>()),
      );
      expect(
        () => AnonymityEngine.sanitizeUnitIdentifier('Forward Bunker 12'),
        throwsA(isA<IdentityLeakException>()),
      );
    });

    test('sanitizeUnitIdentifier allows broad battalion or sector formation', () {
      final sanitized = AnonymityEngine.sanitizeUnitIdentifier('14 Rajputana Rifles (North Sector)');
      expect(sanitized, equals('14 Rajputana Rifles (North Sector)'));
    });
  });

  group('Phase 12: AnonymousReportRepository', () {
    late AnonymousReportRepository repository;

    setUp(() {
      repository = AnonymousReportRepository();
    });

    test('Loads pre-seeded vigilance demo report by tracking token', () async {
      final report = await repository.trackReport('TK-DEMO-SAFE-0001');
      expect(report, isNotNull);
      expect(report!.category, equals(ReportCategory.unsafeConditions));
      expect(report.status, equals('under_review'));
      expect(report.responseNotesEncrypted, contains('Logistics'));
    });

    test('Submits an anonymous report and returns tracking token without author linkage', () async {
      final token = await repository.submitReport(
        category: ReportCategory.bullying,
        reportText: 'Continuous targeted hazing observed during night assembly drills.',
        unitIdentifierGeneral: '18 Punjab Regiment (HQ Sector)',
      );

      expect(token, startsWith('TK-'));

      // Retrieve via token
      final tracked = await repository.trackReport(token);
      expect(tracked, isNotNull);
      expect(tracked!.category, equals(ReportCategory.bullying));
      expect(tracked.status, equals('submitted'));
      expect(tracked.unitIdentifierGeneral, equals('18 Punjab Regiment (HQ Sector)'));
      expect(tracked.reportTextEncrypted, contains('Continuous targeted hazing'));

      // Technical separation: report entity has NO author or officer ID fields
      expect(tracked.toJson().containsKey('officer_id'), isFalse);
      expect(tracked.toJson().containsKey('user_id'), isFalse);
    });

    test('Fails submission if metadata leaks author identity', () async {
      expect(
        () => repository.submitReport(
          category: ReportCategory.harassment,
          reportText: 'Test harassment report',
          extraMetadata: {'officer_id': 'leaked-id-001'},
        ),
        throwsA(isA<IdentityLeakException>()),
      );
    });

    test('Fails submission if unit identifier specifies granular platoon or picket', () async {
      expect(
        () => repository.submitReport(
          category: ReportCategory.harassment,
          reportText: 'Test report',
          unitIdentifierGeneral: 'Platoon 2 Bunker',
        ),
        throwsA(isA<IdentityLeakException>()),
      );
    });

    test('Returns null when tracking an unknown token', () async {
      final report = await repository.trackReport('TK-NONEXISTENT-999');
      expect(report, isNull);
    });

    test('Vigilance Cell can update investigation status and response notes', () async {
      final report = await repository.trackReport('TK-DEMO-SAFE-0001');
      expect(report, isNotNull);

      final updated = await repository.updateReportStatus(
        reportId: report!.id,
        status: 'action_taken',
        responseNotes: 'Fresh winter high-altitude suits and gloves issued to all personnel in sector.',
      );

      expect(updated.status, equals('action_taken'));
      expect(updated.responseNotesEncrypted, contains('winter high-altitude suits'));

      // Verify the whistleblower sees the updated response using original token
      final refetched = await repository.trackReport('TK-DEMO-SAFE-0001');
      expect(refetched!.status, equals('action_taken'));
      expect(refetched.responseNotesEncrypted, contains('winter high-altitude suits'));
    });
  });
}
