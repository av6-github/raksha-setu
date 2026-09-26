// lib/features/security/presentation/offline_sync_screen.dart
// Screen for Offline Sync Management, Idempotency, On-Device Baseline, SMS Fallback, and Screen Security

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/networking/network_client.dart';
import '../../../core/security/screen_security_service.dart';
import '../../../core/storage/encrypted_local_storage_service.dart';
import '../../../core/storage/offline_fallback_service.dart';
import '../../../core/storage/offline_queue_service.dart';
import '../../../core/storage/on_device_baseline_engine.dart';
import '../../../core/storage/sync_engine.dart';
import '../data/app_lock_service.dart';

class OfflineSyncScreen extends StatefulWidget {
  final ISyncEngine syncEngine;
  final IOfflineQueueService queueService;
  final INetworkInfo networkInfo;
  final IEncryptedLocalStorageService encryptedStorage;
  final IAppLockService appLockService;
  final ScreenSecurityService screenSecurityService;

  const OfflineSyncScreen({
    super.key,
    required this.syncEngine,
    required this.queueService,
    required this.networkInfo,
    required this.encryptedStorage,
    required this.appLockService,
    required this.screenSecurityService,
  });

  @override
  State<OfflineSyncScreen> createState() => _OfflineSyncScreenState();
}

class _OfflineSyncScreenState extends State<OfflineSyncScreen> {
  bool _isAirplaneModeSimulated = false;
  LocalBaselineMetrics? _localBaseline;
  bool _isAppLockActive = false;
  String _generatedSmsPayload = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      _isAppLockActive = await widget.appLockService.isAppLockEnabled();
    } catch (_) {
      _isAppLockActive = false;
    }

    // Compute sample on-device baseline from local check-ins
    final mockLocalCheckIns = [
      {'sleep_hours': 6.5, 'workload_score': 10},
      {'sleep_hours': 6.0, 'workload_score': 11},
      {'sleep_hours': 5.5, 'workload_score': 12},
      {'sleep_hours': 5.0, 'workload_score': 14},
      {'sleep_hours': 4.5, 'workload_score': 15},
    ];
    _localBaseline = OnDeviceBaselineEngine.computeLocalBaseline(
      localCheckIns: mockLocalCheckIns,
    );

    _generatedSmsPayload = OfflineFallbackService.generateSmsCheckInPayload(
      officerToken: 'TK-8492-4102-9912',
      phq2Score: 1,
      gad2Score: 0,
      sleepHours: 6.5,
      workloadScore: 10,
    );

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final syncState = widget.syncEngine.currentSyncState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline-First & Sync Hardening'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Sync Status Card
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isAirplaneModeSimulated
                            ? Icons.airplanemode_active_rounded
                            : Icons.cloud_done_rounded,
                        color: _isAirplaneModeSimulated ? Colors.orange : Colors.green.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isAirplaneModeSimulated
                                  ? 'Simulated Airplane Mode (Offline)'
                                  : 'Network Connected',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Sync State: ${syncState.status.displayName}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isAirplaneModeSimulated,
                        onChanged: (val) {
                          setState(() {
                            _isAirplaneModeSimulated = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pending Offline Mutations: ${widget.queueService.queueLength}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          if (syncState.lastSyncedAt != null)
                            Text(
                              'Last sync: ${DateFormat('hh:mm:ss a').format(syncState.lastSyncedAt!)}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _isAirplaneModeSimulated
                            ? null
                            : () async {
                                await widget.syncEngine.syncPendingMutations();
                                setState(() {});
                              },
                        icon: widget.syncEngine.isSyncing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.sync_rounded, size: 16),
                        label: const Text('Sync Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 2. On-Device Baseline Engine Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.speed_rounded, color: Colors.deepPurple, size: 24),
                      const SizedBox(width: 10),
                      const Text(
                        'On-Device Rolling Baseline Engine',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Computes 4-6 week personal baseline and CUSUM shift detection entirely locally on-device without internet access.',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 12),
                  if (_localBaseline != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Samples', '${_localBaseline!.sampleCount} entries'),
                        _buildStat('Avg Sleep', '${_localBaseline!.meanSleep} hrs'),
                        _buildStat('Avg Workload', '${_localBaseline!.meanWorkload} hrs'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _localBaseline!.sleepShiftAlert
                            ? Colors.red.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _localBaseline!.sleepShiftAlert
                              ? Colors.red.shade300
                              : Colors.green.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _localBaseline!.sleepShiftAlert
                                ? Icons.warning_rounded
                                : Icons.check_circle_rounded,
                            color: _localBaseline!.sleepShiftAlert ? Colors.red : Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _localBaseline!.sleepShiftAlert
                                  ? 'CUSUM Alert: Sustained downward sleep shift detected on-device.'
                                  : 'On-device baseline normal. No CUSUM anomaly detected.',
                              style: TextStyle(
                                fontSize: 12,
                                color: _localBaseline!.sleepShiftAlert
                                    ? Colors.red.shade900
                                    : Colors.green.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3. Zero-Data Tactical Fallback Card (SMS & IVR)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sms_rounded, color: Colors.teal, size: 24),
                      const SizedBox(width: 10),
                      const Text(
                        'Tactical Zero-Data Fallback (SMS / IVR)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'For deep forward outposts without 4G/5G or Wi-Fi data connectivity.',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Encrypted SMS Check-In Gateway:',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _generatedSmsPayload,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Send to: ${OfflineFallbackService.designatedSmsGateway}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.phone_in_talk_rounded, size: 16, color: Colors.teal),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Toll-Free IVR: ${OfflineFallbackService.teleManasTollFree} (Tele-MANAS, Dial from any GSM handset)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 4. Screen Security & App Lock Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_rounded, color: Colors.indigo, size: 24),
                      const SizedBox(width: 10),
                      const Text(
                        'Device Privacy & Screen Hardening',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Screenshot & Screen-Recording Block', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Prevents capturing confidential clinical views (FLAG_SECURE policy)', style: TextStyle(fontSize: 11)),
                    value: widget.screenSecurityService.isScreenshotBlocked,
                    onChanged: (val) {
                      setState(() {
                        widget.screenSecurityService.setScreenshotProtection(val);
                      });
                    },
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isAppLockActive ? Icons.lock_clock_rounded : Icons.lock_open_rounded,
                            size: 18,
                            color: _isAppLockActive ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isAppLockActive
                                ? 'App Lock PIN Active (Biometric / 4-Digit)'
                                : 'App Lock Disabled',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
      ],
    );
  }
}
