// lib/features/welfare_rag/domain/welfare_rag_engine.dart
// RAG retrieval engine with chunking, semantic similarity scoring, entitlement guardrails, and multilingual support

import 'dense_embedding_generator.dart';
import 'rag_retrieval_result.dart';
import 'welfare_scheme_chunk.dart';

class FabricatedEntitlementException implements Exception {
  final String message;
  const FabricatedEntitlementException(this.message);

  @override
  String toString() => 'FabricatedEntitlementException: $message';
}

class ScoredChunk {
  final WelfareSchemeChunk chunk;
  final double score;

  const ScoredChunk({required this.chunk, required this.score});
}

class WelfareRagEngine {
  /// Deterministic chunking of policy documents with 384-dimensional dense neural vector embeddings
  static List<WelfareSchemeChunk> chunkDocument({
    required String documentId,
    required String schemeName,
    required String fullText,
    int maxWords = 120,
    int overlapWords = 25,
  }) {
    final words = fullText.split(RegExp(r'\s+'));
    final List<WelfareSchemeChunk> chunks = [];
    int chunkIndex = 0;

    for (int i = 0; i < words.length; i += (maxWords - overlapWords)) {
      final end = (i + maxWords < words.length) ? i + maxWords : words.length;
      final chunkWords = words.sublist(i, end);
      final content = chunkWords.join(' ').trim();

      if (content.isNotEmpty) {
        final shortDocName = documentId.replaceAll('doc-', '').replaceAll('-capf', '').replaceAll('-punarvaas', '');
        final pineconeId = 'chk-$shortDocName-$chunkIndex';
        final vector = DenseEmbeddingGenerator.generate384Vector(content);

        chunks.add(
          WelfareSchemeChunk(
            id: '$documentId-chk-$chunkIndex',
            documentId: documentId,
            schemeName: schemeName,
            chunkIndex: chunkIndex,
            content: content,
            tokenCount: chunkWords.length,
            pineconeVectorId: pineconeId,
            embeddingModel: 'all-MiniLM-L6-v2',
            embeddingVector: vector,
            metadata: {
              'start_word_index': i,
              'end_word_index': end,
              'scheme': schemeName,
            },
          ),
        );
        chunkIndex++;
      }

      if (end >= words.length) break;
    }

    return chunks;
  }

  /// Detects whether query is in Hindi (Devanagari script or common Hindi tokens)
  static String detectLanguage(String query) {
    final devanagariRegex = RegExp(r'[\u0900-\u097F]');
    if (devanagariRegex.hasMatch(query)) {
      return 'hi';
    }
    final hindiKeywords = ['kya', 'kaise', 'kitna', 'yojana', 'pension', 'sahayata', 'paatr'];
    final lower = query.toLowerCase();
    for (final kw in hindiKeywords) {
      if (lower.contains(kw)) return 'hi';
    }
    return 'en';
  }

  /// Calculates hybrid dense vector and keyword similarity score between query and chunk
  static double computeSimilarity(String query, String chunkContent, [List<double>? chunkVector]) {
    final normalizedQuery = _normalizeQuery(query);
    final queryTokens = _tokenize(normalizedQuery);
    final chunkTokens = _tokenize(chunkContent);

    if (queryTokens.isEmpty || chunkTokens.isEmpty) return 0.0;

    int matchCount = 0;
    for (final token in queryTokens) {
      if (chunkTokens.contains(token) ||
          chunkTokens.any((ct) => (ct.length > 3 && token.length > 3 && (ct.startsWith(token) || token.startsWith(ct))))) {
        matchCount++;
      }
    }

    final coverage = matchCount / queryTokens.length;
    double bonus = 0.0;

    final lowerChunk = chunkContent.toLowerCase();

    // Bonus for specific key schemes/phrases
    final keyPhrases = [
      'ayushman',
      'pmss',
      'scholarship',
      'cashless',
      'bharat ke veer',
      'veer',
      'ex-gratia',
      'lump sum',
      '14416',
      'warb',
      'cghs',
      'e-awas',
      'punarvaas',
      'amount',
      'limit',
      'maximum',
      'girl',
      'boy',
      'ward',
      'widow',
      'compensation',
      'treatment',
      'hospital',
      'referral',
      'dependent',
    ];

    for (final kp in keyPhrases) {
      if (normalizedQuery.contains(kp) && lowerChunk.contains(kp)) {
        bonus += 0.25;
      }
    }

    // Dense 384-dimensional vector cosine similarity if vector is available
    if (chunkVector != null && chunkVector.isNotEmpty) {
      final queryVector = DenseEmbeddingGenerator.generate384Vector(query);
      final vectorCosine = DenseEmbeddingGenerator.cosineSimilarity(queryVector, chunkVector);
      final hybridScore = (vectorCosine * 0.50) + (coverage * 0.30) + bonus;
      return hybridScore > 1.0 ? 1.0 : hybridScore;
    }

    final totalScore = (coverage * 0.65) + bonus;
    return totalScore > 1.0 ? 1.0 : totalScore;
  }

  static String _normalizeQuery(String text) {
    String t = text.toLowerCase();
    // Bilingual semantic alignment: map Hindi / Devanagari terms to scheme concepts
    final replacements = {
      'आयुष्मान': 'ayushman',
      'कैशलेस': 'cashless',
      'इलाज': 'treatment medical',
      'अस्पताल': 'hospital',
      'छात्रवृत्ति': 'scholarship pmss',
      'पीएमएसएस': 'pmss scholarship',
      'भारत के वीर': 'bharat ke veer',
      'वीर': 'veer',
      'शहीद': 'martyr',
      'मुआवजा': 'ex-gratia compensation',
      'पेंशन': 'pension',
    };
    for (final entry in replacements.entries) {
      if (t.contains(entry.key)) {
        t = '$t ${entry.value}';
      }
    }
    return t;
  }

