// lib/core/routing/app_router.dart
// Declarative routing with role-based access control guards

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/access_log/data/access_log_repository.dart';
import '../../features/access_log/presentation/access_log_screen.dart';
import '../../features/auth/domain/user_role.dart';
import '../../features/auth/presentation/auth_view_model.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/checkins/data/check_in_repository.dart';
import '../../features/checkins/presentation/check_in_screen.dart';
import '../../features/checkins/presentation/check_in_view_model.dart';
import '../../features/consent/data/consent_repository.dart';
import '../../features/consent/presentation/consent_centre_screen.dart';
import '../../features/consent/presentation/consent_view_model.dart';
import '../../features/crisis/data/crisis_repository.dart';
import '../../features/crisis/presentation/crisis_screen.dart';
import '../../features/crisis/presentation/crisis_view_model.dart';
import '../../features/data_retention/data/data_retention_repository.dart';
import '../../features/data_retention/presentation/data_retention_screen.dart';
import '../../features/officer_dashboard/presentation/officer_dashboard_screen.dart';
import '../../features/assessments/data/assessment_repository.dart';
import '../../features/assessments/presentation/assessment_screen.dart';
import '../../features/assessments/presentation/assessment_view_model.dart';
import '../../features/biometrics/data/biometric_repository.dart';
import '../../features/biometrics/presentation/biometrics_screen.dart';
import '../../features/biometrics/presentation/biometrics_view_model.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/presentation/officer_profile_screen.dart';
import '../../features/profile/presentation/profile_view_model.dart';

import '../../features/security/data/app_lock_service.dart';
import '../../features/security/presentation/app_lock_screen.dart';
import '../../features/security/presentation/app_lock_view_model.dart';
import '../../features/security/presentation/offline_sync_screen.dart';
import '../storage/encrypted_local_storage_service.dart';
import '../storage/offline_queue_service.dart';
import '../storage/sync_engine.dart';
import '../security/screen_security_service.dart';
import '../networking/network_client.dart';
import '../../features/hrms/data/hrms_repository.dart';
import '../../features/hrms/presentation/hrms_view_model.dart';
import '../../features/hrms/presentation/organisational_signals_screen.dart';
import '../../features/analytics/data/baseline_repository.dart';
import '../../features/analytics/presentation/baseline_trends_screen.dart';
import '../../features/analytics/presentation/baseline_view_model.dart';
import '../../features/risk/data/risk_repository.dart';
import '../../features/risk/presentation/risk_insights_screen.dart';
import '../../features/risk/presentation/risk_view_model.dart';
import '../../features/interventions/data/intervention_repository.dart';
import '../../features/interventions/presentation/intervention_view_model.dart';
import '../../features/interventions/presentation/support_hub_screen.dart';
import '../../features/trust/presentation/privacy_firewall_screen.dart';
import '../../features/trust/presentation/trust_commitments_screen.dart';
import '../../features/welfare_dashboard/data/welfare_repository.dart';
import '../../features/welfare_dashboard/presentation/welfare_view_model.dart';
import '../../features/welfare_dashboard/presentation/welfare_dashboard_screen.dart';
import '../../features/counsellor_dashboard/data/counsellor_repository.dart';
import '../../features/counsellor_dashboard/presentation/counsellor_view_model.dart';
import '../../features/counsellor_dashboard/presentation/counsellor_dashboard_screen.dart';
import '../../features/commander_dashboard/data/commander_repository.dart';
import '../../features/commander_dashboard/presentation/commander_view_model.dart';
import '../../features/commander_dashboard/presentation/commander_dashboard_screen.dart';
import '../../features/family/data/family_repository.dart';
import '../../features/family/presentation/family_view_model.dart';
import '../../features/family/presentation/family_dashboard_screen.dart';
import '../../features/family/presentation/morale_vault_screen.dart';
import '../../features/team_cohesion/data/team_session_repository.dart';
import '../../features/team_cohesion/presentation/team_cohesion_screen.dart';
import '../../features/anonymous_reporting/data/anonymous_report_repository.dart';
import '../../features/anonymous_reporting/presentation/anonymous_reporting_screen.dart';
import '../../features/performance/data/performance_repository.dart';
import '../../features/performance/presentation/performance_screen.dart';
import '../../features/welfare_rag/data/welfare_rag_repository.dart';
import '../../features/welfare_rag/presentation/welfare_rag_screen.dart';
import '../../features/bulletin/data/bulletin_recognition_repository.dart';
import '../../features/bulletin/presentation/bulletin_board_screen.dart';
import '../../features/trust/data/governance_repository.dart';
import '../../features/trust/presentation/governance_trust_screen.dart';
import '../../features/observability/data/observability_repository.dart';
import '../../features/observability/presentation/observability_screen.dart';
import '../../features/observability/presentation/observability_view_model.dart';
import '../../features/shadow_pilot/data/shadow_pilot_repository.dart';
import '../../features/shadow_pilot/presentation/shadow_pilot_screen.dart';
import '../../features/shadow_pilot/presentation/shadow_pilot_view_model.dart';
import '../../features/live_pilot/data/live_pilot_repository.dart';
import '../../features/live_pilot/presentation/live_pilot_screen.dart';
import '../../features/live_pilot/presentation/live_pilot_view_model.dart';
import '../../features/scale/data/scale_repository.dart';
import '../../features/scale/presentation/scale_architecture_screen.dart';
import '../../features/scale/presentation/scale_view_model.dart';
import '../../features/expansion/data/expansion_repository.dart';
import '../../features/expansion/presentation/expansion_screen.dart';
import '../../features/expansion/presentation/expansion_view_model.dart';

