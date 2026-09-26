// test/widget/phase8_widget_test.dart
// Widget tests for Phase 8: CrisisScreen, Tele-MANAS dialer, safety alert trigger, and zero-AI guarantee

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/crisis/data/crisis_repository.dart';
import 'package:raksha_welfare/features/crisis/presentation/crisis_screen.dart';
import 'package:raksha_welfare/features/crisis/presentation/crisis_view_model.dart';

void main() {
  const testOfficerId = 'mock-officer-uuid-001';

  testWidgets('CrisisScreen renders 24x7 actions, triggers safety alert, and displays zero-AI guarantee', (WidgetTester tester) async {
    final repository = CrisisRepository(client: null);
    final viewModel = CrisisViewModel(repository: repository, officerId: testOfficerId);

    await tester.pumpWidget(
      MaterialApp(
        home: CrisisScreen(viewModel: viewModel),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    // Verify Title & Reassurance Header
    expect(find.text('24×7 Immediate Human Support'), findsOneWidget);
    expect(find.text('You are not alone.'), findsOneWidget);

    // Verify Actions
    expect(find.text('Call Tele-MANAS (14416)'), findsOneWidget);
    expect(find.text('Call Regimental Medical Desk'), findsOneWidget);
    expect(find.text('Send Immediate Safety Alert'), findsOneWidget);

    // Verify Safety Plan and C-SSRS Buttons
    expect(find.text('View My Personal Safety Plan'), findsOneWidget);
    expect(find.text('Clinical Triage Screener (C-SSRS)'), findsOneWidget);

    // Verify Zero-AI Architectural Guarantee
    final guaranteeFinder = find.text('HARD ARCHITECTURAL GUARANTEE');
    await tester.scrollUntilVisible(guaranteeFinder, 300);
    expect(guaranteeFinder, findsOneWidget);
    expect(find.textContaining('AI, LLMs, and conversational chatbots are strictly forbidden'), findsOneWidget);

    // Tap Send Immediate Safety Alert
    final alertButton = find.text('Send Immediate Safety Alert');
    await tester.scrollUntilVisible(alertButton, -300);
    await tester.tap(alertButton);
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify Dispatched Alert Banner
    expect(find.text('Safety Alert Dispatched'), findsOneWidget);
  });
}
