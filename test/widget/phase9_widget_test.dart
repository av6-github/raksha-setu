// test/widget/phase9_widget_test.dart
// Widget tests for Phase 9: Welfare Officer Console, Counsellor Portal, and Commander Overview

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/welfare_dashboard/data/welfare_repository.dart';
import 'package:raksha_welfare/features/welfare_dashboard/presentation/welfare_dashboard_screen.dart';
import 'package:raksha_welfare/features/welfare_dashboard/presentation/welfare_view_model.dart';
import 'package:raksha_welfare/features/counsellor_dashboard/data/counsellor_repository.dart';
import 'package:raksha_welfare/features/counsellor_dashboard/presentation/counsellor_dashboard_screen.dart';
import 'package:raksha_welfare/features/counsellor_dashboard/presentation/counsellor_view_model.dart';
import 'package:raksha_welfare/features/commander_dashboard/data/commander_repository.dart';
import 'package:raksha_welfare/features/commander_dashboard/presentation/commander_dashboard_screen.dart';
import 'package:raksha_welfare/features/commander_dashboard/presentation/commander_view_model.dart';

void main() {
  group('Phase 9 — Role-Based Dashboards Widget Tests', () {
    testWidgets('WelfareDashboardScreen renders pseudonymised console, tabs, and firewall notice', (WidgetTester tester) async {
      final repository = WelfareRepository();
      final viewModel = WelfareViewModel(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: WelfareDashboardScreen(viewModel: viewModel),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Verify Title & Firewall Notice
      expect(find.text('Welfare Officer Console'), findsOneWidget);
      expect(find.textContaining('Pseudonymised Console: Operating under strict Welfare-HR Firewall'), findsOneWidget);

      // Verify Tabs
      expect(find.text('Tiers'), findsOneWidget);
      expect(find.text('Escalations'), findsOneWidget);
      expect(find.text('Family Pipeline'), findsOneWidget);

      // Verify Pseudonymised Personnel
      expect(find.textContaining('Officer P-'), findsAtLeastNWidgets(1));

      // Tap Escalations Tab
      await tester.tap(find.text('Escalations'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Trigger:'), findsAtLeastNWidgets(1));
      expect(find.text('Log Outreach Contact'), findsOneWidget);

      // Tap Log Outreach Contact
      await tester.tap(find.text('Log Outreach Contact'));
      await tester.pumpAndSettle();

      expect(find.text('Outreach Note: Welfare check completed by regimental welfare officer.'), findsOneWidget);
    });

    testWidgets('CounsellorDashboardScreen renders clinical metrics, cases, and safety plan controls', (WidgetTester tester) async {
      final repository = CounsellorRepository();
      final viewModel = CounsellorViewModel(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: CounsellorDashboardScreen(viewModel: viewModel),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Verify Title & Enclave Notice
      expect(find.text('Clinical Counsellor Portal'), findsOneWidget);
      expect(find.textContaining('Confidential Clinical Enclave: Authorized clinicians only'), findsOneWidget);

      // Verify Active Case Information
      expect(find.text('Major Vikram S.'), findsAtLeastNWidgets(1));
      expect(find.text('PHQ-9 Score'), findsOneWidget);
      expect(find.text('GAD-7 Score'), findsOneWidget);
      expect(find.text('Safety Plan'), findsOneWidget);

      // Verify Stanley-Brown Action
      expect(find.text('Stanley-Brown Safety Plan'), findsOneWidget);
      expect(find.text('View Plan'), findsOneWidget);

      // Tap View Plan to open dialog
      await tester.tap(find.text('View Plan'));
      await tester.pumpAndSettle();

      expect(find.text('Warning Signs:'), findsOneWidget);
      expect(find.text('Internal Coping:'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Verify Add Note button is visible
      expect(find.text('Add Note'), findsOneWidget);
    });

    testWidgets('CommanderDashboardScreen renders readiness indicators, binary availability, and handles k-anonymity suppression', (WidgetTester tester) async {
      final repository = CommanderRepository();
      final viewModel = CommanderViewModel(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: CommanderDashboardScreen(viewModel: viewModel),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Verify Title & Command Notice
      expect(find.text('Commander Unit Overview'), findsOneWidget);
      expect(find.textContaining('Welfare-HR Firewall Guard: Command view is strictly restricted'), findsOneWidget);

      // Verify Readiness Indicators for Charlie Co (84 pers)
      expect(find.text('Readiness Index'), findsOneWidget);
      expect(find.text('Fatigue Roster'), findsOneWidget);
      expect(find.text('Consecutive Duty'), findsOneWidget);
      expect(find.text('Leave Friction'), findsOneWidget);

      // Verify Binary Availability Chips
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('AVAILABLE'), findsAtLeastNWidgets(1));
      expect(find.text('MEDICALLY UNAVAILABLE'), findsAtLeastNWidgets(1));

      // Switch to small unit (Forward Det: 6 pers < 10)
      final smallUnitChip = find.text('Forward Det (6 pers)');
      await tester.tap(smallUnitChip);
      await tester.pumpAndSettle();

      // Verify k-anonymity suppression card
      expect(find.text('Aggregate Metrics Suppressed'), findsOneWidget);
      expect(find.textContaining('violates the minimum group size threshold (k >= 10)'), findsOneWidget);
    });
  });
}
