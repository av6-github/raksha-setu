// test/widget/phase13_widget_test.dart
// Widget tests for Phase 13: PerformanceScreen, Welfare-HR Firewall banner, and ACR Note verification

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/performance/data/performance_repository.dart';
import 'package:raksha_welfare/features/performance/presentation/performance_screen.dart';

void main() {
  late PerformanceRepository repository;

  setUp(() {
    repository = PerformanceRepository();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: PerformanceScreen(
        repository: repository,
        officerId: 'mock-officer-uuid-001',
      ),
    );
  }

  testWidgets('Renders Firewall banner, performance competencies, and encouraging coaching', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify Title & Firewall Banner
    expect(find.text('Performance & ACR Firewall'), findsOneWidget);
    expect(find.text('Welfare-HR & ACR Firewall Active'), findsOneWidget);
    expect(
      find.textContaining('Stress scores, psychometric inventories (PHQ/GAD), and clinical therapy notes are strictly prohibited'),
      findsOneWidget,
    );

    // Verify Performance Card
    expect(find.text('Operational Performance'), findsOneWidget);
    expect(find.text('86.5 / 100'), findsOneWidget);
    expect(find.text('Weapon Handling & Drill'), findsOneWidget);
    expect(find.text('Tactical Terrain Navigation'), findsOneWidget);

    // Verify Encouraging Feedback Card
    expect(find.text('Encouraging Coaching Feedback'), findsOneWidget);
    expect(find.textContaining('Vetted Operational Template'), findsOneWidget);

    // Verify ACR Notes Section
    expect(find.text('ACR Non-Clinical Context Notes'), findsOneWidget);
    expect(find.text('Firewall Verified'), findsWidgets);
  });

  testWidgets('Blocks clinical stress words when attempting to add ACR context note', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap Add ACR Note
    final addBtn = find.text('Add ACR Note');
    expect(addBtn, findsOneWidget);
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    // Verify Dialog opened
    expect(find.text('Add ACR Non-Clinical Context'), findsOneWidget);

    // Enter note violating firewall
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);
    await tester.enterText(textField, 'Officer underwent acute stress during monsoon patrol.');
    await tester.pumpAndSettle();

    // Tap Verify & Save
    final saveBtn = find.text('Verify & Save');
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Verify error is displayed and dialog remains open
    expect(find.textContaining('Welfare-HR Firewall Violation'), findsOneWidget);
    expect(find.text('Add ACR Non-Clinical Context'), findsOneWidget);

    // Now correct the text with clean non-clinical context
    await tester.enterText(textField, 'Maintained high precision in field artillery relay.');
    await tester.pumpAndSettle();

    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Dialog closed and new note rendered
    expect(find.text('Add ACR Non-Clinical Context'), findsNothing);
    expect(find.textContaining('Maintained high precision in field artillery relay'), findsOneWidget);
  });
}
