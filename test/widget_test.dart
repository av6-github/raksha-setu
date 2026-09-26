import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:raksha_welfare/core/config/app_config.dart';
import 'package:raksha_welfare/features/auth/data/auth_repository.dart';
import 'package:raksha_welfare/features/auth/domain/app_user.dart';
import 'package:raksha_welfare/features/auth/domain/user_role.dart';
import 'package:raksha_welfare/features/auth/presentation/auth_view_model.dart';
import 'package:raksha_welfare/main.dart';
import 'package:raksha_welfare/shared/widgets/welfare_banner.dart';

class MockAuthRepository implements IAuthRepository {
  @override
  Future<AppUser?> getCurrentUser() async => null;

  @override
  Future<AppUser> signInWithPassword(String email, String password) async {
    return const AppUser(
      id: 'test-user-id',
      email: 'officer@force.gov.in',
      role: UserRole.officer,
    );
  }

  @override
  Future<void> signOut() async {}

  @override
  Stream<AppUser?> get authStateChanges => Stream.value(null);
}

void main() {
  setUp(() {
    AppConfig.initialize(AppConfig.prototype());
  });

  testWidgets('RakshaWelfareApp boots to LoginScreen with WelfareBanner', (WidgetTester tester) async {
    final mockRepo = MockAuthRepository();
    final authViewModel = AuthViewModel(authRepository: mockRepo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
        ],
        child: const RakshaWelfareApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app renders login elements and welfare firewall banner
    expect(find.text('Raksha Welfare'), findsWidgets);
    expect(find.byType(WelfareBanner), findsOneWidget);
  });
}
