// test/widget/phase12_widget_test.dart
// Widget tests for Phase 12: Anonymous Reporting UI, Tab switching, Submission Dialog, and Case Tracking

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/anonymous_reporting/data/anonymous_report_repository.dart';
import 'package:raksha_welfare/features/anonymous_reporting/presentation/anonymous_reporting_screen.dart';

void main() {
  late AnonymousReportRepository repository;

  setUp(() {
    repository = AnonymousReportRepository();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: AnonymousReportingScreen(
        repository: repository,
      ),
    );
  }

  testWidgets('Renders Technical Identity Firewall banner and form fields', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify Title and Tabs
    expect(find.text('Anonymous Welfare & Vigilance'), findsOneWidget);
    expect(find.text('Submit Report'), findsOneWidget);
    expect(find.text('Track Case'), findsOneWidget);

    // Verify Identity Firewall banner
    expect(find.text('Technical Identity Firewall Active'), findsOneWidget);
    expect(
      find.textContaining('Zero identification tracking: No device fingerprint'),
      findsOneWidget,
    );

    // Verify Fields
    expect(find.text('Report Category'), findsOneWidget);
    expect(find.text('General Formation / Battalion (Optional)'), findsOneWidget);
    expect(find.text('Incident or Concern Details'), findsOneWidget);
    expect(find.text('Submit Whistleblower Report'), findsOneWidget);
  });

  testWidgets('Can submit an anonymous report and display the generated tracking token', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Enter report text in the incident details TextField
    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(2)); // Unit field and Incident details field

    await tester.enterText(textFields.last, 'Dangerous ice buildup on patrol ridge without safety lines.');
    await tester.pumpAndSettle();

    // Tap submit button
    final submitBtn = find.text('Submit Whistleblower Report');
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Verify confirmation dialog appeared
    expect(find.text('Report Dispatched'), findsOneWidget);
    expect(find.text('Your Unique Tracking Token:'), findsOneWidget);
    expect(find.textContaining('SAVE THIS TOKEN NOW'), findsOneWidget);
    expect(find.text('Copy Token'), findsOneWidget);
    expect(find.text('I Have Saved My Token'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('I Have Saved My Token'));
    await tester.pumpAndSettle();

    expect(find.text('Report Dispatched'), findsNothing);
  });

  testWidgets('Can switch to Track Case tab and retrieve existing report status', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Switch to Track Case tab
    final trackTab = find.text('Track Case');
    await tester.tap(trackTab);
    await tester.pumpAndSettle();

    // Enter demo tracking token
    final tokenField = find.byType(TextField);
    expect(tokenField, findsOneWidget);

    await tester.enterText(tokenField, 'TK-DEMO-SAFE-0001');
    await tester.pumpAndSettle();

    // Tap Check Investigation Status
    final searchBtn = find.text('Check Investigation Status');
    await tester.tap(searchBtn);
    await tester.pumpAndSettle();

    // Verify tracked report details render
    expect(find.text('Under Preliminary Review'), findsOneWidget);
    expect(find.text('Unsafe Operational or Living Conditions'), findsOneWidget);
    expect(find.textContaining('Extreme cold clothing and sub-zero mittens'), findsOneWidget);
    expect(find.textContaining('Winter gear replenishment scheduled'), findsOneWidget);
  });
}
