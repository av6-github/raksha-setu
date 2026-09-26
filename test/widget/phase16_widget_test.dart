// test/widget/phase16_widget_test.dart
// Widget tests for Phase 16: GovernanceTrustScreen (Ethics, Security, Break-Glass, and Differential Privacy)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/trust/data/governance_repository.dart';
import 'package:raksha_welfare/features/trust/presentation/governance_trust_screen.dart';

void main() {
  group('Phase 16: GovernanceTrustScreen Widget Tests', () {
    late GovernanceRepository repository;

    setUp(() {
      repository = GovernanceRepository();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: GovernanceTrustScreen(repository: repository),
      );
    }

    testWidgets('Renders AppBar and 4 tabs', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Trust, Ethics & Security Governance'), findsOneWidget);
      expect(find.text('Oversight'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Break-Glass'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
    });

    testWidgets('Oversight & Ethics tab displays Shadow-Mode Pilot and Bias Audits', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Shadow Pilot Gate: PASSED'), findsOneWidget);
      expect(find.text('Clinician Concordance'), findsOneWidget);
      expect(find.text('Algorithmic Fairness & Bias Audits'), findsOneWidget);
      expect(find.text('COMPLIANT'), findsWidgets);
      expect(find.text('Independent Ethics Board'), findsOneWidget);
    });

    testWidgets('Can switch to Security & KMS tab and view security guardrails', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Security'));
      await tester.pumpAndSettle();

      expect(find.text('Multi-Layer Defence Grade Security'), findsOneWidget);
      expect(find.text('AES-256 at Rest & Field-Level Encryption'), findsOneWidget);
      expect(find.text('TLS 1.3 Transport Security'), findsOneWidget);
      expect(find.text('KMS / Hardware Security Module (HSM)'), findsOneWidget);
      expect(find.text('Per-Force Multi-Tenant Isolation'), findsOneWidget);
      expect(find.text('Immutable Append-Only Audit Logs'), findsOneWidget);
    });

    testWidgets('Can switch to Break-Glass tab and open adjudication dialog', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Break-Glass'));
      await tester.pumpAndSettle();

      expect(find.text('Emergency Access Logs & Adjudication'), findsOneWidget);
      expect(find.text('Pending Oversight Review'), findsOneWidget);
      expect(find.text('Validated Emergency Access'), findsOneWidget);

      // Open adjudication dialog
      final adjudicateBtn = find.text('Adjudicate Access');
      expect(adjudicateBtn, findsOneWidget);
      await tester.tap(adjudicateBtn);
      await tester.pumpAndSettle();

      expect(find.text('Adjudicate Break-Glass Access'), findsOneWidget);
      expect(find.text('Save Adjudication'), findsOneWidget);

      await tester.tap(find.text('Save Adjudication'));
      await tester.pumpAndSettle();

      expect(find.text('Adjudicate Break-Glass Access'), findsNothing);
    });

    testWidgets('Can switch to Differential Privacy tab and interact with cohort slider and co-design', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Privacy'));
      await tester.pumpAndSettle();

      expect(find.text('Commander Aggregate Privacy Model'), findsOneWidget);
      expect(find.text('Differential Privacy & K-Anonymity Simulator'), findsOneWidget);

      // Verify troop co-design section
      expect(find.text('Troop Co-Design Feedback'), findsOneWidget);
      expect(find.text('Add Suggestion'), findsOneWidget);

      // Open Co-Design dialog
      await tester.tap(find.text('Add Suggestion'));
      await tester.pumpAndSettle();

      expect(find.text('Submit Co-Design Idea'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Submit Co-Design Idea'), findsNothing);
    });
  });
}
