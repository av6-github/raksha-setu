// test/widget/phase6_widget_test.dart
// Widget tests for Phase 6: RiskInsightsScreen, SHAP explanations, and model transparency

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/risk/data/risk_repository.dart';
import 'package:raksha_welfare/features/risk/presentation/risk_insights_screen.dart';
import 'package:raksha_welfare/features/risk/presentation/risk_view_model.dart';
import 'package:raksha_welfare/shared/widgets/welfare_banner.dart';

void main() {
  const testOfficerId = 'officer-test-phase6-widget';

  testWidgets('RiskInsightsScreen renders risk tier, SHAP attributions, and calibration metadata', (WidgetTester tester) async {
    final repository = RiskRepository(client: null);
    final viewModel = RiskViewModel(repository: repository, officerId: testOfficerId);

    await tester.pumpWidget(
      MaterialApp(
        home: RiskInsightsScreen(viewModel: viewModel),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    // Verify Title & Welfare Banner
    expect(find.text('Risk Model & Explainability'), findsOneWidget);
    expect(find.byType(WelfareBanner), findsOneWidget);

    // Verify Predictive Wellness Tier Card
    expect(find.text('Predictive Wellness Tier (30-60 Days)'), findsOneWidget);
    expect(find.textContaining('%'), findsWidgets);

    // Verify SHAP Feature Attribution Section
    expect(find.text('Why This Score? (SHAP Feature Attribution)'), findsOneWidget);
    expect(find.textContaining('SHAP'), findsWidgets);

    // Scroll to verify Model Calibration Card and Metrics Chips
    final brierFinder = find.text('Brier Score');
    await tester.scrollUntilVisible(brierFinder, 300);
    expect(brierFinder, findsOneWidget);
    expect(find.text('PR-AUC'), findsOneWidget);
    expect(find.text('High-Risk Recall'), findsOneWidget);
    expect(find.textContaining('Parity Verified'), findsWidgets);
  });
}
