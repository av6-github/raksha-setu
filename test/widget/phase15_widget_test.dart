// test/widget/phase15_widget_test.dart
// Widget tests for Phase 15: Bulletin Board and Recognition Screen

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/bulletin/data/bulletin_recognition_repository.dart';
import 'package:raksha_welfare/features/bulletin/presentation/bulletin_board_screen.dart';

void main() {
  group('Phase 15: BulletinBoardScreen Widget Tests', () {
    late BulletinRecognitionRepository repository;

    setUp(() {
      repository = BulletinRecognitionRepository();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BulletinBoardScreen(
          repository: repository,
          officerId: 'mock-officer-uuid-001',
        ),
      );
    }

    testWidgets('Renders AppBar, 3 tabs, search bar, and event cards', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify title & tabs
      expect(find.text('Bulletin & Recognition'), findsOneWidget);
      expect(find.text('Bulletin Events'), findsOneWidget);
      expect(find.text('Recognitions'), findsOneWidget);
      expect(find.text('Stories'), findsOneWidget);

      // Verify filter bar
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Show free-time events only'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'All Events'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Sports & Athletics'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Wellness & Health Camps'), findsOneWidget);

      // Verify at least one seeded event is rendered
      expect(find.text('Battalion Inter-Coy Volleyball Championship'), findsOneWidget);
      expect(find.text('RSVP / Interested'), findsWidgets);
    });

    testWidgets('Tapping RSVP toggles attendance state to Attending', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final firstRsvpButton = find.text('RSVP / Interested').first;
      await tester.tap(firstRsvpButton);
      await tester.pumpAndSettle();

      expect(find.text('Attending'), findsOneWidget);
      expect(find.text('Cancel Attendance'), findsOneWidget);
    });

    testWidgets('Can filter events using category chips', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on Sports & Athletics chip
      final sportsChip = find.widgetWithText(FilterChip, 'Sports & Athletics');
      await tester.tap(sportsChip);
      await tester.pumpAndSettle();

      // Only sports events should be visible
      expect(find.text('Battalion Inter-Coy Volleyball Championship'), findsOneWidget);
      expect(find.text('Comprehensive Cardiovascular & Sleep Health Camp'), findsNothing);
    });

    testWidgets('Can switch to Recognitions tab and toggle Wall of Commendation vs My Honors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on Recognitions tab
      await tester.tap(find.text('Recognitions'));
      await tester.pumpAndSettle();

      // Verify SegmentedButton options and OPSEC notice
      expect(find.text('Wall of Commendation'), findsOneWidget);
      expect(find.text('My Honors & Badges'), findsOneWidget);
      expect(find.textContaining('operational security (OPSEC)'), findsOneWidget);

      // Verify Give Appreciation FAB exists
      expect(find.text('Give Appreciation'), findsOneWidget);

      // Verify public award items appear
      expect(find.text('15 Years Meritorious Duty Ribbon'), findsOneWidget);

      // Switch to My Honors & Badges
      await tester.tap(find.text('My Honors & Badges'));
      await tester.pumpAndSettle();

      expect(find.text('Display on Public Wall of Commendation'), findsWidgets);
    });

    testWidgets('Can switch to Stories tab and view verified welfare testimonials', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on Stories tab
      await tester.tap(find.text('Stories'));
      await tester.pumpAndSettle();

      expect(find.text('Finding Strength to Speak Up'), findsNothing); // Check actual title
      expect(find.textContaining('Reaching out for help was the strongest step'), findsOneWidget);
      expect(find.text('Sub-Inspector, 45 Bn CRPF (Retired)'), findsOneWidget);
      expect(find.text('Welfare Cell Verified Story'), findsWidgets);
    });

    testWidgets('Give Appreciation FAB opens modal bottom sheet and submits successfully', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to Recognitions tab
      await tester.tap(find.text('Recognitions'));
      await tester.pumpAndSettle();

      // Tap Give Appreciation
      await tester.tap(find.text('Give Appreciation'));
      await tester.pumpAndSettle();

      expect(find.text('Give Peer Appreciation'), findsOneWidget);
      expect(find.text('Colleague / Officer Name'), findsOneWidget);
      expect(find.text('Commendation Title'), findsOneWidget);
      expect(find.text('Citation / Appreciation Message'), findsOneWidget);

      // Enter details
      await tester.enterText(
        find.widgetWithText(TextField, 'Colleague / Officer Name'),
        'Constable Manoj',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Commendation Title'),
        'High Morale Builder',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Citation / Appreciation Message'),
        'Manoj consistently volunteered to assist fatigued colleagues during bad weather.',
      );

      // Tap Submit
      await tester.tap(find.text('Submit Appreciation'));
      await tester.pumpAndSettle();

      // Verify sheet closed
      expect(find.text('Give Peer Appreciation'), findsNothing);
    });
  });
}
