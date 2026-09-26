// lib/features/anonymous_reporting/presentation/anonymous_reporting_screen.dart
// Whistleblower portal with technical identity separation, cryptographic token lookup, and separate vigilance pipeline

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/anonymous_report_repository.dart';
import '../domain/anonymous_report.dart';
import '../domain/report_category.dart';
import 'anonymous_report_view_model.dart';

class AnonymousReportingScreen extends StatefulWidget {
  final IAnonymousReportRepository repository;

  const AnonymousReportingScreen({
    super.key,
    required this.repository,
  });

  @override
  State<AnonymousReportingScreen> createState() => _AnonymousReportingScreenState();
}

class _AnonymousReportingScreenState extends State<AnonymousReportingScreen> {
  late final AnonymousReportViewModel _viewModel;
  final TextEditingController _reportController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _tokenSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = AnonymousReportViewModel(repository: widget.repository);
  }

  @override
  void dispose() {
    _reportController.dispose();
    _unitController.dispose();
    _tokenSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Anonymous Welfare & Vigilance'),
              backgroundColor: Colors.blueGrey.shade900,
              foregroundColor: Colors.white,
              bottom: const TabBar(
                indicatorColor: Colors.amber,
                labelColor: Colors.amber,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(icon: Icon(Icons.shield_outlined), text: 'Submit Report'),
                  Tab(icon: Icon(Icons.search_outlined), text: 'Track Case'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildSubmitTab(),
                _buildTrackTab(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubmitTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTechnicalAnonymityBanner(),
        const SizedBox(height: 16),

        // Category dropdown
        Text(
          'Report Category',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ReportCategory>(
              value: _viewModel.selectedCategory,
              isExpanded: true,
              items: ReportCategory.values.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat.displayName, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) _viewModel.setCategory(val);
              },
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _viewModel.selectedCategory.description,
          style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 16),

        // General unit/sector
        Text(
          'General Formation / Battalion (Optional)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _unitController,
          decoration: const InputDecoration(
            hintText: 'e.g. 14 Rajputana Rifles (Sector North)',
            helperText: 'Do NOT specify fine-grained platoons, bunkers, or sentry posts.',
            border: OutlineInputBorder(),
          ),
          onChanged: _viewModel.setUnitIdentifier,
        ),
        const SizedBox(height: 16),

        // Incident details
        Text(
          'Incident or Concern Details',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _reportController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Provide specific facts, conditions, or observations. Do not reveal your personal identity unless you voluntarily choose to do so.',
            border: OutlineInputBorder(),
          ),
          onChanged: _viewModel.setReportText,
        ),
        const SizedBox(height: 16),

        if (_viewModel.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _viewModel.errorMessage!,
                    style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Submit Button
        ElevatedButton.icon(
          onPressed: _viewModel.isLoading ? null : _handleSubmit,
          icon: _viewModel.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send_rounded),
          label: const Text('Submit Whistleblower Report'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey.shade900,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),

        const SizedBox(height: 20),
        _buildWelfareVigilanceFirewallFootnote(),
      ],
    );
  }

  Widget _buildTrackTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.indigo.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.vpn_key_outlined, color: Colors.indigo.shade800),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Enter your confidential 16-character tracking token to check inquiry progress or read findings from the Vigilance Cell.',
                  style: TextStyle(fontSize: 12.5, color: Colors.indigo.shade900, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _tokenSearchController,
          decoration: const InputDecoration(
            labelText: 'Whistleblower Tracking Token',
            hintText: 'e.g. TK-DEMO-SAFE-0001',
            prefixIcon: Icon(Icons.tag),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: _viewModel.isSearching
              ? null
              : () => _viewModel.searchReport(_tokenSearchController.text),
          icon: const Icon(Icons.search),
          label: const Text('Check Investigation Status'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade800,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),

        const SizedBox(height: 20),

        if (_viewModel.trackedReport != null)
          _buildTrackedReportCard(_viewModel.trackedReport!)
        else if (_viewModel.errorMessage != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                _viewModel.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTechnicalAnonymityBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_person_outlined, color: Colors.amber.shade900, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Technical Identity Firewall Active',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Zero identification tracking: No device fingerprint, IP address, or user ID is recorded. Reports are routed directly to an independent Vigilance Cell outside unit command hierarchy.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.amber.shade900,
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

  Widget _buildTrackedReportCard(AnonymousReport report) {
    Color statusColor;
    String statusLabel;
    switch (report.status) {
      case 'under_review':
        statusColor = Colors.orange;
        statusLabel = 'Under Preliminary Review';
        break;
      case 'investigating':
        statusColor = Colors.blue;
        statusLabel = 'Active Inquiry Ongoing';
        break;
      case 'action_taken':
        statusColor = Colors.teal;
        statusLabel = 'Corrective Action Taken';
        break;
      case 'closed':
        statusColor = Colors.grey;
        statusLabel = 'Inquiry Concluded';
        break;
      default:
        statusColor = Colors.blueGrey;
        statusLabel = 'Received by Vigilance Cell';
    }

    return Card(
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
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Filed: ${_formatDate(report.submittedAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              report.category.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (report.unitIdentifierGeneral != null) ...[
              const SizedBox(height: 4),
              Text(
                'Formation: ${report.unitIdentifierGeneral}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              report.reportTextEncrypted,
              style: const TextStyle(fontSize: 13.5, height: 1.4),
            ),
            const Divider(height: 24),
            Text(
              'Official Vigilance Response',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.blueGrey.shade900,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                report.responseNotesEncrypted ?? 'Inquiry pending preliminary assessment. Findings and corrective actions will appear here.',
                style: TextStyle(
                  fontSize: 13,
                  color: report.responseNotesEncrypted != null ? Colors.black87 : Colors.grey.shade600,
                  fontStyle: report.responseNotesEncrypted != null ? FontStyle.normal : FontStyle.italic,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelfareVigilanceFirewallFootnote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Whistleblower Protection: Reports submitted through this channel bypass regimental chains of command and cannot be accessed by unit officers. Whistleblower tracking tokens are non-reversible.',
        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, height: 1.3),
      ),
    );
  }

  void _handleSubmit() async {
    final token = await _viewModel.submitReport();
    if (!mounted || token == null) return;

    _reportController.clear();
    _unitController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.teal),
            SizedBox(width: 8),
            Text('Report Dispatched'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your anonymous report has been dispatched to the Vigilance Cell.',
              style: TextStyle(fontSize: 13.5),
            ),
            const SizedBox(height: 14),
            const Text(
              'Your Unique Tracking Token:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.shade600),
              ),
              child: SelectableText(
                token,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'SAVE THIS TOKEN NOW. Because the system stores zero identity links, this token is your ONLY key to track inquiry updates or review actions taken.',
              style: TextStyle(fontSize: 11.5, color: Colors.amber.shade900, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: token));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tracking token copied to clipboard.')),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy Token'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('I Have Saved My Token'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
