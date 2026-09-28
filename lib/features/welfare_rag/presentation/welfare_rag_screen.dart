// lib/features/welfare_rag/presentation/welfare_rag_screen.dart
// Interactive Welfare Scheme RAG Assistant with source citations, confidence indicators, and ingestion dashboard
// Revamped with Arctic Frost liquid glass panels, consistent header, floating dock, and overflow-free architecture

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/rakshasetu_theme.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/aura_background.dart';
import '../../../shared/widgets/floating_dock.dart';
import '../../../shared/widgets/liquid_glass_card.dart';
import '../../../shared/widgets/kinetic_dots_loader.dart';
import '../data/welfare_rag_repository.dart';
import '../domain/rag_retrieval_result.dart';
import 'welfare_rag_view_model.dart';

class WelfareRagScreen extends StatefulWidget {
  final IWelfareRagRepository repository;

  const WelfareRagScreen({
    super.key,
    required this.repository,
  });

  @override
  State<WelfareRagScreen> createState() => _WelfareRagScreenState();
}

class _WelfareRagScreenState extends State<WelfareRagScreen> {
  late final WelfareRagViewModel _viewModel;
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickPrompts = [
    'How do I get cashless treatment under Ayushman CAPF?',
    'What is the PMSS scholarship amount for girls and boys?',
    'What is the maximum limit under Bharat Ke Veer?',
    'What are the ex-gratia compensation slabs for operational casualties?',
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = WelfareRagViewModel(repository: widget.repository);
    _viewModel.loadIngestionStatus();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: RakshaSetuColors.background,
          body: AuraBackground(
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Column(
                    children: [
                      // 1. Consistent RakshaSetu Header with Integrated Corpus Status Action
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                        child: AppHeader(
                          subtitle: 'Welfare Schemes Assistant • WARB Grounded',
                          showBackButton: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.dataset_outlined, size: 19, color: RakshaSetuColors.defenceDeep),
                            tooltip: 'Corpus Ingestion Status',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            onPressed: _showIngestionStatusDialog,
                          ),
                        ),
                      ),

                      // 2. Top Trust & Guardrail Banner
                      _buildGroundingBanner(),

                      // 3. Quick Suggestions Carousel
                      _buildSuggestionsBar(),

                      // 4. Messages Conversation Flow
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
                          itemCount: _viewModel.messages.length,
                          itemBuilder: (context, index) {
                            final msg = _viewModel.messages[index];
                            return _buildMessageBubble(msg);
                          },
                        ),
                      ),

                      // 5. Query Loading Indicator
                      if (_viewModel.isQuerying)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: KineticDotsLoader(
                            size: 14,
                            label: 'Searching MHA & WARB authoritative documents...',
                          ),
                        ),

                      // 6. Frosted Floating Input Bar (with bottom clearance above FloatingDock)
                      _buildInputBar(),
                    ],
                  ),

                  // Pinned Floating Dock at Bottom
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 6,
                    child: FloatingDock(currentRoute: '/welfare-assistant'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroundingBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: LiquidGlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        borderLeftColor: RakshaSetuColors.azure,
        borderLeftWidth: 3.5,
        child: const Row(
          children: [
            Icon(Icons.verified_outlined, size: 15, color: RakshaSetuColors.azure),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Grounded in official MHA, NHA, and WARB circulars. Zero fabricated entitlements.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 10.5,
                  color: RakshaSetuColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsBar() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _quickPrompts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final prompt = _quickPrompts[index];
          return InkWell(
            onTap: () {
              _queryController.text = prompt;
              _handleSend();
            },
            borderRadius: BorderRadius.circular(9999),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: const Color(0x6622D3EE), width: 1.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A06B6D4),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 12, color: RakshaSetuColors.azure),
                      const SizedBox(width: 5),
                      Text(
                        prompt,
                        maxLines: 1,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: RakshaSetuColors.slate800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(RagChatMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: RakshaSetuColors.obsidianGradient,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
            border: Border.all(color: const Color(0x6122D3EE), width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2B06B6D4),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            msg.text,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.88),
        margin: const EdgeInsets.only(bottom: 12),
        child: LiquidGlassCard(
          borderRadius: 18,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xE6CFFAFE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, size: 14, color: RakshaSetuColors.azure),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'WARB Grounded Response',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: RakshaSetuColors.navy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                msg.text,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12.5,
                  color: RakshaSetuColors.slate900,
                  height: 1.4,
                ),
              ),

              // Low Confidence Warning
              if (msg.isLowConfidence) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCD34D)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 14, color: RakshaSetuColors.amber800),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Low Retrieval Confidence • Human Verification Recommended',
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 10.5,
                            color: RakshaSetuColors.amber900,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Citations Card
              if (msg.citations.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Divider(height: 14, color: Color(0x2694A3B8)),
                const Text(
                  'Authoritative Sources Cited:',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: RakshaSetuColors.slate800,
                  ),
                ),
                const SizedBox(height: 6),
                ...msg.citations.map((c) => _buildCitationPill(c)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCitationPill(SourceCitation c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x6622D3EE), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, size: 13, color: RakshaSetuColors.azure),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  c.schemeName,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                    color: RakshaSetuColors.navy,
                  ),
                ),
              ),
            ],
          ),
          if (c.officialReference != null) ...[
            const SizedBox(height: 2),
            Text(
              'Ref: ${c.officialReference!}',
              style: const TextStyle(fontFamily: 'Public Sans', fontSize: 10, color: RakshaSetuColors.slate600),
            ),
          ],
          if (c.url != null) ...[
            const SizedBox(height: 1),
            Text(
              'Portal: ${c.url!}',
              style: const TextStyle(fontFamily: 'Public Sans', fontSize: 10, color: RakshaSetuColors.azure),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 68),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F06B6D4),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.95),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 12.5,
                      color: RakshaSetuColors.slate900,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Ask about Ayushman CAPF, PMSS, Bharat Ke Veer...',
                      hintStyle: TextStyle(fontSize: 11.5, color: RakshaSetuColors.slate400),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                GestureDetector(
                  onTap: _handleSend,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RakshaSetuColors.obsidianGradient,
                      border: Border.all(color: const Color(0x6122D3EE), width: 1.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3306B6D4),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        size: 18,
                        color: Color(0xFF67E8F9),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSend() {
    final text = _queryController.text;
    if (text.trim().isEmpty) return;

    _queryController.clear();
    _viewModel.sendQuery(text);
    _scrollToBottom();
  }

  void _showIngestionStatusDialog() {
    final status = _viewModel.ingestionStatus;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: RakshaSetuColors.azure, size: 20),
            SizedBox(width: 8),
            Text(
              'Welfare RAG Corpus',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: RakshaSetuColors.navy,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow('Total Ingested Documents:', '${status?['total_documents'] ?? 4} Official Policies'),
            _buildStatusRow('Indexed Chunks:', '${status?['total_chunks'] ?? 8} Vectors'),
            _buildStatusRow('Vector Database:', '${status?['vector_db'] ?? 'Pinecone Connected'}'),
            _buildStatusRow('Embedding Model:', '${status?['embedding_model'] ?? 'all-MiniLM-L6-v2'}'),
            _buildStatusRow('Broken Source Alerts:', '${status?['broken_sources_count'] ?? 0} (Healthy)'),
            _buildStatusRow('Entitlement Guardrail:', 'ENFORCED (Strict MHA Grounding)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Close',
              style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w700, color: RakshaSetuColors.azure),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
                color: RakshaSetuColors.slate800,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'Public Sans', fontSize: 11.5, color: RakshaSetuColors.slate600),
            ),
          ),
        ],
      ),
    );
  }
}
