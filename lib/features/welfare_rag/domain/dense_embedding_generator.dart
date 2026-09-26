// lib/features/welfare_rag/domain/dense_embedding_generator.dart
// 384-dimensional dense vector embedding generator for local semantic retrieval and Pinecone vector DB integration.

import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';

class DenseEmbeddingGenerator {
  static const int dimension = 384;

  /// Generates a normalized 384-dimensional dense unit vector (||v||_2 = 1.0) from text.
  /// Matches the multi-hash semantic projection used by the Pinecone indexer.
  static List<double> generate384Vector(String text) {
    final List<double> vec = List<double>.filled(dimension, 0.0);
    final cleaned = text.toLowerCase()
        .replaceAll('.', ' ')
        .replaceAll(',', ' ')
        .replaceAll('?', ' ')
        .replaceAll(':', ' ')
        .replaceAll(';', ' ')
        .replaceAll('(', ' ')
        .replaceAll(')', ' ')
        .replaceAll('-', ' ');

    final tokens = cleaned.split(RegExp(r'\s+')).where((t) => t.length > 2).toList();
    if (tokens.isEmpty) return vec;

    const boostTokens = {
      'pmss': 3.0, 'scholarship': 3.0, 'girls': 3.0, 'boys': 3.0, '3000': 3.0, '2500': 3.0,
      '36000': 3.0, '30000': 3.0, 'veer': 3.0, 'bharat': 3.0, 'martyr': 3.0, '15': 3.0,
      'lakhs': 3.0, '1500000': 3.0, 'exgratia': 3.0, 'ayushman': 3.0, 'capf': 3.0,
      'cashless': 3.0, 'cghs': 3.0, 'hospital': 2.5, 'opd': 2.5, 'ipd': 2.5, 'warb': 2.5,
      'pension': 2.5, 'widow': 2.5, 'ward': 2.5, 'eawas': 2.5, 'punarvaas': 2.5,
      'amount': 2.5, 'limit': 2.5, 'maximum': 2.5
    };

    // Bilingual concept mapping
    final bilingualReplacements = {
      'आयुष्मान': 'ayushman',
      'कैशलेस': 'cashless',
      'इलाज': 'treatment medical',
      'अस्पताल': 'hospital',
      'छात्रवृत्ति': 'scholarship pmss',
      'भारत के वीर': 'bharat veer',
      'शहीद': 'martyr',
      'मुआवजा': 'exgratia'
    };

    String expandedText = cleaned;
    for (final entry in bilingualReplacements.entries) {
      if (expandedText.contains(entry.key)) {
        tokens.addAll(entry.value.split(' '));
      }
    }

    for (final token in tokens) {
      final double weight = boostTokens[token] ?? 1.0;
      final bytes = utf8.encode(token);
      final digest = sha256.convert(bytes);
      final hashBytes = digest.bytes;

      for (int i = 0; i < 16; i++) {
        final b1 = hashBytes[i];
        final b2 = hashBytes[(i + 8) % hashBytes.length];
        final val = (b1 << 8) | b2;
        final idx = val % dimension;
        final sign = ((hashBytes[(i + 4) % hashBytes.length]) & 1) == 1 ? 1.0 : -1.0;
        vec[idx] += sign * weight;
      }
    }

    // L2 Normalization to unit hypersphere
    double sumSquares = 0.0;
    for (int i = 0; i < dimension; i++) {
      sumSquares += vec[i] * vec[i];
    }

    final double norm = math.sqrt(sumSquares);
    if (norm > 0) {
      for (int i = 0; i < dimension; i++) {
        vec[i] = double.parse((vec[i] / norm).toStringAsFixed(6));
      }
    }

    return vec;
  }

  /// Calculates cosine similarity between two dense vectors
  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length || a.isEmpty) return 0.0;
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    final denom = math.sqrt(normA) * math.sqrt(normB);
    if (denom == 0) return 0.0;
    final sim = dotProduct / denom;
    return sim.clamp(0.0, 1.0);
  }
}
