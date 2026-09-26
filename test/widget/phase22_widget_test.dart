// test/widget/phase22_widget_test.dart
// Widget tests for Phase 22: ExpansionScreen (Sector Horizons, Dynamic Adapter, Universal Firewall)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:raksha_welfare/features/expansion/data/expansion_repository.dart';
import 'package:raksha_welfare/features/expansion/presentation/expansion_screen.dart';
import 'package:raksha_welfare/features/expansion/presentation/expansion_view_model.dart';

void main() {
  group('Phase 22: ExpansionScreen Widget Tests', () {
    late ExpansionRepository repository;
    late ExpansionViewModel viewModel;

    setUp(() async {
      repository = ExpansionRepository();
      viewModel = ExpansionViewModel(repository: repository);
      await viewModel.loadMetrics();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<ExpansionViewModel>.value(
          value: viewModel,
          child: const ExpansionScreen(),
        ),
      );
    }

    testWidgets('Renders AppBar and Tab 1 Sector Horizons', (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Phase 22: Multi-Sector Expansion'), findsOneWidget);
      expect(find.text('National High-Stress Workforce Horizons'), findsOneWidget);
      expect(find.text('6 High-Stress Sectors'), findsOneWidget);
      expect(find.text('645000 Personnel'), findsOneWidget);
      expect(find.text('State Police Forces'), findsOneWidget);
      expect(find.text('National & State Disaster Response (NDRF/SDRF)'), findsOneWidget);
    });

    testWidgets('Can switch to Tab 2 Dynamic Adapter and switch active sector', (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final adapterTab = find.text('Dynamic Adapter');
      expect(adapterTab, findsOneWidget);
      await tester.tap(adapterTab);
      await tester.pumpAndSettle();

      expect(find.text('Active Adaptation: State Police Forces'), findsOneWidget);
      expect(find.text('Sector-Specific Operational Stressors'), findsOneWidget);
      expect(find.text('Mapped Organizational Rank Hierarchy'), findsOneWidget);

      // Tap NDRF choice chip
      final ndrfChip = find.text('National & State Disaster Response (NDRF/SDRF)');
      expect(ndrfChip, findsOneWidget);
      await tester.tap(ndrfChip);
      await tester.pumpAndSettle();

      expect(find.text('Active Adaptation: National & State Disaster Response (NDRF/SDRF)'), findsOneWidget);
      expect(find.textContaining('exposure to casualty extraction'), findsOneWidget);
      expect(find.textContaining('Commandant (NDRF)'), findsOneWidget);
    });

    testWidgets('Can switch to Tab 3 Universal Firewall and view statutory rules', (tester) async {
      tester.view.physicalSize = const Size(1600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final firewallTab = find.text('Universal Firewall');
      expect(firewallTab, findsOneWidget);
      await tester.tap(firewallTab);
      await tester.pumpAndSettle();

      expect(find.text('Universal Non-Negotiable Firewall Mandate'), findsOneWidget);
      expect(find.text('Sector-Specific Statutory Firewall Guarantees'), findsOneWidget);
      expect(find.textContaining('Section 42-B State Police Act'), findsOneWidget);
      expect(find.textContaining('Disaster Management Act 2005'), findsOneWidget);
    });
  });
}
