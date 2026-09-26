// lib/features/auth/presentation/login_screen.dart
// Production-quality login screen with welfare firewall messaging and crisis exit

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../presentation/auth_view_model.dart';
import '../domain/user_role.dart';
import '../../../shared/widgets/welfare_banner.dart';

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
      switch (authVm.currentRole) {
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
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVm.errorMessage ?? 'Sign in failed. Please try again.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo & Title
                    Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc.translate('app_title'),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.translate('tagline'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),
                    const WelfareBanner(),
                    const SizedBox(height: 28),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: loc.translate('email'),
                        hintText: 'officer@force.gov.in',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (!_submitted) return null;
                        if (value == null || value.trim().isEmpty) {
                          return 'Service email is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: loc.translate('password'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
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

                    const SizedBox(height: 24),

                    // Sign In button
                    FilledButton(
                      onPressed: authVm.isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: authVm.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              loc.translate('login'),
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Quick Role Demo / Evaluation Sign In
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blueGrey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.touch_app_rounded, size: 16, color: Colors.blueGrey.shade700),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Quick Demo Sign-In (Select Role):',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              ActionChip(
                                avatar: const Icon(Icons.person_rounded, size: 14),
                                label: const Text('Officer 1 (Vikram)', style: TextStyle(fontSize: 11)),
                                onPressed: () async {
                                  await authVm.signInAsDemo(
                                    UserRole.officer,
                                    customEmail: 'officer1@raksha.gov.in',
                                    specificOfficerId: '3790a74c-61c7-4e69-9448-eac79eeac022',
                                  );
                                  if (context.mounted) context.go('/dashboard');
                                },
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.person_outline_rounded, size: 14),
                                label: const Text('Officer 2 (Priya)', style: TextStyle(fontSize: 11)),
                                onPressed: () async {
                                  await authVm.signInAsDemo(
                                    UserRole.officer,
                                    customEmail: 'officer2@raksha.gov.in',
                                    specificOfficerId: '10ff6159-a26e-420a-9f81-f1b1ec9c39ad',
                                  );
                                  if (context.mounted) context.go('/dashboard');
                                },
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.deepOrange),
                                label: const Text('Officer 3 (Arjun - High Risk)', style: TextStyle(fontSize: 11)),
                                onPressed: () async {
                                  await authVm.signInAsDemo(
                                    UserRole.officer,
                                    customEmail: 'officer3@raksha.gov.in',
                                    specificOfficerId: '9ba7cd91-fe4b-46a6-8011-38c183c55e70',
                                  );
                                  if (context.mounted) context.go('/dashboard');
                                },
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.military_tech_rounded, size: 14),
                                label: const Text('Commander (Col. Rajesh Sharma)', style: TextStyle(fontSize: 11)),
                                onPressed: () async {
                                  await authVm.signInAsDemo(UserRole.commander);
                                  if (context.mounted) context.go('/commander');
                                },
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.medical_services_rounded, size: 14),
                                label: const Text('Counsellor (Dr. Ananya Iyer)', style: TextStyle(fontSize: 11)),
                                onPressed: () async {
                                  await authVm.signInAsDemo(UserRole.counsellor);
                                  if (context.mounted) context.go('/counsellor');
                                },
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.volunteer_activism_rounded, size: 14),
                                label: const Text('Welfare Officer (Insp. Manoj Kumar)', style: TextStyle(fontSize: 11)),
                                onPressed: () async {
                                  await authVm.signInAsDemo(UserRole.welfareOfficer);
                                  if (context.mounted) context.go('/welfare');
                                },
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.family_restroom_rounded, size: 14),
                                label: const Text('Family (Meera - Spouse)', style: TextStyle(fontSize: 11)),
                                onPressed: () async {
                                  await authVm.signInAsDemo(
                                    UserRole.family,
                                    customEmail: 'family1@raksha.gov.in',
                                    specificOfficerId: '3790a74c-61c7-4e69-9448-eac79eeac022',
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

                    // Crisis/Emergency exit - always visible
                    OutlinedButton.icon(
                      onPressed: () => context.push('/crisis'),
                      icon: const Icon(Icons.emergency, color: Colors.redAccent),
                      label: const Text(
                        'Immediate Support / Crisis Line',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Privacy notice
                    Text(
                      'This system is consent-based and confidential. '
                      'Check-in responses are never used for ACR, promotion, or disciplinary purposes.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
