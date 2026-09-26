// lib/features/access_log/presentation/access_log_screen.dart
// Transparent access audit log screen visible to the officer

import 'package:flutter/material.dart';
import '../data/access_log_repository.dart';
import '../domain/access_log_entry.dart';

class AccessLogScreen extends StatefulWidget {
  final IAccessLogRepository repository;
  final String officerId;

  const AccessLogScreen({
    super.key,
    required this.repository,
    required this.officerId,
  });

  @override
  State<AccessLogScreen> createState() => _AccessLogScreenState();
}

class _AccessLogScreenState extends State<AccessLogScreen> {
  List<AccessLogEntry> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    final logs = await widget.repository.getAccessLogsForOfficer(widget.officerId);
    if (mounted) {
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Access History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: Colors.indigo.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.visibility, color: Colors.indigo.shade900),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Every access to your personal welfare data is recorded immutably. '
                            'Commanders cannot view individual clinical details without your knowledge.',
                            style: TextStyle(fontSize: 12, color: Colors.indigo.shade900, height: 1.4),

                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Access Log Entries (${_logs.length})',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_logs.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: Text('No access records found.')),
                    ),
                  )
                else
                  ..._logs.map((log) {
                    final isBreakGlass = log.action == 'BREAK_GLASS';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isBreakGlass ? Colors.red.shade100 : Colors.blue.shade100,
                          child: Icon(
                            isBreakGlass ? Icons.warning_amber_rounded : Icons.lock_open,
                            color: isBreakGlass ? Colors.red : Colors.blue,
                            size: 20,
                          ),
                        ),
                        title: Text(log.actionDisplay, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(
                          'Accessed by: ${log.actorRole}\n${log.reason != null ? 'Reason: ${log.reason}\n' : ''}'
                          '${log.timestamp.toLocal().toString().split('.').first}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        isThreeLine: log.reason != null,
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