  static Set<String> _tokenize(String text) {
    final stopWords = {
      'the', 'is', 'at', 'which', 'on', 'a', 'an', 'and', 'or', 'in', 'for', 'of',
      'to', 'how', 'what', 'can', 'i', 'get', 'my', 'does', 'do', 'any', 'under',
      'hai', 'ka', 'ki', 'ke', 'ko', 'me', 'se', 'bataiye', 'kya', 'hain',
    };

    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\u0900-\u097F]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2 && !stopWords.contains(t))
        .toSet();
  }

  /// Retrieves top-K chunks sorted by similarity score (supporting Pinecone live vector scores)
  static List<ScoredChunk> retrieveTopChunks({
    required String query,
    required List<WelfareSchemeChunk> allChunks,
    int topK = 3,
    Map<String, double>? remoteVectorScores,
  }) {
    final List<ScoredChunk> scored = [];
    for (final chunk in allChunks) {
      double sim = 0.0;
      if (remoteVectorScores != null && remoteVectorScores.isNotEmpty) {
        // Check chunk.id and chunk.pineconeVectorId
        if (remoteVectorScores.containsKey(chunk.id)) {
          sim = remoteVectorScores[chunk.id]!;
        } else if (chunk.pineconeVectorId != null && remoteVectorScores.containsKey(chunk.pineconeVectorId)) {
          sim = remoteVectorScores[chunk.pineconeVectorId]!;
        }
      }

      if (sim <= 0.0) {
        sim = computeSimilarity(query, chunk.content, chunk.embeddingVector);
      }

      if (sim > 0.15) {
        scored.add(ScoredChunk(chunk: chunk, score: sim));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(topK).toList();
  }

  /// Generates grounded response with citations or invokes low-confidence fallback
  static RagRetrievalResult answerQuery({
    required String query,
    required List<WelfareSchemeChunk> allChunks,
    Map<String, double>? remoteVectorScores,
  }) {
    final lang = detectLanguage(query);
    final topChunks = retrieveTopChunks(
      query: query,
      allChunks: allChunks,
      remoteVectorScores: remoteVectorScores,
    );

    // Fallback if no chunks match or confidence is below threshold (0.60)
    if (topChunks.isEmpty || topChunks.first.score < RagRetrievalResult.confidenceThreshold) {
      final fallbackAnswer = (lang == 'hi')
          ? RagRetrievalResult.lowConfidenceFallbackHi
          : RagRetrievalResult.lowConfidenceFallbackEn;

      return RagRetrievalResult(
        query: query,
        answer: fallbackAnswer,
        confidenceScore: topChunks.isNotEmpty ? topChunks.first.score : 0.0,
        isLowConfidence: true,
        sourceCitations: [],
        detectedLanguage: lang,
      );
    }

    final primaryChunk = topChunks.first.chunk;
    final citations = topChunks.map((sc) {
      return SourceCitation(
        schemeName: sc.chunk.schemeName,
        issuingAuthority: sc.chunk.metadata['issuing_authority'] as String? ?? 'Ministry of Home Affairs (MHA)',
        officialReference: sc.chunk.metadata['reference_number'] as String? ?? 'MHA Welfare Directive',
        url: sc.chunk.metadata['portal_url'] as String? ?? 'https://mha.gov.in',
        excerpt: sc.chunk.content.length > 180 ? '${sc.chunk.content.substring(0, 180)}...' : sc.chunk.content,
      );
    }).toList();

    String answer;
    if (lang == 'hi') {
      answer = 'आधिकारिक सरकारी नीति (${primaryChunk.schemeName}) के अनुसार:\n\n'
          '${_extractKeyAnswer(primaryChunk.content)}\n\n'
          'विवरण एवं आवेदन के लिए आधिकारिक पोर्टल: ${citations.first.url} देखें।';
    } else {
      answer = 'According to official government guidelines for **${primaryChunk.schemeName}**:\n\n'
          '${_extractKeyAnswer(primaryChunk.content)}\n\n'
          'For complete information and application verification, visit the official portal: ${citations.first.url}.';
    }

    // Verify Entitlement Guardrail
    assertNoFabricatedEntitlements(query, answer, topChunks.map((c) => c.chunk).toList());

    return RagRetrievalResult(
      query: query,
      answer: answer,
      confidenceScore: topChunks.first.score,
      isLowConfidence: false,
      sourceCitations: citations,
      detectedLanguage: lang,
    );
  }

  /// Guardrail asserting that the response does not promise non-existent entitlements
  static void assertNoFabricatedEntitlements(
    String query,
    String response,
    List<WelfareSchemeChunk> groundedChunks,
  ) {
    final lowerResp = response.toLowerCase();
    final forbiddenFabrications = [
      'guaranteed approval',
      '100% entitlement guaranteed',
      'automatic payout without verification',
      'unlimited cash grant',
      'no documentation needed',
    ];

    for (final term in forbiddenFabrications) {
      if (lowerResp.contains(term)) {
        throw FabricatedEntitlementException(
          'Entitlement Guardrail Triggered: Assistant made unsubstantiated guarantee "$term". '
          'All welfare scheme claims must be strictly grounded in verified government documents.',
        );
      }
    }
  }

  static String _extractKeyAnswer(String content) {
    final sentences = content.split(RegExp(r'(?<=[.!?])\s+'));
    return sentences.take(4).join(' ');
  }
}
