// test/widget/phase21_widget_test.dart
// Widget tests for Phase 21: ScaleArchitectureScreen (Multi-Force Tenants, Federated Learning, Multilingual, and Gov Cloud)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:raksha_welfare/features/scale/data/scale_repository.dart';
import 'package:raksha_welfare/features/scale/presentation/scale_architecture_screen.dart';
import 'package:raksha_welfare/features/scale/presentation/scale_view_model.dart';

void main() {
  group('Phase 21: ScaleArchitectureScreen Widget Tests', () {
    late ScaleRepository repository;
    late ScaleViewModel viewModel;

    setUp(() async {
      repository = ScaleRepository();
      viewModel = ScaleViewModel(repository: repository);
      await viewModel.loadMetrics();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<ScaleViewModel>.value(
          value: viewModel,
          child: const ScaleArchitectureScreen(),
        ),
      );
    }

    testWidgets('Renders AppBar and Tab 1 Multi-Force & Tenants', (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Phase 21: Scale & Enterprise Architecture'), findsOneWidget);
      expect(find.text('Multi-Force Tenant Isolation Architecture'), findsOneWidget);
      expect(find.text('7 Forces Integrated'), findsOneWidget);
      expect(find.text('RLS Enforced'), findsOneWidget);
      expect(find.text('Dedicated HSM Keys'), findsOneWidget);
      expect(find.text('Deployed Operational Battalions'), findsOneWidget);
      expect(find.text('42 Bn BSF (Kupwara Line of Control)'), findsOneWidget);
    });

    testWidgets('Can filter battalions by force in Tab 1', (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find BSF chip
      final bsfChip = find.text('BSF (192 Bn)');
      expect(bsfChip, findsOneWidget);
      await tester.tap(bsfChip);
      await tester.pumpAndSettle();

      expect(find.text('42 Bn BSF (Kupwara Line of Control)'), findsOneWidget);
      expect(find.text('114 Bn CRPF (Bijapur Bastar Sector)'), findsNothing);
    });

    testWidgets('Can switch to Tab 2 Federated Learning and view DP budget', (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final fedTab = find.text('Federated Learning');
      expect(fedTab, findsOneWidget);
      await tester.tap(fedTab);
      await tester.pumpAndSettle();

      expect(find.text('Zero Raw Telemetry Transmission Guarantee'), findsOneWidget);
      expect(find.text('Differential Privacy Budget'), findsOneWidget);
      expect(find.text('Run Federated Round'), findsOneWidget);
      expect(find.text('Federated Aggregation Round History'), findsOneWidget);
      expect(find.text('Round 14 • global-distress-detector-v2.1'), findsOneWidget);
    });

    testWidgets('Can switch to Tab 3 Multilingual and select languages', (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final multiTab = find.text('Multilingual Deployment');
      expect(multiTab, findsOneWidget);
      await tester.tap(multiTab);
      await tester.pumpAndSettle();

      expect(find.text('8 Strategic CAPF Regional Languages'), findsOneWidget);
      expect(find.text('Active Translation Preview [EN]'), findsOneWidget);
      expect(find.text('Morale Wins Wars'), findsOneWidget);

      // Tap Punjabi chip
      final punjabiChip = find.text('ਪੰਜਾਬੀ (Punjabi)');
      expect(punjabiChip, findsOneWidget);
      await tester.tap(punjabiChip);
      await tester.pumpAndSettle();

      expect(find.text('Active Translation Preview [PA]'), findsOneWidget);
      expect(find.text('ਮਨੋਬਲ ਨਾਲ ਜਿੱਤ'), findsOneWidget);
    });

    testWidgets('Can switch to Tab 4 Gov Cloud & Capacity and view sovereign compliance', (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final cloudTab = find.text('Gov Cloud & Capacity');
      expect(cloudTab, findsOneWidget);
      await tester.tap(cloudTab);
      await tester.pumpAndSettle();

      expect(find.text('Sovereign National Cloud Status'), findsOneWidget);
      expect(find.text('MIGRATION COMPLETED'), findsOneWidget);
      expect(find.text('Enterprise Capacity & Throughput'), findsOneWidget);
      expect(find.text('150000 Troops'), findsOneWidget);
      expect(find.text('1240 Concurrent TPS'), findsOneWidget);
    });
  });
}
