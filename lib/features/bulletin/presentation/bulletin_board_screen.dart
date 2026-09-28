// lib/features/bulletin/presentation/bulletin_board_screen.dart
// Screen for Battalion Bulletin Board, Wall of Commendation, and Welfare Stories

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/rakshasetu_theme.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/aura_background.dart';
import '../../../shared/widgets/floating_dock.dart';
import '../../../shared/widgets/kinetic_dots_loader.dart';
import '../data/bulletin_recognition_repository.dart';
import '../domain/bulletin_event.dart';
import '../../recognition/domain/recognition_award.dart';
import 'bulletin_view_model.dart';

class BulletinBoardScreen extends StatelessWidget {
  final IBulletinRecognitionRepository repository;
  final String officerId;

  const BulletinBoardScreen({
    super.key,
    required this.repository,
    this.officerId = 'mock-officer-uuid-001',
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BulletinViewModel(
        repository: repository,
        officerId: officerId,
      ),
      child: const _BulletinBoardView(),
    );
  }
}

class _BulletinBoardView extends StatefulWidget {
  const _BulletinBoardView();

  @override
  State<_BulletinBoardView> createState() => _BulletinBoardViewState();
}

class _BulletinBoardViewState extends State<_BulletinBoardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BulletinViewModel>();

    // Listen to messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage!),
            backgroundColor: Colors.red.shade800,
          ),
        );
        vm.clearMessages();
      } else if (vm.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.successMessage!),
            backgroundColor: Colors.green.shade800,
          ),
        );
        vm.clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: RakshaSetuColors.background,
      floatingActionButton: _tabController.index == 1
          ? Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: FloatingActionButton.extended(
                onPressed: () => _showSendAppreciationDialog(context, vm),
                backgroundColor: RakshaSetuColors.navy,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.favorite_rounded, color: RakshaSetuColors.rose600),
                label: const Text('Give Appreciation', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            )
          : null,
      body: AuraBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  // Consistent RakshaSetu Header
                  const Padding(
                    padding: EdgeInsets.fromLTRB(14, 8, 14, 4),
                    child: AppHeader(
                      subtitle: 'Bulletin & Recognition • Hall of Fame',
                      showBackButton: true,
                    ),
                  ),

                  // TabBar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: RakshaSetuColors.gold,
                      indicatorWeight: 3,
                      labelColor: RakshaSetuColors.navy,
                      unselectedLabelColor: RakshaSetuColors.slate500,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                      tabs: const [
                        Tab(icon: Icon(Icons.event_note_rounded, size: 17), text: 'Events & Calendar'),
                        Tab(icon: Icon(Icons.military_tech_rounded, size: 17), text: 'Hall of Fame'),
                        Tab(icon: Icon(Icons.auto_stories_rounded, size: 17), text: 'Stories'),
                      ],
                    ),
                  ),

                  // Tab Views
                  Expanded(
                    child: vm.isLoading
                        ? const Center(
                            child: KineticDotsLoader(
                              size: 18,
                              label: 'Syncing activities & recognitions...',
                            ),
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildBulletinEventsTab(context, vm),
                              _buildRecognitionsTab(context, vm),
                              _buildTestimonialsTab(context, vm),
                            ],
                          ),
                  ),
                ],
              ),

              // Pinned Floating Dock
              const Positioned(
                left: 0,
                right: 0,
                bottom: 6,
                child: FloatingDock(currentRoute: '/bulletin'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletinEventsTab(BuildContext context, BulletinViewModel vm) {
    return Column(
      children: [
        // Search & Free-Time Filter Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'Search by location or event title...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _locationController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _locationController.clear();
                                  vm.filterByLocation('');
                                },
                              )
                            : null,
                        isDense: true,
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) => vm.filterByLocation(val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 18, color: Colors.blueGrey),
                      const SizedBox(width: 6),
                      Text(
                        'Show free-time events only',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  Switch(
                    value: vm.freeTimeOnly,
                    onChanged: (val) => vm.toggleFreeTimeOnly(val),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Horizontal Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All Events'),
                selected: vm.selectedCategory == null,
                onSelected: (_) => vm.filterByCategory(null),
                selectedColor: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
              ),
              const SizedBox(width: 8),
              ...EventCategory.values.map((cat) {
                final isSelected = vm.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(cat.icon, size: 16, color: isSelected ? Colors.white : cat.color),
                    label: Text(cat.displayName),
                    selected: isSelected,
                    selectedColor: cat.color.withValues(alpha: 0.3),
                    onSelected: (_) => vm.filterByCategory(isSelected ? null : cat),
                  ),
                );
              }),
            ],
          ),
        ),

        // Event List
        Expanded(
          child: vm.events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy_rounded, size: 54, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'No events found matching your filter',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Try clearing the location search or category filter',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 92),
                  itemCount: vm.events.length,
                  itemBuilder: (context, index) {
                    final event = vm.events[index];
                    return _buildEventCard(context, vm, event);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEventCard(BuildContext context, BulletinViewModel vm, BulletinEvent event) {
    final dateFormat = DateFormat('EEE, dd MMM yyyy · hh:mm a');
    final timeRange =
        '${dateFormat.format(event.eventStart)} - ${DateFormat('hh:mm a').format(event.eventEnd)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: event.category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(event.category.icon, size: 14, color: event.category.color),
                      const SizedBox(width: 5),
                      Text(
                        event.category.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: event.category.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (event.isRsvpd)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade600),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Attending',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              event.title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 15, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    timeRange,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              event.description,
              style: const TextStyle(fontSize: 14, height: 1.35),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => vm.toggleRsvp(event.id),
                  icon: Icon(
                    event.isRsvpd ? Icons.cancel_outlined : Icons.check_circle_outline_rounded,
                    size: 16,
                  ),
                  label: Text(event.isRsvpd ? 'Cancel Attendance' : 'RSVP / Interested'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: event.isRsvpd ? Colors.red.shade700 : const Color(0xFF1E3A8A),
                    side: BorderSide(
                      color: event.isRsvpd ? Colors.red.shade300 : const Color(0xFF1E3A8A),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecognitionsTab(BuildContext context, BulletinViewModel vm) {
    return Column(
      children: [
        // Sub-segment switcher: Wall of Commendation vs My Honors & Badges
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(
                value: 0,
                icon: Icon(Icons.public_rounded),
                label: Text('Wall of Commendation'),
              ),
              ButtonSegment<int>(
                value: 1,
                icon: Icon(Icons.badge_rounded),
                label: Text('My Honors & Badges'),
              ),
            ],
            selected: {vm.recognitionSubTab},
            onSelectionChanged: (set) => vm.setRecognitionSubTab(set.first),
          ),
        ),

        // OPSEC & Consent banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_rounded, color: Colors.blue.shade800, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  vm.recognitionSubTab == 0
                      ? 'Every public commendation is vetted for operational security (OPSEC) and requires explicit officer consent.'
                      : 'You maintain 100% control over public visibility. Toggle the consent switch on any badge to display it publicly or keep it private.',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // List View
        Expanded(
          child: vm.recognitionSubTab == 0
              ? _buildPublicWallList(vm)
              : _buildMyHonorsList(vm),
        ),
      ],
    );
  }

  Widget _buildPublicWallList(BulletinViewModel vm) {
    if (vm.publicRecognitions.isEmpty) {
      return const Center(
        child: Text('No public commendations published yet.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 92),
      itemCount: vm.publicRecognitions.length,
      itemBuilder: (context, index) {
        final rec = vm.publicRecognitions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: rec.category.color.withValues(alpha: 0.15),
                      child: Icon(rec.category.icon, color: rec.category.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Awarded to: ${rec.recipientName}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey.shade800,
                            ),
                          ),
                          Text(
                            'By: ${rec.awardedByName} · ${DateFormat('dd MMM yyyy').format(rec.awardedAt)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_open_rounded, size: 12, color: Colors.green.shade800),
                          const SizedBox(width: 3),
                          Text(
                            'Public',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '"${rec.citation}"',
                    style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyHonorsList(BulletinViewModel vm) {
    if (vm.myRecognitions.isEmpty) {
      return const Center(
        child: Text('No honors or recognitions recorded yet.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 92),
      itemCount: vm.myRecognitions.length,
      itemBuilder: (context, index) {
        final rec = vm.myRecognitions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: rec.category.color.withValues(alpha: 0.15),
                      child: Icon(rec.category.icon, color: rec.category.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'From: ${rec.awardedByName}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey.shade800,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMMM yyyy').format(rec.awardedAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '"${rec.citation}"',
                    style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, height: 1.3),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          rec.officerConsentForPublic
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          size: 16,
                          color: rec.officerConsentForPublic ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Display on Public Wall of Commendation',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: rec.officerConsentForPublic
                                ? Colors.green.shade800
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: rec.officerConsentForPublic,
                      onChanged: (val) => vm.updatePublicConsent(rec.id, val),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestimonialsTab(BuildContext context, BulletinViewModel vm) {
    if (vm.testimonials.isEmpty) {
      return const Center(child: Text('No stories published yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 92),
      itemCount: vm.testimonials.length,
      itemBuilder: (context, index) {
        final item = vm.testimonials[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.format_quote_rounded, color: Colors.teal.shade700, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.authorRoleDisplay,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.teal.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.content,
                  style: const TextStyle(fontSize: 14, height: 1.45),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.verified_rounded, size: 14, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Welfare Cell Verified Story',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSendAppreciationDialog(BuildContext context, BulletinViewModel vm) {
    final nameCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final citationCtrl = TextEditingController();
    RecognitionCategory category = RecognitionCategory.peerAppreciation;
    bool consentPublic = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.military_tech_rounded, color: Color(0xFF1E3A8A)),
                        const SizedBox(width: 8),
                        const Text(
                          'Give Peer Appreciation',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Colleague / Officer Name',
                        hintText: 'e.g. Head Constable Vikram Singh',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<RecognitionCategory>(
                      initialValue: category,
                      decoration: const InputDecoration(
                        labelText: 'Appreciation Category',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: RecognitionCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.displayName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => category = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Commendation Title',
                        hintText: 'e.g. Steady Composure Under Stress',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: citationCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Citation / Appreciation Message',
                        hintText: 'Describe how this officer demonstrated support or excellence (min 10 characters)...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: consentPublic,
                      title: const Text(
                        'Nominate for Public Wall of Commendation',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Will be published publicly after OPSEC review.',
                        style: TextStyle(fontSize: 11),
                      ),
                      onChanged: (val) {
                        setModalState(() => consentPublic = val ?? true);
                      },
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.security_rounded, size: 18, color: Colors.amber.shade900),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'OPSEC Notice: Do not include live convoy routes, forward patrol coordinates, or grid numbers. Sarcastic or punitive terms are blocked.',
                              style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final success = await vm.submitPeerAppreciation(
                            recipientName: nameCtrl.text,
                            title: titleCtrl.text,
                            citation: citationCtrl.text,
                            category: category,
                            consentForPublic: consentPublic,
                          );
                          if (success && sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('Submit Appreciation', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
