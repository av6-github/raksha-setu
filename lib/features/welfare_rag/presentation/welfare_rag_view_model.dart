// lib/features/welfare_rag/presentation/welfare_rag_view_model.dart
// Presentation ViewModel managing Welfare Scheme RAG dialogue, citations, and ingestion metrics

import 'package:flutter/foundation.dart';
import '../data/welfare_rag_repository.dart';
import '../domain/rag_retrieval_result.dart';

class RagChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<SourceCitation> citations;
  final double confidenceScore;
  final bool isLowConfidence;
  final String language;

  const RagChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.citations = const [],
    this.confidenceScore = 1.0,
    this.isLowConfidence = false,
    this.language = 'en',
  });
}

class WelfareRagViewModel extends ChangeNotifier {
  final IWelfareRagRepository repository;

  final List<RagChatMessage> _messages = [];
  bool _isQuerying = false;
  String? _errorMessage;
  Map<String, dynamic>? _ingestionStatus;

  WelfareRagViewModel({required this.repository}) {
    _initializeWelcomeMessage();
  }

  List<RagChatMessage> get messages => List.unmodifiable(_messages);
  bool get isQuerying => _isQuerying;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get ingestionStatus => _ingestionStatus;

  void _initializeWelcomeMessage() {
    _messages.add(
      RagChatMessage(
        text: 'Jai Hind! I am your Welfare Scheme Assistant. I answer questions about official MHA and WARB benefits (Ayushman CAPF, PMSS scholarships, Bharat Ke Veer, Ex-Gratia, and pensions) with verified citations and zero fabricated claims.\n\nHow may I assist you or your family today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> sendQuery(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    // 1. Add User Message
    _messages.add(
      RagChatMessage(
        text: cleanQuery,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    _isQuerying = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await repository.queryWelfareAssistant(cleanQuery);

      _messages.add(
        RagChatMessage(
          text: result.answer,
          isUser: false,
          timestamp: DateTime.now(),
          citations: result.sourceCitations,
          confidenceScore: result.confidenceScore,
          isLowConfidence: result.isLowConfidence,
          language: result.detectedLanguage,
        ),
      );
    } catch (e) {
      _errorMessage = 'Query failed: $e';
    } finally {
      _isQuerying = false;
      notifyListeners();
    }
  }

  Future<void> loadIngestionStatus() async {
    try {
      _ingestionStatus = await repository.getIngestionStatus();
      notifyListeners();
    } catch (_) {
      // Keep existing
    }
  }
}
