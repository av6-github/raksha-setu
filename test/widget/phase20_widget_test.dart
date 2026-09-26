// test/widget/phase20_widget_test.dart
// Widget tests for Phase 20: LivePilotScreen (Deployments, Pilot vs Control Impact, Live Incidents & Safety, Trust & Certification)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:raksha_welfare/features/live_pilot/data/live_pilot_repository.dart';
import 'package:raksha_welfare/features/live_pilot/presentation/live_pilot_screen.dart';
import 'package:raksha_welfare/features/live_pilot/presentation/live_pilot_view_model.dart';

void main() {
  group('Phase 20: LivePilotScreen Widget Tests', () {
    late LivePilotRepository repository;
    late LivePilotViewModel viewModel;

    setUp(() async {
      repository = LivePilotRepository();
      viewModel = LivePilotViewModel(repository: repository);
      await viewModel.loadMetrics();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<LivePilotViewModel>.value(
          value: viewModel,
          child: const LivePilotScreen(),
        ),
      );
    }

    testWidgets('Renders AppBar and Tab 1 Deployments & Units', (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Phase 20: Live Pilot & Certification'), findsOneWidget);
      expect(find.text('Operational Field Trial Structure'), findsOneWidget);
      expect(find.text('Staged Battalion Formations'), findsOneWidget);
      expect(find.text('42 Bn BSF (Pilot)'), findsOneWidget);
      expect(find.text('114 Bn CRPF (Pilot)'), findsOneWidget);
      expect(find.text('43 Bn BSF (Control)'), findsOneWidget);
    });

    testWidgets('Can switch to Tab 2 Pilot vs Control Impact and view metrics', (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final impactTab = find.text('Pilot vs Control Impact');
      expect(impactTab, findsOneWidget);
      await tester.tap(impactTab);
      await tester.pumpAndSettle();

      expect(find.text('6-Month Field Trial (April - September 2026)'), findsOneWidget);
      expect(find.text('Leave Friction Index'), findsOneWidget);
      expect(find.text('Acute Crisis Escalation Rate'), findsOneWidget);
      expect(find.text('Trust in Confidentiality'), findsOneWidget);
    });

    testWidgets('Can switch to Tab 3 Live Incidents and view guarantee', (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final incidentsTab = find.text('Live Incidents & Safety');
      expect(incidentsTab, findsOneWidget);
      await tester.tap(incidentsTab);
      await tester.pumpAndSettle();

      expect(find.textContaining('Zero-AI & Human Responder Guarantee'), findsOneWidget);
      expect(find.text('Live Operational Incidents & Intercepts'), findsOneWidget);
    });

    testWidgets('Can switch to Tab 4 Trust & Certification and view sign-offs', (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final trustTab = find.text('Trust & Certification');
      expect(trustTab, findsOneWidget);
      await tester.tap(trustTab);
      await tester.pumpAndSettle();

      expect(find.text('Operational Scale Certification'), findsOneWidget);
      expect(find.text('CERTIFIED FOR SCALE'), findsOneWidget);
      expect(find.text('Longitudinal Trust & Stigma Evolution'), findsOneWidget);
      expect(find.text('Authorizing Governance Sign-Offs:'), findsOneWidget);
      expect(find.text('Lt. Gen. Dr. A. Sengupta, DG Armed Forces Medical Services'), findsOneWidget);
    });
  });
}
