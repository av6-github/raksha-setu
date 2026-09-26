// test/widget/phase19_widget_test.dart
// Widget tests for Phase 19: ShadowPilotScreen (Go/No-Go Gate, Silent Scoring, Error Analysis, and Troop Co-Design)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:raksha_welfare/features/shadow_pilot/data/shadow_pilot_repository.dart';
import 'package:raksha_welfare/features/shadow_pilot/presentation/shadow_pilot_screen.dart';
import 'package:raksha_welfare/features/shadow_pilot/presentation/shadow_pilot_view_model.dart';

void main() {
  group('Phase 19: ShadowPilotScreen Widget Tests', () {
    late ShadowPilotRepository repository;
    late ShadowPilotViewModel viewModel;

    setUp(() async {
      repository = ShadowPilotRepository();
      viewModel = ShadowPilotViewModel(repository: repository);
      await viewModel.loadMetrics();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<ShadowPilotViewModel>.value(
          value: viewModel,
          child: const ShadowPilotScreen(),
        ),
      );
    }

    testWidgets('Renders AppBar and Tab 1 Go/No-Go Gate & Baseline KPIs', (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Phase 19: Shadow Pilot & Gate'), findsOneWidget);
      expect(find.text('Formal Shadow Pilot Review Gate'), findsOneWidget);
      expect(find.text('GO FOR LIVE PILOT'), findsOneWidget);
      expect(find.text('Prerequisite Gatekeeper Checklist (6 Criteria)'), findsOneWidget);
      expect(find.text('Operational Baseline KPIs (Pre-Live Pilot)'), findsOneWidget);
      expect(find.text('Leave Friction'), findsOneWidget);
      expect(find.text('Check-In Rate'), findsOneWidget);
    });

    testWidgets('Can switch to Tab 2 Silent Scoring and view clinician concordance', (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final silentTab = find.text('Silent Scoring & Concordance');
      expect(silentTab, findsOneWidget);
      await tester.tap(silentTab);
      await tester.pumpAndSettle();

      expect(find.textContaining('Silent Pilot Mode Active: Predictive models score quietly'), findsOneWidget);
      expect(find.text('Clinician Concordance Benchmark'), findsOneWidget);
      expect(find.textContaining('CONCORDANT'), findsWidgets);
      expect(find.text('TK-8492-4102-9912'), findsOneWidget);
      expect(find.text('TK-3921-9941-2041'), findsOneWidget);
    });

    testWidgets('Can switch to Tab 3 Error Analysis & Synthetic validation', (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final errorTab = find.text('Error Analysis & Synthetic');
      expect(errorTab, findsOneWidget);
      await tester.tap(errorTab);
      await tester.pumpAndSettle();

      expect(find.text('Error Analysis (False Positives & Negatives)'), findsOneWidget);
      expect(find.text('Critical Misses'), findsOneWidget);
      expect(find.textContaining('Synthetic Cohort Validation'), findsOneWidget);
      expect(find.text('VALIDATED'), findsOneWidget);
      expect(find.text('Acute fatigue post-operation edge cases'), findsOneWidget);
    });

    testWidgets('Can switch to Tab 4 Trust & Co-Design and view troop suggestions', (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final trustTab = find.text('Trust & Co-Design');
      expect(trustTab, findsOneWidget);
      await tester.tap(trustTab);
      await tester.pumpAndSettle();

      expect(find.text('Troop Trust & Stigma Perception Survey'), findsOneWidget);
      expect(find.text('Trust Score'), findsOneWidget);
      expect(find.text('Volunteer Personnel Co-Design Suggestions'), findsOneWidget);
      expect(find.text('SMS Fallback Token Verification'), findsOneWidget);
      expect(find.text('Welfare-HR Firewall Clarity'), findsOneWidget);
    });
  });
}
