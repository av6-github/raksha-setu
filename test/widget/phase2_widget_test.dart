import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/access_log/data/access_log_repository.dart';
import 'package:raksha_welfare/features/access_log/presentation/access_log_screen.dart';
import 'package:raksha_welfare/features/consent/data/consent_repository.dart';
import 'package:raksha_welfare/features/consent/presentation/consent_centre_screen.dart';
import 'package:raksha_welfare/features/consent/presentation/consent_view_model.dart';
import 'package:raksha_welfare/features/profile/data/profile_repository.dart';
import 'package:raksha_welfare/features/profile/presentation/officer_profile_screen.dart';
import 'package:raksha_welfare/features/profile/presentation/profile_view_model.dart';
import 'package:raksha_welfare/features/trust/presentation/privacy_firewall_screen.dart';
import 'package:raksha_welfare/features/trust/presentation/trust_commitments_screen.dart';
import 'package:raksha_welfare/shared/widgets/welfare_banner.dart';

void main() {
  const testOfficerId = 'mock-officer-uuid-001';

  testWidgets('ConsentCentreScreen renders privacy card and switches', (WidgetTester tester) async {
    final repo = ConsentRepository(client: null);
    final vm = ConsentViewModel(repository: repo, officerId: testOfficerId);

    await tester.pumpWidget(
      MaterialApp(
        home: ConsentCentreScreen(viewModel: vm),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Consent & Privacy Centre'), findsOneWidget);
    expect(find.text('Consent-First Architecture'), findsOneWidget);
    expect(find.text('Voluntary Wearable Biometrics'), findsOneWidget);
    expect(find.byType(Switch), findsWidgets);
  });

  testWidgets('OfficerProfileScreen renders service info and WelfareBanner', (WidgetTester tester) async {
    final repo = ProfileRepository(client: null);
    final vm = ProfileViewModel(repository: repo, officerId: testOfficerId);

    await tester.pumpWidget(
      MaterialApp(
        home: OfficerProfileScreen(viewModel: vm),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Officer Profile & Identity'), findsOneWidget);
    expect(find.text('Vikram Singh'), findsOneWidget);
    expect(find.text('CRPF-2024-8891'), findsOneWidget);
    expect(find.byType(WelfareBanner), findsOneWidget);
  });

  testWidgets('AccessLogScreen renders access history entries', (WidgetTester tester) async {
    final repo = AccessLogRepository(client: null);

    await tester.pumpWidget(
      MaterialApp(
        home: AccessLogScreen(repository: repo, officerId: testOfficerId),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Data Access History'), findsOneWidget);
    expect(find.text('Confidential Clinical Review'), findsOneWidget);
    expect(find.text('Biweekly Check-In Submitted'), findsOneWidget);
  });

  testWidgets('PrivacyFirewallScreen and TrustCommitmentsScreen render correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PrivacyFirewallScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('The Welfare-HR Firewall'), findsOneWidget);
    expect(find.text('No ACR / Promotion Impact'), findsOneWidget);
    expect(find.text('Commander Sees Aggregate Only'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: TrustCommitmentsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Institutional Trust Commitments'), findsOneWidget);
    expect(find.text('1. Welfare Over Surveillance'), findsOneWidget);
    expect(find.text('2. Personal Baseline First'), findsOneWidget);

  });
}
