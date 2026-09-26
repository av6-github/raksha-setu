// test/widget/phase10_widget_test.dart
// Widget tests for Phase 10: FamilyDashboardScreen and MoraleVaultScreen

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/family/data/family_repository.dart';
import 'package:raksha_welfare/features/family/presentation/family_dashboard_screen.dart';
import 'package:raksha_welfare/features/family/presentation/family_view_model.dart';
import 'package:raksha_welfare/features/family/presentation/morale_vault_screen.dart';

void main() {
  const testOfficerId = 'mock-officer-uuid-001';

  group('Phase 10 — Family Support & Morale Vault Widget Tests', () {
    testWidgets('FamilyDashboardScreen renders portal tabs, OPSEC notice, and triggers actions', (WidgetTester tester) async {
      final repository = FamilyRepository();
      final viewModel = FamilyViewModel(repository: repository, officerId: testOfficerId);

      await tester.pumpWidget(
        MaterialApp(
          home: FamilyDashboardScreen(viewModel: viewModel),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Verify Title & OPSEC Notice
      expect(find.text('Family Support Portal'), findsOneWidget);
      expect(find.textContaining('Operational Security Notice: All shared voice and video messages'), findsOneWidget);

      // Verify Tabs
      expect(find.text('Morale Vault'), findsOneWidget);
      expect(find.text('Flash Connect'), findsOneWidget);
      expect(find.text('Resilience Guides'), findsOneWidget);

      // Verify Upload Action Card in Morale Vault tab
      expect(find.text('Send Morale Voice Note or Video'), findsOneWidget);
      final uploadButton = find.text('Record or Upload Message');
      expect(uploadButton, findsOneWidget);

      // Open Upload Dialog
      await tester.tap(uploadButton);
      await tester.pumpAndSettle();

      expect(find.text('Record or Upload Morale Media'), findsOneWidget);
      expect(find.text('Voice Note'), findsOneWidget);
      expect(find.text('Family Video'), findsOneWidget);

      // Close Dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Switch to Flash Connect Tab
      await tester.tap(find.text('Flash Connect'));
      await tester.pumpAndSettle();

      expect(find.text('Officer Connection Status'), findsOneWidget);
      expect(find.text('SAFE & ACTIVE'), findsOneWidget);
      expect(find.text('Send Call-Home Reminder'), findsOneWidget);
      expect(find.text('Request Call Home'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('24×7 Family Helpline — Tele-MANAS'), findsOneWidget);

      // Switch to Resilience Guides Tab
      await tester.tap(find.text('Resilience Guides'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Navigating Prolonged Separation'), findsOneWidget);
      expect(find.text('Open Guide'), findsAtLeastNWidgets(1));
    });

    testWidgets('MoraleVaultScreen renders offline reassurance and cleared playback controls', (WidgetTester tester) async {
      final repository = FamilyRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: MoraleVaultScreen(
            repository: repository,
            officerId: testOfficerId,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Verify Title & Offline Deployment Reassurance
      expect(find.text('Morale Vault'), findsOneWidget);
      expect(find.textContaining('Offline Morale Vault: Approved family voice and video notes are cached locally'), findsOneWidget);

      // Verify Cleared Badges
      expect(find.text('Cleared'), findsAtLeastNWidgets(1));
      expect(find.text('Ananya (Spouse)'), findsAtLeastNWidgets(1));

      // Test Playback Toggle
      final playButton = find.text('Listen');
      expect(playButton, findsOneWidget);

      await tester.tap(playButton);
      await tester.pump();

      expect(find.text('Pause'), findsOneWidget);
    });
  });
}
