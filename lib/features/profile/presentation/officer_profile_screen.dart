// lib/features/profile/presentation/officer_profile_screen.dart
// Officer profile screen with full transparent self-data review and firewall status

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/welfare_banner.dart';
import 'profile_view_model.dart';

class OfficerProfileScreen extends StatelessWidget {
  final ProfileViewModel viewModel;

  const OfficerProfileScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final profile = viewModel.profile;
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Officer Profile & Identity'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: viewModel.loadProfile,
              ),
            ],
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : profile == null
                  ? Center(
                      child: Text(viewModel.errorMessage ?? 'Profile not found'),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Profile Header Card
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  child: Text(
                                    profile.firstName.isNotEmpty ? profile.firstName[0] : 'O',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  profile.fullName,
                                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  profile.designation ?? 'Uniformed Personnel',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: profile.isAvailable ? Colors.green.shade100 : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    profile.dutyStatusDisplay,
                                    style: TextStyle(
                                      color: profile.isAvailable ? Colors.green.shade900 : Colors.orange.shade900,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const WelfareBanner(),
                        const SizedBox(height: 16),

                        // Service Information Section
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Service Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const Divider(),
                                _infoTile(Icons.badge, 'Service Number', profile.serviceNumber),
                                _infoTile(Icons.apartment, 'Unit / Deployment', profile.unitName ?? '105 RAF Battalion'),
                                _infoTile(Icons.calendar_today, 'Date of Joining', profile.dateOfJoining.toIso8601String().split('T').first),
                                _infoTile(Icons.bloodtype, 'Blood Group', profile.bloodGroup ?? 'B+'),
                                _infoTile(Icons.person_outline, 'Gender', profile.gender ?? 'Male'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Trust & Privacy Navigation Buttons
                        Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.rule_folder_outlined, color: Colors.blue),
                                title: const Text('Consent Centre'),
                                subtitle: const Text('Manage granular family and biometrics sharing'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => context.push('/consent'),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.history, color: Colors.indigo),
                                title: const Text('Data Access Log'),
                                subtitle: const Text('Transparent audit log of who accessed your records'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => context.push('/access-log'),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.lock_clock_outlined, color: Colors.purple),
                                title: const Text('Local App Lock & Security'),
                                subtitle: const Text('Configure PIN and auto-lock timeout'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => context.push('/app-lock'),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.delete_outline, color: Colors.red),
                                title: const Text('Data Retention & Deletion'),
                                subtitle: const Text('Request purge of voluntary biometrics or media'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => context.push('/data-retention'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Full Self-Data Transparency View
                        Card(
                          color: Colors.grey.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.verified_user, color: Colors.teal),
                                    const SizedBox(width: 8),
                                    Text('Self-Data Transparency Guarantee', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Under the Welfare Architecture, uniformed personnel have the statutory right to view all stored self-data. No secret scoring or shadow evaluation exists.',
                                  style: TextStyle(fontSize: 12, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

}
