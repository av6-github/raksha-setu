// test/widget/phase5_widget_test.dart
// Widget tests for Phase 5: BaselineTrendsScreen, CUSUM alerts, and k-anonymity rendering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/analytics/data/baseline_repository.dart';
import 'package:raksha_welfare/features/analytics/presentation/baseline_trends_screen.dart';
import 'package:raksha_welfare/features/analytics/presentation/baseline_view_model.dart';
import 'package:raksha_welfare/shared/widgets/welfare_banner.dart';

void main() {
  const testOfficerId = 'officer-widget-test-phase5';

  testWidgets('BaselineTrendsScreen renders baseline targets, CUSUM alerts, and k-anonymity unit card', (WidgetTester tester) async {
    final repository = BaselineRepository(client: null);
    final viewModel = BaselineViewModel(repository: repository, officerId: testOfficerId);

    await tester.pumpWidget(
      MaterialApp(
        home: BaselineTrendsScreen(viewModel: viewModel),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    // Verify Title & Welfare Banner
    expect(find.text('Personal Baseline & Analytics'), findsOneWidget);
    expect(find.byType(WelfareBanner), findsOneWidget);

    // Verify Personal Baseline Card
    expect(find.text('Calibrated Personal Baseline'), findsOneWidget);
    expect(find.text('Sleep Norm'), findsOneWidget);
    expect(find.text('Duty Norm'), findsOneWidget);
    expect(find.text('Distress Norm'), findsOneWidget);

    // Verify CUSUM alerts
    expect(find.text('CUSUM Change-Point Alerts'), findsOneWidget);
    expect(find.text('Duty Workload'), findsOneWidget);
    expect(find.text('Sleep Duration'), findsOneWidget);

    // Verify k-anonymity unit summary
    final kAnonFinder = find.textContaining('k=5 Protected');
    await tester.scrollUntilVisible(kAnonFinder, 300);
    expect(kAnonFinder, findsOneWidget);
    expect(find.text('Systemic Balancing Insights:'), findsOneWidget);
  });
}
