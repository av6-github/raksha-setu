// lib/features/welfare_rag/domain/welfare_scheme_chunk.dart
// Ingested text chunk with embedding metadata and vector identifier

class WelfareSchemeChunk {
  final String id;
  final String documentId;
  final String schemeName;
  final int chunkIndex;
  final String content;
  final int tokenCount;
  final String? pineconeVectorId;
  final String embeddingModel;
  final List<double>? embeddingVector;
  final Map<String, dynamic> metadata;

  const WelfareSchemeChunk({
    required this.id,
    required this.documentId,
    required this.schemeName,
    required this.chunkIndex,
    required this.content,
    required this.tokenCount,
    this.pineconeVectorId,
    this.embeddingModel = 'all-MiniLM-L6-v2',
    this.embeddingVector,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'document_id': documentId,
        'scheme_name': schemeName,
        'chunk_index': chunkIndex,
        'content': content,
        'token_count': tokenCount,
        'pinecone_vector_id': pineconeVectorId,
        'embedding_model': embeddingModel,
        'embedding_vector': embeddingVector,
        'metadata': metadata,
      };

  factory WelfareSchemeChunk.fromJson(Map<String, dynamic> json) {
    return WelfareSchemeChunk(
      id: json['id'] as String,
      documentId: json['document_id'] as String,
      schemeName: json['scheme_name'] as String? ??
          (json['metadata'] is Map ? (json['metadata'] as Map)['scheme_name'] as String? : null) ??
          'Welfare Scheme',
      chunkIndex: json['chunk_index'] as int? ?? 0,
      content: json['content'] as String,
      tokenCount: json['token_count'] as int? ?? 0,
      pineconeVectorId: json['pinecone_vector_id'] as String?,
      embeddingModel: json['embedding_model'] as String? ?? 'all-MiniLM-L6-v2',
      embeddingVector: (json['embedding_vector'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }
}
