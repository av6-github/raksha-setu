// test/widget/phase18_widget_test.dart
// Widget tests for Phase 18: ObservabilityScreen (System & Sync, Crisis Routing, ML Drift, and Sanitized Alerts)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:raksha_welfare/features/observability/data/observability_repository.dart';
import 'package:raksha_welfare/features/observability/presentation/observability_screen.dart';
import 'package:raksha_welfare/features/observability/presentation/observability_view_model.dart';

void main() {
  group('Phase 18: ObservabilityScreen Widget Tests', () {
    late ObservabilityRepository repository;
    late ObservabilityViewModel viewModel;

    setUp(() {
      repository = ObservabilityRepository();
      viewModel = ObservabilityViewModel(repository: repository);
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<ObservabilityViewModel>.value(
          value: viewModel,
          child: const ObservabilityScreen(),
        ),
      );
    }

    testWidgets('Renders AppBar and Tab 1 System & Sync telemetry', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Observability & ML Monitoring'), findsOneWidget);
      expect(find.text('API Throughput & Health'), findsOneWidget);
      expect(find.text('Sync Queue & Capacity'), findsOneWidget);
      expect(find.text('Infrastructure & Provider Status'), findsOneWidget);
      expect(find.text('Supabase Postgres DB'), findsOneWidget);
      expect(find.text('DEFENCE_HSM_NITRO (KMS)'), findsOneWidget);
    });

    testWidgets('Can switch to Tab 2 Crisis & Audits and view 100% human routing compliance', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final crisisTab = find.text('Crisis & Audits');
      expect(crisisTab, findsOneWidget);
      await tester.tap(crisisTab);
      await tester.pumpAndSettle();

      expect(find.text('100% Human Crisis Routing Compliance'), findsOneWidget);
      expect(find.text('COMPLIANT'), findsOneWidget);
      expect(find.text('Zero AI allowed in emergency clinical and crisis intercept paths.'), findsOneWidget);
      expect(find.text('Immutable Audit Log & Break-Glass Health'), findsOneWidget);
      expect(find.text('VERIFIED'), findsOneWidget);
    });

    testWidgets('Can switch to Tab 3 ML Drift & Bias and view PSI scores and Four-Fifths fairness', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final mlTab = find.text('ML Drift & Bias');
      expect(mlTab, findsOneWidget);
      await tester.tap(mlTab);
      await tester.pumpAndSettle();

      expect(find.text('Population Stability Index (PSI) Drift'), findsOneWidget);
      expect(find.text('rolling_sleep_avg_14d'), findsOneWidget);
      expect(find.text('leave_friction_index'), findsOneWidget);
      expect(find.text('Subgroup Fairness (Four-Fifths Rule)'), findsOneWidget);
      expect(find.text('Gender (Female vs Male)'), findsOneWidget);
    });

    testWidgets('Can switch to Tab 4 Sanitized Alerts, filter alerts, and acknowledge alert', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final alertsTab = find.text('Sanitized Alerts');
      expect(alertsTab, findsOneWidget);
      await tester.tap(alertsTab);
      await tester.pumpAndSettle();

      expect(find.textContaining('Privacy-by-Design: Alerts are strictly sanitized'), findsOneWidget);
      expect(find.text('Forward Outpost Sync Backoff Spike'), findsOneWidget);

      final ackButton = find.widgetWithText(TextButton, 'Ack');
      expect(ackButton, findsOneWidget);
      await tester.tap(ackButton);
      await tester.pumpAndSettle();

      // Once acknowledged, button transitions to ACK chip
      expect(find.text('ACK'), findsWidgets);
    });
  });
}
