// lib/features/team_cohesion/presentation/team_cohesion_screen.dart
// Screen for viewing Unit Team Sessions and opting into confidential 1-on-1 alternatives

import 'package:flutter/material.dart';
import '../data/team_session_repository.dart';
import '../domain/session_attendance.dart';
import '../domain/team_session.dart';
import 'team_session_view_model.dart';

class TeamCohesionScreen extends StatefulWidget {
  final ITeamSessionRepository repository;
  final String unitId;
  final String officerId;

  const TeamCohesionScreen({
    super.key,
    required this.repository,
    this.unitId = 'unit-alpha',
    this.officerId = 'mock-officer-uuid-001',
  });

  @override
  State<TeamCohesionScreen> createState() => _TeamCohesionScreenState();
}

class _TeamCohesionScreenState extends State<TeamCohesionScreen> {
  late final TeamSessionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TeamSessionViewModel(repository: widget.repository);
    _loadData();
  }

  void _loadData() {
    _viewModel.loadSessions(
      unitId: widget.unitId,
      officerId: widget.officerId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Team Cohesion & Psychoeducation'),
            backgroundColor: Colors.teal.shade800,
            foregroundColor: Colors.white,
          ),
          body: _viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Anti-Stress Grouping Guarantee Card
                      _buildEthicalGuaranteeBanner(),
                      const SizedBox(height: 16),

                      Text(
                        'Scheduled Unit Sessions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),

                      if (_viewModel.sessions.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Text('No team sessions scheduled for this unit.'),
                          ),
                        )
                      else
                        ..._viewModel.sessions.map((session) {
                          final attendance = _viewModel.attendanceMap[session.id];
                          return _buildSessionCard(session, attendance);
                        }),

                      const SizedBox(height: 16),
                      _buildWelfareFirewallNotice(),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildEthicalGuaranteeBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade300, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, color: Colors.teal.shade800, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anti-Stress Grouping Guarantee',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sessions are scheduled strictly by unit/shift rosters. Sorting or segregating personnel by stress scores or clinical risk is architecturally prohibited.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.teal.shade900,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(TeamSession session, SessionAttendance? attendance) {
    final is1on1 = attendance?.optedForIndividualAlternative == true;
    final isAttended = attendance?.attended == true;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    session.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (session.isCompulsory)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.orange.shade400),
                    ),
                    child: Text(
                      'Unit Routine',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                session.topic.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Facilitator & Location
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${session.facilitatorName} (${session.facilitatorRole})',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Text(
                  '${_formatDate(session.scheduledAt)} • ${session.durationMinutes} mins',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
                if (session.targetShift != null) ...[
                  const SizedBox(width: 8),
                  Text('• ${session.targetShift}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.place_outlined, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    session.location,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Attendance Action / Status
            if (is1on1) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.indigo.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Opted for Confidential 1-on-1 Alternative',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.indigo.shade900,
                            ),
                          ),
                          Text(
                            'Private session scheduled with facilitator. Zero stigma, no command visibility.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.indigo.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (isAttended) ...[
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Attendance Confirmed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmAttendance(session.id),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Confirm Attendance'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showIndividualAlternativeDialog(session),
                    icon: const Icon(Icons.lock_person_outlined, size: 18),
                    label: const Text('1-on-1 Alternative'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.indigo.shade700,
                      side: BorderSide(color: Colors.indigo.shade300),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWelfareFirewallNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Confidentiality Policy: Attendance preferences and psychoeducation feedback are protected under the Welfare-HR firewall. Opting for a 1-on-1 individual alternative has zero bearing on performance appraisals (ACRs) or postings.',
        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, height: 1.3),
      ),
    );
  }

  void _confirmAttendance(String sessionId) async {
    final success = await _viewModel.confirmAttendance(
      sessionId: sessionId,
      officerId: widget.officerId,
    );
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance successfully confirmed.')),
      );
    }
  }

  void _showIndividualAlternativeDialog(TeamSession session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Colors.indigo),
            SizedBox(width: 8),
            Text('1-on-1 Alternative'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Topic: ${session.title}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'You may choose to complete this session individually and confidentially with the facilitator instead of in a squad group setting.',
              style: TextStyle(fontSize: 13, height: 1.3),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Confidentiality Guarantee: Your commanding officers and peers are NOT notified of this choice. It is recorded simply as routine module fulfillment.',
                style: TextStyle(fontSize: 11.5, color: Colors.indigo),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await _viewModel.optForIndividualAlternative(
                sessionId: session.id,
                officerId: widget.officerId,
              );
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Requested confidential 1-on-1 alternative session.'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm 1-on-1 Request'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