class AppRouter {
  static String _homeRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.counsellor:
        return '/counsellor';
      case UserRole.welfareOfficer:
        return '/welfare';
      case UserRole.commander:
        return '/commander';
      case UserRole.family:
        return '/family';
      case UserRole.officer:
      default:
        return '/dashboard';
    }
  }

  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: '/dashboard',
      refreshListenable: authViewModel,
      redirect: (context, state) {
        final isAuthenticated = authViewModel.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login';
        final isCrisis = state.matchedLocation == '/crisis';

        // Crisis route is always unblocked regardless of auth state
        if (isCrisis) return null;

        if (!isAuthenticated) {
          return isLoggingIn ? null : '/login';
        }

        final role = authViewModel.currentRole;
        final home = _homeRouteForRole(role);

        // If authenticated and visiting login or root, go to role-specific home
        if (isLoggingIn || state.matchedLocation == '/') {
          return home;
        }

        // If non-officer visits officer dashboard, route to their dedicated dashboard
        if (state.matchedLocation == '/dashboard' && role != UserRole.officer) {
          return home;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const OfficerDashboardScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) {
            final repo = context.read<IProfileRepository>();
            final officerId = authViewModel.currentUser?.officerId ?? 'mock-officer-uuid-001';
            return OfficerProfileScreen(
              viewModel: ProfileViewModel(repository: repo, officerId: officerId),
            );
          },
        ),
        GoRoute(
          path: '/consent',
          builder: (context, state) {
            final repo = context.read<IConsentRepository>();
            final officerId = authViewModel.currentUser?.officerId ?? 'mock-officer-uuid-001';
            return ConsentCentreScreen(
              viewModel: ConsentViewModel(repository: repo, officerId: officerId),
            );
          },
        ),
        GoRoute(
          path: '/access-log',
          builder: (context, state) {
            final repo = context.read<IAccessLogRepository>();
            final officerId = authViewModel.currentUser?.officerId ?? 'mock-officer-uuid-001';
            return AccessLogScreen(repository: repo, officerId: officerId);
          },
        ),
        GoRoute(
          path: '/app-lock',
          builder: (context, state) {
            final service = context.read<IAppLockService>();
            return AppLockScreen(
              viewModel: AppLockViewModel(appLockService: service),
            );
          },
        ),
        GoRoute(
          path: '/data-retention',
          builder: (context, state) {
            final repo = context.read<IDataRetentionRepository>();
            final officerId = authViewModel.currentUser?.officerId ?? 'mock-officer-uuid-001';
            return DataRetentionScreen(repository: repo, officerId: officerId);
          },
        ),
        GoRoute(
          path: '/privacy-firewall',
          builder: (context, state) => const PrivacyFirewallScreen(),
        ),
        GoRoute(
          path: '/trust',
          builder: (context, state) => const TrustCommitmentsScreen(),
        ),
        GoRoute(
          path: '/checkin',
          builder: (context, state) {
            final repo = context.read<ICheckInRepository>();
            final officerId = authViewModel.currentUser?.officerId ?? 'mock-officer-uuid-001';
            return CheckInScreen(
              viewModel: CheckInViewModel(repository: repo, officerId: officerId),
            );
          },
        ),
        GoRoute(
          path: '/assessment',
          builder: (context, state) {
            final repo = context.read<IAssessmentRepository>();
            final officerId = authViewModel.currentUser?.officerId ?? 'mock-officer-uuid-001';
            return AssessmentScreen(
              viewModel: AssessmentViewModel(repository: repo, officerId: officerId),
            );
          },
        ),
        GoRoute(
          path: '/biometrics',
          builder: (context, state) {
            final repo = context.read<IBiometricRepository>();
            final consentRepo = context.read<IConsentRepository>();
            final officerId = authViewModel.currentUser?.officerId ?? 'mock-officer-uuid-001';
            return BiometricsScreen(
              viewModel: BiometricsViewModel(
                repository: repo,
                consentRepository: consentRepo,
                officerId: officerId,
              ),
            );
          },
        ),
        GoRoute(
          path: '/organisational-signals',
          builder: (context, state) {
            final repo = context.read<IHrmsRepository>();
            final officerId = authViewModel.currentUser?.officerId ?? 'mock-officer-uuid-001';
            return OrganisationalSignalsScreen(
              viewModel: HrmsViewModel(repository: repo, officerId: officerId),
            );
          },
        ),
        GoRoute(
          path: '/baseline',
          builder: (context, state) {
            final repo = context.read<IBaselineRepository>();
            final officerId = authViewModel.currentUser?.officerId ?? 'mock-officer-uuid-001';
            return BaselineTrendsScreen(
              viewModel: BaselineViewModel(repository: repo, officerId: officerId),
            );
          },
        ),
        GoRoute(
          path: '/risk-insights',
          builder: (context, state) {
            final repo = context.read<IRiskRepository>();
            final officerId = authViewModel.currentUser?.officerId ?? 'mock-officer-uuid-001';
            return RiskInsightsScreen(
              viewModel: RiskViewModel(repository: repo, officerId: officerId),
            );
          },
        ),
        GoRoute(
          path: '/interventions',
          builder: (context, state) {
            final repo = context.read<IInterventionRepository>();
            final officerId = authViewModel.currentUser?.officerId ?? 'mock-officer-uuid-001';
            return SupportHubScreen(
              viewModel: InterventionViewModel(repository: repo, officerId: officerId),
            );
          },
        ),

        GoRoute(
          path: '/welfare',
          builder: (context, state) {
            final repo = context.read<IWelfareRepository>();
            return WelfareDashboardScreen(
              viewModel: WelfareViewModel(repository: repo),
            );
          },
        ),
        GoRoute(
          path: '/counsellor',
          builder: (context, state) {
            final repo = context.read<ICounsellorRepository>();
            return CounsellorDashboardScreen(
              viewModel: CounsellorViewModel(repository: repo),
            );
          },
        ),
        GoRoute(
          path: '/commander',
          builder: (context, state) {
            final repo = context.read<ICommanderRepository>();
            return CommanderDashboardScreen(
              viewModel: CommanderViewModel(repository: repo),
            );
          },
        ),
        GoRoute(
          path: '/family',
          builder: (context, state) {
            final repo = context.read<IFamilyRepository>();
            final user = authViewModel.currentUser;
            final officerId = user?.officerId ?? '3790a74c-61c7-4e69-9448-eac79eeac022';
            final familyMemberId = user?.familyMemberId ?? 'c8b7e27c-bb27-4dc2-b604-a74b57cdaa4d';
            final familyMemberName = (user?.displayName.isNotEmpty ?? false)
                ? '${user!.displayName} (Spouse)'
                : 'Meera Singh (Spouse)';
            return FamilyDashboardScreen(
              viewModel: FamilyViewModel(
                repository: repo,
                officerId: officerId,
                currentFamilyMemberId: familyMemberId,
                currentFamilyMemberName: familyMemberName,
              ),
            );
          },
        ),
        GoRoute(
          path: '/morale-vault',
          builder: (context, state) {
            final repo = context.read<IFamilyRepository>();
            final officerId = authViewModel.currentUser?.officerId ?? '3790a74c-61c7-4e69-9448-eac79eeac022';
            return MoraleVaultScreen(
              repository: repo,
              officerId: officerId,
            );
          },
        ),
        GoRoute(
          path: '/team-sessions',
          builder: (context, state) {
            final repo = context.read<ITeamSessionRepository>();
            final officerId = authViewModel.currentUser?.officerId ?? 'mock-officer-uuid-001';
            return TeamCohesionScreen(
              repository: repo,
              officerId: officerId,
            );
          },
        ),
        GoRoute(
          path: '/anonymous-reporting',
          builder: (context, state) {
            final repo = context.read<IAnonymousReportRepository>();
            return AnonymousReportingScreen(
              repository: repo,
            );
          },
        ),
        GoRoute(
          path: '/performance',
          builder: (context, state) {
            final repo = context.read<IPerformanceRepository>();
            final officerId = authViewModel.currentUser?.officerId ?? 'mock-officer-uuid-001';
            return PerformanceScreen(
              repository: repo,
              officerId: officerId,
            );
          },
        ),
        GoRoute(
          path: '/welfare-assistant',
          builder: (context, state) {
            final repo = context.read<IWelfareRagRepository>();
            return WelfareRagScreen(
              repository: repo,
            );
          },
        ),
        GoRoute(
          path: '/bulletin',
          builder: (context, state) {
            final repo = context.read<IBulletinRecognitionRepository>();
            final officerId = authViewModel.currentUser?.officerId ?? 'mock-officer-uuid-001';
            return BulletinBoardScreen(
              repository: repo,
              officerId: officerId,
            );
          },
        ),
        GoRoute(
          path: '/governance-trust',
          builder: (context, state) {
            final repo = context.read<IGovernanceRepository>();
            return GovernanceTrustScreen(
              repository: repo,
            );
          },
        ),
        GoRoute(
          path: '/offline-sync',
          builder: (context, state) {
            final syncEngine = context.read<ISyncEngine>();
            final queueService = context.read<IOfflineQueueService>();
            final networkInfo = context.read<INetworkInfo>();
            final encStorage = context.read<IEncryptedLocalStorageService>();
            final appLockService = context.read<IAppLockService>();
            final screenSec = context.read<ScreenSecurityService>();

            return OfflineSyncScreen(
              syncEngine: syncEngine,
              queueService: queueService,
              networkInfo: networkInfo,
              encryptedStorage: encStorage,
              appLockService: appLockService,
              screenSecurityService: screenSec,
            );
          },
        ),
        GoRoute(
          path: '/crisis',
          builder: (context, state) {
            final repo = context.read<ICrisisRepository>();
            final officerId = authViewModel.currentUser?.officerId ?? 'mock-officer-uuid-001';
            return CrisisScreen(
              viewModel: CrisisViewModel(repository: repo, officerId: officerId),
            );
          },
        ),
        GoRoute(
          path: '/observability',
          builder: (context, state) {
            final repo = context.read<IObservabilityRepository>();
            return ChangeNotifierProvider(
              create: (_) => ObservabilityViewModel(repository: repo),
              child: const ObservabilityScreen(),
            );
          },
        ),
        GoRoute(
          path: '/shadow-pilot',
          builder: (context, state) {
            final repo = context.read<IShadowPilotRepository>();
            return ChangeNotifierProvider(
              create: (_) => ShadowPilotViewModel(repository: repo),
              child: const ShadowPilotScreen(),
            );
          },
        ),
        GoRoute(
          path: '/live-pilot',
          builder: (context, state) {
            final repo = context.read<ILivePilotRepository>();
            return ChangeNotifierProvider(
              create: (_) => LivePilotViewModel(repository: repo),
              child: const LivePilotScreen(),
            );
          },
        ),
        GoRoute(
          path: '/scale-architecture',
          builder: (context, state) {
            final repo = context.read<IScaleRepository>();
            return ChangeNotifierProvider(
              create: (_) => ScaleViewModel(repository: repo),
              child: const ScaleArchitectureScreen(),
            );
          },
        ),
        GoRoute(
          path: '/expansion',
          builder: (context, state) {
            final repo = context.read<IExpansionRepository>();
            return ChangeNotifierProvider(
              create: (_) => ExpansionViewModel(repository: repo),
              child: const ExpansionScreen(),
            );
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.error}'),
        ),
      ),
    );
  }
}
