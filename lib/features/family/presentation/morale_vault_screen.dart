// lib/features/family/presentation/morale_vault_screen.dart
// Officer Morale Vault: Offline-cached audio voice notes and video messages from family

import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Morale Vault'),
        backgroundColor: Colors.amber.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadClearedVaultItems,
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline Deployment Reassurance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.amber.shade50,
            child: Row(
              children: [
                Icon(Icons.offline_pin_rounded, size: 22, color: Colors.amber.shade900),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Offline Morale Vault: Approved family voice and video notes are cached locally '
                    'so you can listen and recharge even when deployed without network access.',
                    style: TextStyle(fontSize: 11, color: Colors.amber.shade900, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(),

          Expanded(
            child: _items.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sentiment_satisfied_alt, size: 48, color: Colors.amber),
                          SizedBox(height: 12),
                          Text(
                            'No Morale Messages Yet',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Messages sent by your verified family members will appear here once cleared by security review.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final isPlaying = _currentlyPlayingId == item.id;
                      final isAudio = item.mediaType == 'audio';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.amber.shade100,
                                    child: Icon(
                                      isAudio ? Icons.record_voice_over_rounded : Icons.videocam_rounded,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.familyMemberName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        Text(
                                          '${isAudio ? "Voice Note" : "Video Clip"} • Received ${_formatDate(item.uploadedAt)}',
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Chip(
                                    avatar: const Icon(Icons.verified, size: 14, color: Colors.green),
                                    label: const Text('Cleared', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    backgroundColor: Colors.green.shade50,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Text(
                                  '"${item.transcriptOrCaption}"',
                                  style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, height: 1.3),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isPlaying ? Colors.amber.shade800 : Colors.indigo.shade800,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                                    label: Text(isPlaying ? 'Pause' : (isAudio ? 'Listen' : 'Watch')),
                                    onPressed: () {
                                      setState(() {
                                        _currentlyPlayingId = isPlaying ? null : item.id;
                                      });
                                    },
                                  ),
                                ],
                              ),
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

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
