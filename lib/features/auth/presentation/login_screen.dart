// lib/features/auth/presentation/login_screen.dart
// RakshaSetu - Armed Forces Welfare & Resilience Platform
// Revamped Login Screen with Arctic Frost Aura and Liquid Glass Design

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/rakshasetu_theme.dart';
import '../../../shared/widgets/aura_background.dart';
import '../../../shared/widgets/liquid_glass_card.dart';
import '../../../shared/widgets/welfare_banner.dart';
import '../../../shared/widgets/kinetic_dots_loader.dart';
import '../domain/user_role.dart';
import '../presentation/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final authVm = context.read<AuthViewModel>();
    final success = await authVm.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      _routeForRole(authVm.currentRole);
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVm.errorMessage ?? 'Sign in failed. Please try again.'),
          backgroundColor: RakshaSetuColors.rose600,
        ),
      );
    }
  }

  void _routeForRole(UserRole role) {
    switch (role) {
      case UserRole.commander:
        context.go('/commander');
        break;
      case UserRole.counsellor:
        context.go('/counsellor');
        break;
      case UserRole.welfareOfficer:
        context.go('/welfare');
        break;
      case UserRole.family:
        context.go('/family');
        break;
      case UserRole.officer:
      default:
        context.go('/dashboard');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: RakshaSetuColors.background,
      body: AuraBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header & Military Welfare Crest
                      Column(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: const Color(0x6622D3EE), width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x330891B2),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/images/rakshasetu_logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  decoration: BoxDecoration(
                                    gradient: RakshaSetuColors.crestGradient,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.shield_rounded,
                                    size: 40,
                                    color: RakshaSetuColors.cyan400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text.rich(
                            const TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: Color(0xFF0A1F2C),
                              ),
                              children: const [
                                TextSpan(text: 'Raksha'),
                                TextSpan(
                                  text: 'Setu',
                                  style: TextStyle(color: Color(0xFF0891B2)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Armed Forces Welfare & Resilience Platform',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: RakshaSetuColors.slate600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            loc.translate('tagline'),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontStyle: FontStyle.italic,
                              color: RakshaSetuColors.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Firewall Status Badge
                      const Center(child: WelfareBanner(compact: false)),
                      const SizedBox(height: 20),

                      // Liquid Glass Card Form
                      LiquidGlassCard(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              loc.translate('login'),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: RakshaSetuColors.slate900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Sign in with your verified Service credentials',
                              style: TextStyle(
                                fontSize: 12,
                                color: RakshaSetuColors.slate500,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              style: const TextStyle(fontSize: 13.5, color: RakshaSetuColors.slate900),
                              decoration: InputDecoration(
                                labelText: loc.translate('email'),
                                labelStyle: const TextStyle(fontSize: 12.5, color: RakshaSetuColors.slate600),
                                hintText: 'officer@force.gov.in',
                                hintStyle: const TextStyle(fontSize: 12, color: RakshaSetuColors.slate400),
                                prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: RakshaSetuColors.azure),
                              ),
                              validator: (value) {
                                if (!_submitted) return null;
                                if (value == null || value.trim().isEmpty) {
                                  return 'Service email is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              style: const TextStyle(fontSize: 13.5, color: RakshaSetuColors.slate900),
                              decoration: InputDecoration(
                                labelText: loc.translate('password'),
                                labelStyle: const TextStyle(fontSize: 12.5, color: RakshaSetuColors.slate600),
                                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: RakshaSetuColors.azure),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    size: 19,
                                    color: RakshaSetuColors.slate500,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (value) {
                                if (!_submitted) return null;
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Submit Button
                            authVm.isLoading
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Center(
                                      child: KineticDotsLoader.compact(
                                        size: 13,
                                        label: 'Authenticating...',
                                      ),
                                    ),
                                  )
                                : MetalButton(
                                    label: loc.translate('login'),
                                    icon: const Icon(Icons.login_rounded, size: 18, color: Colors.white),
                                    onPressed: _submit,
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Quick Role Demo Sign-In
                      LiquidGlassCard(
                        borderRadius: 18,
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.touch_app_rounded, size: 16, color: RakshaSetuColors.azure),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Evaluation Demo Sign-In (Select Role):',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Public Sans',
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: RakshaSetuColors.slate800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _buildRoleChip(
                                  label: 'Officer (Vikram)',
                                  icon: Icons.person_rounded,
                                  onTap: () async {
                                    await authVm.signInAsDemo(
                                      UserRole.officer,
                                      customEmail: 'officer1@raksha.gov.in',
                                      specificOfficerId: '3790a74c-61c7-4e69-9448-eac79eeac022',
                                    );
                                    if (context.mounted) context.go('/dashboard');
                                  },
                                ),
                                _buildRoleChip(
                                  label: 'Commander',
                                  icon: Icons.shield_rounded,
                                  onTap: () async {
                                    await authVm.signInAsDemo(
                                      UserRole.commander,
                                      customEmail: 'commander1@raksha.gov.in',
                                    );
                                    if (context.mounted) context.go('/commander');
                                  },
                                ),
                                _buildRoleChip(
                                  label: 'Welfare Officer',
                                  icon: Icons.people_alt_rounded,
                                  onTap: () async {
                                    await authVm.signInAsDemo(
                                      UserRole.welfareOfficer,
                                      customEmail: 'welfare1@raksha.gov.in',
                                    );
                                    if (context.mounted) context.go('/welfare');
                                  },
                                ),
                                _buildRoleChip(
                                  label: 'Counsellor',
                                  icon: Icons.psychology_rounded,
                                  onTap: () async {
                                    await authVm.signInAsDemo(
                                      UserRole.counsellor,
                                      customEmail: 'counsellor1@raksha.gov.in',
                                    );
                                    if (context.mounted) context.go('/counsellor');
                                  },
                                ),
                                _buildRoleChip(
                                  label: 'Family Member',
                                  icon: Icons.family_restroom_rounded,
                                  onTap: () async {
                                    await authVm.signInAsDemo(
                                      UserRole.family,
                                      customEmail: 'family1@raksha.gov.in',
                                    );
                                    if (context.mounted) context.go('/family');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Emergency 24x7 Hotline
                      Center(
                        child: TextButton.icon(
                          onPressed: () => context.push('/crisis'),
                          icon: const Icon(Icons.phone_in_talk_rounded, size: 16, color: RakshaSetuColors.rose600),
                          label: const Text(
                            '24x7 CAPF Tele-MANAS Crisis Helpline',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: RakshaSetuColors.rose600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0C2340),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: RakshaSetuColors.azure),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: RakshaSetuColors.slate800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
