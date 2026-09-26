// test/widget/phase4_widget_test.dart
// Widget tests for Phase 4: OrganisationalSignalsScreen and Dashboard Navigation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/hrms/data/hrms_repository.dart';
import 'package:raksha_welfare/features/hrms/presentation/hrms_view_model.dart';
import 'package:raksha_welfare/features/hrms/presentation/organisational_signals_screen.dart';
import 'package:raksha_welfare/shared/widgets/welfare_banner.dart';

void main() {
  const testOfficerId = 'officer-test-phase4-widget';

  testWidgets('OrganisationalSignalsScreen renders friction index, leave history, and welfare banner', (WidgetTester tester) async {
    final repository = HrmsRepository(client: null);
    final viewModel = HrmsViewModel(repository: repository, officerId: testOfficerId);

    await tester.pumpWidget(
      MaterialApp(
        home: OrganisationalSignalsScreen(viewModel: viewModel),
      ),
    );

    // Initial load triggers async loadData in initState
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify Title and WelfareBanner
    expect(find.text('Organisational Signals & Rhythm'), findsOneWidget);
    expect(find.byType(WelfareBanner), findsOneWidget);

    // Verify Friction overview card
    expect(find.text('Systemic Operational Friction'), findsOneWidget);
    expect(find.textContaining('The algorithm evaluates organizational strain'), findsOneWidget);

    // Verify Leave history section exists
    expect(find.text('Leave Applications & Operational Decisions'), findsOneWidget);

    // Verify operational rejection badge
    expect(find.textContaining('Operational Denial'), findsWidgets);
  });
}
