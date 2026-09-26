// test/unit/welfare_rag_test.dart
// Unit tests for Phase 14: Welfare Scheme RAG Assistant, Grounded Retrieval, Citations & Fallbacks

import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/features/welfare_rag/data/welfare_rag_repository.dart';
import 'package:raksha_welfare/features/welfare_rag/domain/welfare_rag_engine.dart';
import 'package:raksha_welfare/features/welfare_rag/domain/welfare_scheme_chunk.dart';

void main() {
  group('Phase 14: WelfareRagEngine (Retrieval & Guardrails)', () {
    test('chunkDocument breaks text into sequential overlapping chunks with metadata', () {
      final sampleText = List.generate(300, (i) => 'word$i').join(' ');
      final chunks = WelfareRagEngine.chunkDocument(
        documentId: 'doc-test',
        schemeName: 'Test Scheme',
        fullText: sampleText,
        maxWords: 100,
        overlapWords: 20,
      );

      expect(chunks.length, greaterThanOrEqualTo(3));
      expect(chunks[0].chunkIndex, equals(0));
      expect(chunks[1].chunkIndex, equals(1));
      expect(chunks[0].schemeName, equals('Test Scheme'));
      expect(chunks[0].embeddingModel, equals('all-MiniLM-L6-v2'));
    });

    test('detectLanguage detects Hindi and English queries', () {
      expect(WelfareRagEngine.detectLanguage('What is Ayushman CAPF?'), equals('en'));
      expect(WelfareRagEngine.detectLanguage('आयुष्मान सीएपीएफ योजना क्या है?'), equals('hi'));
      expect(WelfareRagEngine.detectLanguage('PMSS scholarship me kitna paisa milta hai?'), equals('hi'));
    });

    test('computeSimilarity scores query with matching keyphrases higher than unrelated text', () {
      final query = 'Ayushman CAPF cashless treatment for dependents';
      final matchText = 'Ayushman CAPF provides cashless medical treatment to serving personnel and dependent families.';
      final mismatchText = 'Cricket match was organized between battalion teams in the sports complex.';

      final matchScore = WelfareRagEngine.computeSimilarity(query, matchText);
      final mismatchScore = WelfareRagEngine.computeSimilarity(query, mismatchText);

      expect(matchScore, greaterThan(0.60));
      expect(mismatchScore, lessThan(0.20));
      expect(matchScore, greaterThan(mismatchScore));
    });

    test('assertNoFabricatedEntitlements throws FabricatedEntitlementException on unsubstantiated claims', () {
      final chunks = [
        const WelfareSchemeChunk(
          id: 'chk-1',
          documentId: 'doc-1',
          schemeName: 'Test',
          chunkIndex: 0,
          content: 'Standard grant.',
          tokenCount: 2,
        ),
      ];

      expect(
        () => WelfareRagEngine.assertNoFabricatedEntitlements(
          'Query',
          'You are promised guaranteed approval for ₹50 Lakh without verification.',
          chunks,
        ),
        throwsA(isA<FabricatedEntitlementException>()),
      );
    });
  });

  group('Phase 14: WelfareRagRepository & Retrieval Workflow', () {
    late WelfareRagRepository repository;

    setUp(() {
      repository = WelfareRagRepository();
    });

    test('Initializes with 5 authoritative MHA/WARB documents and chunks', () async {
      final docs = await repository.getIngestedDocuments();
      expect(docs.length, equals(5));
      expect(docs.any((d) => d.schemeName.contains('Ayushman CAPF')), isTrue);
      expect(docs.any((d) => d.schemeName.contains('Prime Minister')), isTrue);
      expect(docs.any((d) => d.schemeName.contains('Bharat Ke Veer')), isTrue);
      expect(docs.any((d) => d.schemeName.contains('Ex-Gratia')), isTrue);
      expect(docs.any((d) => d.schemeName.contains('e-Awas')), isTrue);

      final chunks = await repository.getAllChunks();
      expect(chunks.length, greaterThanOrEqualTo(4));
    });

    test('Answers Ayushman CAPF query with citations and portal links', () async {
      final res = await repository.queryWelfareAssistant('How to get cashless treatment under Ayushman CAPF?');

      expect(res.isLowConfidence, isFalse);
      expect(res.confidenceScore, greaterThanOrEqualTo(0.60));
      expect(res.answer, contains('Ayushman CAPF'));
      expect(res.sourceCitations.isNotEmpty, isTrue);
      expect(res.sourceCitations.first.url, contains('pmjay.gov.in'));
      expect(res.sourceCitations.first.officialReference, contains('MHA'));
    });

    test('Answers PMSS scholarship query for boys and girls amounts', () async {
      final res = await repository.queryWelfareAssistant('What is the PMSS scholarship amount for girls and boys?');

      expect(res.isLowConfidence, isFalse);
      expect(res.answer, contains('Prime Minister'));
      expect(res.sourceCitations.any((c) => c.schemeName.contains('PMSS') || c.schemeName.contains('Prime Minister')), isTrue);
      expect(res.sourceCitations.first.url, contains('scholarships.gov.in'));
    });

    test('Answers Bharat Ke Veer martyr assistance limit', () async {
      final res = await repository.queryWelfareAssistant('What is the maximum limit for Bharat Ke Veer financial assistance?');

      expect(res.isLowConfidence, isFalse);
      expect(res.answer, contains('Bharat Ke Veer'));
      expect(res.sourceCitations.first.url, contains('bharatkeveer.gov.in'));
    });

    test('Triggers low confidence fallback on completely unrelated query', () async {
      final res = await repository.queryWelfareAssistant('How to bake a chocolate strawberry cake in microwave?');

      expect(res.isLowConfidence, isTrue);
      expect(res.sourceCitations, isEmpty);
      expect(res.answer, contains('I cannot confirm this entitlement with high confidence'));
      expect(res.answer, contains('Unit Welfare Officer'));
    });

    test('Answers in Hindi when query is written in Hindi', () async {
      final res = await repository.queryWelfareAssistant('आयुष्मान सीएपीएफ योजना में कैशलेस इलाज कैसे मिलेगा?');

      expect(res.detectedLanguage, equals('hi'));
      expect(res.isLowConfidence, isFalse);
      expect(res.answer, contains('आधिकारिक सरकारी नीति'));
      expect(res.sourceCitations.isNotEmpty, isTrue);
    });

    test('Returns ingestion status with Pinecone vector DB metadata', () async {
      final status = await repository.getIngestionStatus();
      expect(status['total_documents'], equals(5));
      expect(status['vector_db'], contains('Pinecone'));
      expect(status['broken_sources_count'], equals(0));
      expect(status['entitlement_guardrail_status'], contains('ENFORCED'));
    });
  });
}
