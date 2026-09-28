// lib/features/family/presentation/morale_vault_screen.dart
// Officer Morale Vault: Offline-cached audio voice notes and video messages from family
// Styled with Arctic Frost theme, RakshaSetuScaffold, and LiquidGlassCards

import 'package:flutter/material.dart';
import '../../../core/theme/rakshasetu_theme.dart';
import '../../../shared/widgets/liquid_glass_card.dart';
import '../../../shared/widgets/rakshasetu_scaffold.dart';
import '../data/family_repository.dart';
import '../domain/morale_vault_item.dart';

class MoraleVaultScreen extends StatefulWidget {
  final IFamilyRepository repository;
  final String officerId;

  const MoraleVaultScreen({
    super.key,
    required this.repository,
    this.officerId = 'mock-officer-uuid-001',
  });

  @override
  State<MoraleVaultScreen> createState() => _MoraleVaultScreenState();
}

class _MoraleVaultScreenState extends State<MoraleVaultScreen> {
  bool _isLoading = false;
  List<MoraleVaultItem> _items = [];
  String? _currentlyPlayingId;

  @override
  void initState() {
    super.initState();
    _loadClearedVaultItems();
  }

  Future<void> _loadClearedVaultItems() async {
    setState(() => _isLoading = true);
    try {
      // HARD SECURITY RULE: includeQuarantined is FALSE for officers
      final items = await widget.repository.getMoraleVaultItems(
        widget.officerId,
        includeQuarantined: false,
      );
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RakshaSetuScaffold(
      currentRoute: '/morale-vault',
      subtitle: 'Family & Morale Vault • Offline Cached',
      showBackButton: true,
      trailing: IconButton(
        icon: const Icon(Icons.refresh_rounded, size: 19, color: RakshaSetuColors.slate700),
        tooltip: 'Refresh Vault',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        onPressed: _loadClearedVaultItems,
      ),
      body: Column(
        children: [
          // Reassurance Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: LiquidGlassCard(
              borderRadius: 14,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              borderLeftColor: RakshaSetuColors.amber800,
              borderLeftWidth: 3.5,
              child: const Row(
                children: [
                  Icon(Icons.offline_pin_rounded, size: 16, color: RakshaSetuColors.amber800),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Approved family voice & video notes are locally cached so you can listen anywhere, even offline.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 10.5,
                        color: RakshaSetuColors.slate800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: LinearProgressIndicator(
                color: RakshaSetuColors.azure,
                backgroundColor: Color(0x3322D3EE),
              ),
            ),

          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: LiquidGlassCard(
                        borderRadius: 22,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFEF3C7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.favorite_rounded, size: 28, color: RakshaSetuColors.amber800),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No Morale Messages Yet',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: RakshaSetuColors.slate900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Encrypted audio and video notes sent by your verified family members will appear here once cleared.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 11.5,
                                color: RakshaSetuColors.slate600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 90),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final isPlaying = _currentlyPlayingId == item.id;
                      final isAudio = item.mediaType == 'audio';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: LiquidGlassCard(
                          borderRadius: 18,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isAudio ? Icons.record_voice_over_rounded : Icons.videocam_rounded,
                                      color: RakshaSetuColors.amber800,
                                      size: 19,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.familyMemberName.isNotEmpty
                                              ? item.familyMemberName
                                              : 'Family Member Note',
                                          style: const TextStyle(
                                            fontFamily: 'Public Sans',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: RakshaSetuColors.slate900,
                                          ),
                                        ),
                                        Text(
                                          item.transcriptOrCaption.isNotEmpty
                                              ? item.transcriptOrCaption
                                              : 'Encrypted Family Voice Note',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Public Sans',
                                            fontSize: 10.5,
                                            color: RakshaSetuColors.slate500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Play/Pause Action
                                  IconButton(
                                    icon: Icon(
                                      isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                                      size: 34,
                                      color: RakshaSetuColors.azure,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _currentlyPlayingId = isPlaying ? null : item.id;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (isPlaying) ...[
                                const SizedBox(height: 10),
                                const LinearProgressIndicator(
                                  color: RakshaSetuColors.azure,
                                  backgroundColor: Color(0x3322D3EE),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
