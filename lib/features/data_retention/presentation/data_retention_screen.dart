// lib/features/data_retention/presentation/data_retention_screen.dart
// Screen for managing data retention policies and requesting data purging

import 'package:flutter/material.dart';
import '../data/data_retention_repository.dart';

class DataRetentionScreen extends StatefulWidget {
  final IDataRetentionRepository repository;
  final String officerId;

  const DataRetentionScreen({
    super.key,
    required this.repository,
    required this.officerId,
  });

  @override
  State<DataRetentionScreen> createState() => _DataRetentionScreenState();
}

class _DataRetentionScreenState extends State<DataRetentionScreen> {
  List<DeletionRequestItem> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final reqs = await widget.repository.getDeletionRequests(widget.officerId);
    if (mounted) {
      setState(() {
        _requests = reqs;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmPurge(String type, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(
          'Are you sure you want to request purging of $type? '
          'Once purged, this data cannot be recovered.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Purge'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.repository.submitDeletionRequest(
        widget.officerId,
        type,
        'Officer initiated data deletion via Privacy Centre',
      );
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purge request submitted successfully.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Retention & Erasure'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Colors.red.shade900),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Statutory Right to Erasure: Voluntary biometrics and private media '
                            'can be purged permanently upon your request.',
                            style: TextStyle(fontSize: 12, color: Colors.red.shade900, height: 1.4),

                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text('Available Purge Actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.favorite_border, color: Colors.red),
                        title: const Text('Purge Voluntary Biometrics'),
                        subtitle: const Text('Deletes all recorded heart rate and sleep telemetry'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => _confirmPurge('voluntary_biometrics', 'Purge Biometrics'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.video_library_outlined, color: Colors.orange),
                        title: const Text('Purge Morale Vault Media'),
                        subtitle: const Text('Removes stored family audio and video recordings'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => _confirmPurge('morale_vault_media', 'Purge Morale Vault'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text('Past Deletion Requests (${_requests.length})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                if (_requests.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No active deletion requests.'),
                    ),
                  )
                else
                  ..._requests.map((r) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                        title: Text(r.typeDisplay, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Status: ${r.status.toUpperCase()} • Submitted: ${r.submittedAt.toIso8601String().split('T').first}'),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
