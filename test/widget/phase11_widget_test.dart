// test/widget/phase11_widget_test.dart
// Widget tests for Phase 11: Team Cohesion UI, Guarantee Banner, and 1-on-1 Confidential Alternative

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/team_cohesion/data/team_session_repository.dart';
import 'package:raksha_welfare/features/team_cohesion/presentation/team_cohesion_screen.dart';

void main() {
  late TeamSessionRepository repository;

  setUp(() {
    repository = TeamSessionRepository();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: TeamCohesionScreen(
        repository: repository,
        unitId: 'unit-alpha',
        officerId: 'test-officer-uuid',
      ),
    );
  }

  testWidgets('Renders Anti-Stress Grouping Guarantee banner and sessions', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify Title and Guarantee Banner
    expect(find.text('Team Cohesion & Psychoeducation'), findsOneWidget);
    expect(find.text('Anti-Stress Grouping Guarantee'), findsOneWidget);
    expect(
      find.textContaining('Sessions are scheduled strictly by unit/shift rosters'),
      findsOneWidget,
    );

    // Verify scheduled session titles
    expect(find.text('Squad Sleep Hygiene & Circadian Banking'), findsOneWidget);
    expect(find.text('Tactical Decompression & Adrenaline Down-regulation'), findsOneWidget);

    // Verify action buttons are present
    expect(find.text('Confirm Attendance'), findsWidgets);
    expect(find.text('1-on-1 Alternative'), findsWidgets);
  });

  testWidgets('Can confirm attendance on a team session', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap first Confirm Attendance button
    final confirmButtons = find.text('Confirm Attendance');
    expect(confirmButtons, findsWidgets);

    await tester.tap(confirmButtons.first);
    await tester.pumpAndSettle();

    // Verify status changed to Attendance Confirmed
    expect(find.text('Attendance Confirmed'), findsOneWidget);
  });

  testWidgets('Can opt into confidential 1-on-1 alternative session', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap first session's 1-on-1 Alternative button
    final altButtons = find.text('1-on-1 Alternative');
    expect(altButtons, findsWidgets);

    await tester.tap(altButtons.first);
    await tester.pumpAndSettle();

    // Verify dialog opened
    expect(find.text('Confidential 1-on-1 Session'), findsNothing); // Dialog title in screen is '1-on-1 Alternative'
    expect(find.text('1-on-1 Alternative'), findsWidgets);
    expect(
      find.textContaining('You may choose to complete this session individually and confidentially'),
      findsOneWidget,
    );

    // Confirm 1-on-1 request
    final confirmBtn = find.text('Confirm 1-on-1 Request');
    expect(confirmBtn, findsOneWidget);

    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Verify Opted for Confidential 1-on-1 Alternative banner
    expect(find.text('Opted for Confidential 1-on-1 Alternative'), findsOneWidget);
    expect(find.textContaining('Private session scheduled with facilitator'), findsOneWidget);
  });
}
