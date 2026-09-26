// test/widget/phase14_widget_test.dart
// Widget tests for Phase 14: Welfare Scheme RAG Assistant UI, Grounded Citations, and Ingestion Status

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/welfare_rag/data/welfare_rag_repository.dart';
import 'package:raksha_welfare/features/welfare_rag/presentation/welfare_rag_screen.dart';

void main() {
  late WelfareRagRepository repository;

  setUp(() {
    repository = WelfareRagRepository();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: WelfareRagScreen(
        repository: repository,
      ),
    );
  }

  testWidgets('Renders Welfare RAG screen, welcome message, and grounding banner', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify Title & Grounding Banner
    expect(find.text('Welfare Scheme Assistant'), findsOneWidget);
    expect(
      find.textContaining('Grounded in official MHA, NHA, and WARB circulars'),
      findsOneWidget,
    );

    // Verify initial welcome message
    expect(
      find.textContaining('Jai Hind! I am your Welfare Scheme Assistant'),
      findsOneWidget,
    );

    // Verify suggestion chips
    expect(find.text('How do I get cashless treatment under Ayushman CAPF?'), findsOneWidget);
    expect(find.text('What is the PMSS scholarship amount for girls and boys?'), findsOneWidget);
  });

  testWidgets('Can tap suggestion chip and receive grounded answer with official citations', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap first suggestion chip
    final chip = find.text('How do I get cashless treatment under Ayushman CAPF?');
    await tester.tap(chip);
    await tester.pumpAndSettle();

    // Verify response message and citations appear
    expect(find.textContaining('Ayushman CAPF Healthcare Scheme'), findsWidgets);
    expect(find.text('Authoritative Sources Cited:'), findsOneWidget);
    expect(find.textContaining('pmjay.gov.in'), findsWidgets);
  });

  testWidgets('Handles unknown query with low confidence warning and official fallback', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Enter unrelated query into text field
    final inputField = find.byType(TextField);
    await tester.enterText(inputField, 'How to bake vanilla cookies at home?');
    await tester.pumpAndSettle();

    // Tap send button
    final sendBtn = find.byIcon(Icons.arrow_upward);
    await tester.tap(sendBtn);
    await tester.pumpAndSettle();

    // Verify low confidence badge and fallback text
    expect(find.text('Low Retrieval Confidence • Verification Required'), findsOneWidget);
    expect(find.textContaining('I cannot confirm this entitlement with high confidence'), findsOneWidget);
  });

  testWidgets('Opens Corpus Ingestion Status dialog from AppBar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap Ingestion Status icon in AppBar
    final infoBtn = find.byIcon(Icons.dataset_outlined);
    expect(infoBtn, findsOneWidget);
    await tester.tap(infoBtn);
    await tester.pumpAndSettle();

    // Verify dialog contents
    expect(find.text('Welfare RAG Corpus'), findsOneWidget);
    expect(find.text('Total Ingested Documents:'), findsOneWidget);
    expect(find.text('Vector Database:'), findsOneWidget);
    expect(find.text('Entitlement Guardrail:'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Welfare RAG Corpus'), findsNothing);
  });
}
