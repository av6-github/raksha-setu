// test/widget/phase7_widget_test.dart
// Widget tests for Phase 7: SupportHubScreen, voluntary choices, and command disclosure transparency

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/interventions/data/intervention_repository.dart';
import 'package:raksha_welfare/features/interventions/presentation/intervention_view_model.dart';
import 'package:raksha_welfare/features/interventions/presentation/support_hub_screen.dart';
import 'package:raksha_welfare/shared/widgets/welfare_banner.dart';

void main() {
  const testOfficerId = 'mock-officer-uuid-001';

  testWidgets('SupportHubScreen renders voluntary options, counselling sessions, RTD plan, and command transparency', (WidgetTester tester) async {
    final repository = InterventionRepository(client: null);
    final viewModel = InterventionViewModel(repository: repository, officerId: testOfficerId);

    await tester.pumpWidget(
      MaterialApp(
        home: SupportHubScreen(viewModel: viewModel),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    // Verify Title & Welfare Banner
    expect(find.text('Support & Human Interventions'), findsOneWidget);
    expect(find.byType(WelfareBanner), findsOneWidget);

    // Verify Voluntary & Zero Consequences Trust Card
    expect(find.text('100% Voluntary · Zero Automated Consequences'), findsOneWidget);

    // Verify Support Options
    expect(find.text('Personalized Welfare & Workload Options'), findsOneWidget);
    expect(find.text('Accept Option'), findsWidgets);
    expect(find.text('Decline'), findsWidgets);

    // Scroll to verify Confidential Counselling Section
    final counsellingHeader = find.text('Confidential Counselling Sessions');
    await tester.scrollUntilVisible(counsellingHeader, 300);
    expect(counsellingHeader, findsOneWidget);
    expect(find.text('Book Session'), findsOneWidget);

    // Scroll to verify RTD plan and Command Disclosure Transparency
    final disclosureHeader = find.text('Command Disclosure Transparency Inspector');
    await tester.scrollUntilVisible(disclosureHeader, 300);
    expect(disclosureHeader, findsOneWidget);
    expect(find.text('MEDICALLY UNAVAILABLE'), findsOneWidget);
    expect(find.textContaining('Strict Minimum Necessary Privacy Guarantee'), findsOneWidget);
  });
}
