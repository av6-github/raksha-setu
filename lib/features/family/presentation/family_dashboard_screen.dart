// lib/features/family/presentation/family_dashboard_screen.dart
// Dedicated portal for enrolled family members: Morale Vault uploads, Call-Home prompts, and resilience guides

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/auth_view_model.dart';
import 'family_view_model.dart';

class FamilyDashboardScreen extends StatefulWidget {
  final FamilyViewModel? viewModel;

  const FamilyDashboardScreen({super.key, this.viewModel});

  @override
  State<FamilyDashboardScreen> createState() => _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends State<FamilyDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final authVm = context.watch<AuthViewModel?>();

    Widget buildScaffold() {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Family Support Portal'),
          backgroundColor: Colors.purple.shade900,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () => vm?.loadAll(),
            ),
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              tooltip: 'Sign Out',
              onPressed: () => authVm?.signOut(),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.amberAccent,
            tabs: const [
              Tab(icon: Icon(Icons.video_library_rounded), text: 'Morale Vault'),
              Tab(icon: Icon(Icons.phone_in_talk_rounded), text: 'Flash Connect'),
              Tab(icon: Icon(Icons.menu_book_rounded), text: 'Resilience Guides'),
            ],
          ),
        ),
        body: Column(
          children: [
            // OPSEC Safeguard Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.purple.shade50,
              child: Row(
                children: [
                  Icon(Icons.verified_user_outlined, size: 20, color: Colors.purple.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Operational Security Notice: All shared voice and video messages pass through automated OPSEC filters '
                      'to prevent unintended location clues or tactical disclosures.',
                      style: TextStyle(fontSize: 11, color: Colors.purple.shade900),
                    ),
                  ),
                ],
              ),
            ),
            if (vm?.isLoading ?? false)
              const LinearProgressIndicator(),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMoraleVaultTab(context, vm),
                  _buildFlashConnectTab(context, vm),
                  _buildResilienceGuidesTab(context, vm),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (vm != null) {
      return ListenableBuilder(
        listenable: vm,
        builder: (context, _) => buildScaffold(),
      );
    }

    return buildScaffold();
  }

  Widget _buildMoraleVaultTab(BuildContext context, FamilyViewModel? vm) {
    final items = vm?.moraleItems ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Upload Action Card
        Card(
          elevation: 2,
          color: Colors.purple.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.mic_rounded, color: Colors.purple, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Send Morale Voice Note or Video',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Record a warm voice message or upload a family video clip. '
                  'Your officer can listen to and watch these offline even at forward stations.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade800,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Record or Upload Message'),
                  onPressed: () => _showUploadDialog(context, vm),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Sent Messages & Security Clearance',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),

        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text('No morale messages sent yet.')),
          )
        else
          ...items.map((item) {
            final isApproved = item.isAvailableToOfficer;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: item.mediaType == 'audio' ? Colors.indigo.shade50 : Colors.deepOrange.shade50,
                  child: Icon(
                    item.mediaType == 'audio' ? Icons.audiotrack_rounded : Icons.videocam_rounded,
                    color: item.mediaType == 'audio' ? Colors.indigo : Colors.deepOrange,
                  ),
                ),
                title: Text(
                  item.transcriptOrCaption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Sent by ${item.familyMemberName} • Type: ${item.mediaType.toUpperCase()}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    if (item.opsecFlags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Flags: ${item.opsecFlags.join(", ")}',
                          style: TextStyle(fontSize: 10, color: Colors.red.shade800),
                        ),
                      ),
                  ],
                ),
                trailing: Chip(
                  label: Text(
                    item.securityStatus.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isApproved ? Colors.green.shade900 : Colors.amber.shade900,
                    ),
                  ),
                  backgroundColor: isApproved ? Colors.green.shade50 : Colors.amber.shade50,
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildFlashConnectTab(BuildContext context, FamilyViewModel? vm) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Officer Wellness High-Level Status
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Officer Connection Status',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Chip(
                      label: const Text('SAFE & ACTIVE', style: TextStyle(color: Colors.white, fontSize: 10)),
                      backgroundColor: Colors.teal.shade700,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connected Officer: Major Vikram S. (12th Battalion)',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Under privacy-by-design guidelines, specific geographic coordinates and combat assignments are protected. '
                  'Routine wellness check-in confirmation received within the last 48 hours.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Call-Home Prompt Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.phone_forwarded_rounded, color: Colors.purple),
                    SizedBox(width: 8),
                    Text(
                      'Send Call-Home Reminder',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sends a discreet notification to your officer asking them to take 5 minutes to call home. '
                  'Delivered strictly during designated evening rest windows (6:00 PM – 10:00 PM) to avoid duty interruptions.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Request Call Home'),
                  onPressed: () async {
                    await vm?.triggerCallHomePrompt();
                  },
                ),
                if (vm?.callHomeStatusMessage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Text(
                      vm!.callHomeStatusMessage!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 24x7 Tele-MANAS Family Support Dialer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.indigo.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.support_agent_rounded, color: Colors.indigo),
                  SizedBox(width: 8),
                  Text(
                    '24×7 Family Helpline — Tele-MANAS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Military life and separations bring unique family stressors. Trained counsellors are available 24 hours a day, free of cost.',
                style: TextStyle(fontSize: 11),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade800,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.call, size: 16),
                label: const Text('Call Tele-MANAS (14416)'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dialing Tele-MANAS 14416 (Toll-Free)...')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResilienceGuidesTab(BuildContext context, FamilyViewModel? vm) {
    final modules = vm?.trainingModules ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final mod = modules[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        mod.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    Chip(
                      label: Text('${mod.durationMinutes} min', style: const TextStyle(fontSize: 10)),
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  mod.description,
                  style: const TextStyle(fontSize: 12, height: 1.3),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.play_circle_outline, size: 16),
                    label: const Text('Open Guide'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opening module: ${mod.title}')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUploadDialog(BuildContext context, FamilyViewModel? vm) {
    String mediaType = 'audio';
    _captionController.clear();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Record or Upload Morale Media'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Media Type:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Voice Note'),
                      selected: mediaType == 'audio',
                      onSelected: (selected) {
                        if (selected) setDialogState(() => mediaType = 'audio');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Family Video'),
                      selected: mediaType == 'video',
                      onSelected: (selected) {
                        if (selected) setDialogState(() => mediaType = 'video');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _captionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Message / Caption',
                    hintText: 'e.g. Thinking of you today! Kids did great at sports day.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Note: Avoid mentioning specific base names, sector numbers, or operational plans.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text('Submit Media'),
              onPressed: () async {
                if (_captionController.text.trim().isNotEmpty) {
                  Navigator.pop(ctx);
                  final item = await vm?.uploadMedia(
                    mediaType: mediaType,
                    mediaUrl: 'https://cloudinary.example.com/$mediaType/upload_${DateTime.now().millisecondsSinceEpoch}',
                    caption: _captionController.text.trim(),
                  );

                  if (context.mounted && item != null) {
                    final isSafe = item.isAvailableToOfficer;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isSafe
                              ? 'Message cleared OPSEC scan and added to Morale Vault!'
                              : 'Message flagged for review: ${item.opsecFlags.join(", ")}',
                        ),
                        backgroundColor: isSafe ? Colors.green.shade800 : Colors.amber.shade900,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
