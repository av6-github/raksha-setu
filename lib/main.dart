// lib/main.dart
// Raksha Welfare Application Entrypoint

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

import 'core/config/app_config.dart';
import 'core/localization/app_localizations.dart';
import 'core/logging/app_logger.dart';
import 'core/networking/network_client.dart';
import 'core/routing/app_router.dart';
import 'core/security/secure_storage_service.dart';
import 'core/storage/offline_queue_service.dart';
import 'core/storage/sync_engine.dart';
import 'core/storage/encrypted_local_storage_service.dart';
import 'core/security/screen_security_service.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_view_model.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/consent/data/consent_repository.dart';
import 'features/security/data/app_lock_service.dart';
import 'features/access_log/data/access_log_repository.dart';
import 'features/data_retention/data/data_retention_repository.dart';
import 'features/checkins/data/check_in_repository.dart';
import 'features/assessments/data/assessment_repository.dart';
import 'features/biometrics/data/biometric_repository.dart';
import 'features/hrms/data/hrms_repository.dart';
import 'features/analytics/data/baseline_repository.dart';
import 'features/risk/data/risk_repository.dart';
import 'features/interventions/data/intervention_repository.dart';
import 'features/crisis/data/crisis_repository.dart';
import 'features/welfare_dashboard/data/welfare_repository.dart';
import 'features/counsellor_dashboard/data/counsellor_repository.dart';
import 'features/commander_dashboard/data/commander_repository.dart';
import 'features/family/data/family_repository.dart';
import 'features/team_cohesion/data/team_session_repository.dart';
import 'features/anonymous_reporting/data/anonymous_report_repository.dart';
import 'features/performance/data/performance_repository.dart';
import 'features/welfare_rag/data/welfare_rag_repository.dart';
import 'features/bulletin/data/bulletin_recognition_repository.dart';
import 'features/trust/data/governance_repository.dart';
import 'features/observability/data/observability_repository.dart';
import 'features/shadow_pilot/data/shadow_pilot_repository.dart';
import 'features/live_pilot/data/live_pilot_repository.dart';
import 'features/scale/data/scale_repository.dart';
import 'features/expansion/data/expansion_repository.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize environment configuration
  final config = AppConfig.prototype();
  AppConfig.initialize(config);

  // 2. Initialize SharedPreferences & Secure Storage
  final prefs = await SharedPreferences.getInstance();
  final secureStorage = SecureStorageService();

  // 3. Initialize Supabase
  sp.SupabaseClient? supabaseClient;
  try {
    await sp.Supabase.initialize(
      url: config.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: config.supabaseAnonKey,
    );

    supabaseClient = sp.Supabase.instance.client;
    AppLogger.info('Supabase client initialized successfully');
  } catch (e) {
    AppLogger.warning('Supabase initialization failed or running offline', error: e);
  }

  // 4. Initialize Network Info & Offline Queue Services
  final networkInfo = NetworkInfo();
  final offlineQueue = OfflineQueueService(prefs: prefs);
  final encryptedStorage = EncryptedLocalStorageService(prefs: prefs);
  final screenSecurityService = ScreenSecurityService();
  final syncEngine = SyncEngine(
    queueService: offlineQueue,
    networkInfo: networkInfo,
    supabaseClient: supabaseClient,
  );

  // 5. Initialize Auth Repository & View Model
  final authRepository = AuthRepository(
    client: supabaseClient,
    secureStorage: secureStorage,
  );
  final authViewModel = AuthViewModel(authRepository: authRepository);

  // 6. Initialize Phase 2 Repositories
  final profileRepository = ProfileRepository(client: supabaseClient);
  final consentRepository = ConsentRepository(client: supabaseClient);
  final appLockService = AppLockService(secureStorage: secureStorage);
  final accessLogRepository = AccessLogRepository(client: supabaseClient);
  final dataRetentionRepository = DataRetentionRepository(client: supabaseClient);
  final checkInRepository = CheckInRepository(
    client: supabaseClient,
    offlineQueue: offlineQueue,
    networkInfo: networkInfo,
  );
  final assessmentRepository = AssessmentRepository(
    client: supabaseClient,
    offlineQueue: offlineQueue,
    networkInfo: networkInfo,
  );
  final biometricRepository = BiometricRepository(
    client: supabaseClient,
    offlineQueue: offlineQueue,
    networkInfo: networkInfo,
    consentRepository: consentRepository,
  );
  final hrmsRepository = HrmsRepository(client: supabaseClient);
  final baselineRepository = BaselineRepository(client: supabaseClient);
  final riskRepository = RiskRepository(client: supabaseClient);
  final interventionRepository = InterventionRepository(client: supabaseClient);
  final crisisRepository = CrisisRepository(client: supabaseClient);
  final welfareRepository = WelfareRepository(client: supabaseClient);
  final counsellorRepository = CounsellorRepository(client: supabaseClient);
  final commanderRepository = CommanderRepository(client: supabaseClient);
  final familyRepository = FamilyRepository(client: supabaseClient);
  final teamSessionRepository = TeamSessionRepository(client: supabaseClient);
  final anonymousReportRepository = AnonymousReportRepository(client: supabaseClient);
  final performanceRepository = PerformanceRepository(client: supabaseClient);
  final welfareRagRepository = WelfareRagRepository(client: supabaseClient);
  final bulletinRecognitionRepository = BulletinRecognitionRepository(client: supabaseClient);
  final governanceRepository = GovernanceRepository(client: supabaseClient);
  final observabilityRepository = ObservabilityRepository(supabase: supabaseClient);
  final shadowPilotRepository = ShadowPilotRepository(supabase: supabaseClient);
  final livePilotRepository = LivePilotRepository(supabase: supabaseClient);
  final scaleRepository = ScaleRepository(supabase: supabaseClient);
  final expansionRepository = ExpansionRepository(supabase: supabaseClient);

  runApp(
    MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: config),
        Provider<ISecureStorageService>.value(value: secureStorage),
        Provider<INetworkInfo>.value(value: networkInfo),
        Provider<IOfflineQueueService>.value(value: offlineQueue),
        Provider<IEncryptedLocalStorageService>.value(value: encryptedStorage),
        Provider<ScreenSecurityService>.value(value: screenSecurityService),
        Provider<ISyncEngine>.value(value: syncEngine),
        Provider<IAuthRepository>.value(value: authRepository),
        Provider<IProfileRepository>.value(value: profileRepository),
        Provider<IConsentRepository>.value(value: consentRepository),
        Provider<IAppLockService>.value(value: appLockService),
        Provider<IAccessLogRepository>.value(value: accessLogRepository),
        Provider<IDataRetentionRepository>.value(value: dataRetentionRepository),
        Provider<ICheckInRepository>.value(value: checkInRepository),
        Provider<IAssessmentRepository>.value(value: assessmentRepository),
        Provider<IBiometricRepository>.value(value: biometricRepository),
        Provider<IHrmsRepository>.value(value: hrmsRepository),
        Provider<IBaselineRepository>.value(value: baselineRepository),
        Provider<IRiskRepository>.value(value: riskRepository),
        Provider<IInterventionRepository>.value(value: interventionRepository),
        Provider<ICrisisRepository>.value(value: crisisRepository),
        Provider<IWelfareRepository>.value(value: welfareRepository),
        Provider<ICounsellorRepository>.value(value: counsellorRepository),
        Provider<ICommanderRepository>.value(value: commanderRepository),
        Provider<IFamilyRepository>.value(value: familyRepository),
        Provider<ITeamSessionRepository>.value(value: teamSessionRepository),
        Provider<IAnonymousReportRepository>.value(value: anonymousReportRepository),
        Provider<IPerformanceRepository>.value(value: performanceRepository),
        Provider<IWelfareRagRepository>.value(value: welfareRagRepository),
        Provider<IBulletinRecognitionRepository>.value(value: bulletinRecognitionRepository),
        Provider<IGovernanceRepository>.value(value: governanceRepository),
        Provider<IObservabilityRepository>.value(value: observabilityRepository),
        Provider<IShadowPilotRepository>.value(value: shadowPilotRepository),
        Provider<ILivePilotRepository>.value(value: livePilotRepository),
        Provider<IScaleRepository>.value(value: scaleRepository),
        Provider<IExpansionRepository>.value(value: expansionRepository),
        ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
      ],
      child: const RakshaWelfareApp(),
    ),
  );


}


class RakshaWelfareApp extends StatelessWidget {
  const RakshaWelfareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final router = AppRouter.createRouter(authViewModel);

    return MaterialApp.router(
      title: 'Raksha Welfare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Military Deep Blue
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
