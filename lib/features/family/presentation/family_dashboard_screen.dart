// lib/features/family/presentation/family_dashboard_screen.dart
// Dedicated portal for enrolled family members: Morale Vault uploads, Call-Home prompts, and resilience guides
// Styled with Arctic Frost glassmorphism, persistent RakshaSetu branding, and zero-overflow layouts

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/rakshasetu_theme.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/aura_background.dart';
import '../../../shared/widgets/floating_dock.dart';
import '../../../shared/widgets/liquid_glass_card.dart';
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
        backgroundColor: RakshaSetuColors.background,
        body: AuraBackground(
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    // Consistent Header with RakshaSetu Branding
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                      child: AppHeader(
                        subtitle: 'Family Support Portal • Morale & Kinship Grid',
                        showBackButton: true,
                        onSignOut: () => authVm?.signOut(),
                        trailing: IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 19, color: RakshaSetuColors.azure),
                          tooltip: 'Refresh',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          onPressed: () => vm?.loadAll(),
                        ),
                      ),
                    ),

                    // Frosted TabBar Navigation
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: RakshaSetuColors.azure,
                        indicatorWeight: 3,
                        labelColor: RakshaSetuColors.navy,
                        unselectedLabelColor: RakshaSetuColors.slate500,
                        labelStyle: const TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w800, fontSize: 11),
                        tabs: const [
                          Tab(icon: Icon(Icons.video_library_rounded, size: 16), text: 'Morale Vault'),
                          Tab(icon: Icon(Icons.phone_in_talk_rounded, size: 16), text: 'Flash Connect'),
                          Tab(icon: Icon(Icons.menu_book_rounded, size: 16), text: 'Resilience Guides'),
                        ],
                      ),
                    ),

                    // OPSEC Safeguard Banner
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xB3E0F2FE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x660284C7)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_user_rounded, size: 15, color: RakshaSetuColors.azure),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'OPSEC Safeguard: Voice & video messages pass automated scans to protect tactical security.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0369A1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (vm?.isLoading ?? false)
                      const LinearProgressIndicator(
                        minHeight: 2.5,
                        backgroundColor: Color(0x3322D3EE),
                        valueColor: AlwaysStoppedAnimation<Color>(RakshaSetuColors.azure),
                      ),

                    // Content View
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 620),
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildMoraleVaultTab(context, vm),
                              _buildFlashConnectTab(context, vm),
                              _buildResilienceGuidesTab(context, vm),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Pinned Bottom Dock
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: FloatingDock(currentRoute: '/family'),
                ),
              ],
            ),
          ),
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 96),
      children: [
        // Upload Action Card
        LiquidGlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(16),
          borderLeftColor: const Color(0xFF9333EA), // purple-600
          borderLeftWidth: 3.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0x269333EA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic_rounded, color: Color(0xFF7E22CE), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Send Morale Voice Note or Video',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: RakshaSetuColors.slate900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Record a warm voice message or upload a family video clip. Your officer can listen and watch offline even at forward border outposts.',
                style: TextStyle(fontFamily: 'Public Sans', fontSize: 11.5, color: RakshaSetuColors.slate600, height: 1.35),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 34,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A1F2C),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF67E8F9)),
                  label: const Text(
                    'Record or Upload Message',
                    style: TextStyle(fontFamily: 'Public Sans', fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  onPressed: () => _showUploadDialog(context, vm),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        const Text(
          'SENT MESSAGES & OPSEC CLEARANCE',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 0.5,
            color: RakshaSetuColors.slate700,
          ),
        ),
        const SizedBox(height: 8),

        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'No morale messages sent yet.',
                style: TextStyle(fontFamily: 'Public Sans', fontSize: 13, color: RakshaSetuColors.slate500),
              ),
            ),
          )
        else
          ...items.map((item) {
            final isApproved = item.isAvailableToOfficer;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LiquidGlassCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(12),
                borderLeftColor: isApproved ? RakshaSetuColors.emerald500 : RakshaSetuColors.amber500,
                borderLeftWidth: 3.0,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.mediaType == 'audio' ? const Color(0x260284C7) : const Color(0x26F97316),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.mediaType == 'audio' ? Icons.audiotrack_rounded : Icons.videocam_rounded,
                        color: item.mediaType == 'audio' ? RakshaSetuColors.azure : Colors.deepOrange,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.transcriptOrCaption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Public Sans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: RakshaSetuColors.slate900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isApproved ? const Color(0x2610B981) : const Color(0x26F59E0B),
                                  borderRadius: BorderRadius.circular(9999),
                                  border: Border.all(
                                    color: isApproved ? const Color(0x6610B981) : const Color(0x66F59E0B),
                                  ),
                                ),
                                child: Text(
                                  item.securityStatus.displayName,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: isApproved ? RakshaSetuColors.emerald800 : RakshaSetuColors.amber800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sent by ${item.familyMemberName} • Type: ${item.mediaType.toUpperCase()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Public Sans', fontSize: 10.5, color: RakshaSetuColors.slate500),
                          ),
                          if (item.opsecFlags.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Flags: ${item.opsecFlags.join(", ")}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontFamily: 'Public Sans', fontSize: 10, color: RakshaSetuColors.rose600, fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildFlashConnectTab(BuildContext context, FamilyViewModel? vm) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 96),
      children: [
        // Officer Wellness High-Level Status
        LiquidGlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(16),
          borderLeftColor: const Color(0xFF0D9488),
          borderLeftWidth: 3.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Officer Connection Status',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: RakshaSetuColors.slate900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0x2610B981),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: const Color(0x6610B981)),
                    ),
                    child: const Text(
                      'SAFE & ACTIVE',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Connected Officer: Major Vikram S. (12th Battalion)',
                style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w700, fontSize: 13, color: RakshaSetuColors.slate800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Under privacy-by-design guidelines, specific geographic coordinates and combat assignments are protected. Routine wellness check-in confirmation received within the last 48 hours.',
                style: TextStyle(fontFamily: 'Public Sans', fontSize: 11.5, color: RakshaSetuColors.slate600, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Call-Home Prompt Card
        LiquidGlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(16),
          borderLeftColor: RakshaSetuColors.azure,
          borderLeftWidth: 3.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.phone_forwarded_rounded, color: RakshaSetuColors.azure, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Send Call-Home Reminder',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: RakshaSetuColors.slate900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Sends a discreet notification to your officer asking them to take 5 minutes to call home. Delivered strictly during designated evening rest windows (6:00 PM – 10:00 PM) to avoid duty interruptions.',
                style: TextStyle(fontFamily: 'Public Sans', fontSize: 11.5, color: RakshaSetuColors.slate600, height: 1.35),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 34,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A1F2C),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 14, color: Color(0xFF67E8F9)),
                  label: const Text(
                    'Request Call Home',
                    style: TextStyle(fontFamily: 'Public Sans', fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  onPressed: () async {
                    await vm?.triggerCallHomePrompt();
                  },
                ),
              ),
              if (vm?.callHomeStatusMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0x260284C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x660284C7)),
                  ),
                  child: Text(
                    vm!.callHomeStatusMessage!,
                    style: const TextStyle(fontFamily: 'Public Sans', fontSize: 11, fontWeight: FontWeight.bold, color: RakshaSetuColors.azure),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 24x7 Tele-MANAS Family Support Dialer
        LiquidGlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(16),
          borderLeftColor: const Color(0xFF6366F1), // indigo
          borderLeftWidth: 3.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.support_agent_rounded, color: Color(0xFF4F46E5), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '24×7 Family Helpline — Tele-MANAS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: RakshaSetuColors.slate900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Military life and separations bring unique family stressors. Trained counsellors are available 24 hours a day, free of cost.',
                style: TextStyle(fontFamily: 'Public Sans', fontSize: 11.5, color: RakshaSetuColors.slate600, height: 1.35),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 34,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0x666366F1)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  ),
                  icon: const Icon(Icons.call_rounded, size: 15, color: Color(0xFF4F46E5)),
                  label: const Text(
                    'Call Tele-MANAS (14416)',
                    style: TextStyle(fontFamily: 'Public Sans', fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dialing Tele-MANAS 14416 (Toll-Free)...')),
                    );
                  },
                ),
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 96),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final mod = modules[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LiquidGlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            borderLeftColor: RakshaSetuColors.azure,
            borderLeftWidth: 3.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        mod.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: RakshaSetuColors.slate900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x260284C7),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: const Color(0x660284C7)),
                      ),
                      child: Text(
                        '${mod.durationMinutes} MIN',
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.w800, color: RakshaSetuColors.azure),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  mod.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Public Sans', fontSize: 11.5, color: RakshaSetuColors.slate600, height: 1.35),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 30,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.play_circle_outline_rounded, size: 15, color: RakshaSetuColors.azure),
                      label: const Text('Open Guide', style: TextStyle(fontFamily: 'Public Sans', fontSize: 11, fontWeight: FontWeight.w700, color: RakshaSetuColors.azure)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0x660891B2)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening module: ${mod.title}')),
                        );
                      },
                    ),
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
          title: const Text('Record or Upload Morale Media', style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w800, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Media Type:', style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.bold, fontSize: 12.5)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Voice Note', style: TextStyle(fontFamily: 'Public Sans', fontSize: 11)),
                      selected: mediaType == 'audio',
                      selectedColor: const Color(0xFF0A1F2C),
                      labelStyle: TextStyle(
                        color: mediaType == 'audio' ? Colors.white : RakshaSetuColors.slate700,
                        fontWeight: mediaType == 'audio' ? FontWeight.w800 : FontWeight.w600,
                      ),
                      onSelected: (selected) {
                        if (selected) setDialogState(() => mediaType = 'audio');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Family Video', style: TextStyle(fontFamily: 'Public Sans', fontSize: 11)),
                      selected: mediaType == 'video',
                      selectedColor: const Color(0xFF0A1F2C),
                      labelStyle: TextStyle(
                        color: mediaType == 'video' ? Colors.white : RakshaSetuColors.slate700,
                        fontWeight: mediaType == 'video' ? FontWeight.w800 : FontWeight.w600,
                      ),
                      onSelected: (selected) {
                        if (selected) setDialogState(() => mediaType = 'video');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                const Text(
                  'Note: Avoid mentioning specific base names, sector numbers, or operational plans.',
                  style: TextStyle(fontFamily: 'Public Sans', fontSize: 10.5, color: RakshaSetuColors.slate500, fontStyle: FontStyle.italic),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A1F2C),
                foregroundColor: Colors.white,
              ),
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
                        backgroundColor: isSafe ? RakshaSetuColors.emerald800 : RakshaSetuColors.amber800,
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
