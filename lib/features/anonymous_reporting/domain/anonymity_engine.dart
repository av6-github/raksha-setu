// lib/features/anonymous_reporting/domain/anonymity_engine.dart
// Cryptographic token generator and technical identity protection engine for whistleblower reports

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class IdentityLeakException implements Exception {
  final String message;
  const IdentityLeakException(this.message);

  @override
  String toString() => 'IdentityLeakException: $message';
}

class AnonymityEngine {
  static final Random _secureRandom = Random.secure();
  static const String _tokenAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Base32-like (omitted 0, O, 1, I)

  /// Generates a cryptographically strong, human-readable whistleblower tracking token.
  /// Format: TK-XXXX-XXXX-XXXX
  static String generateTrackingToken() {
    String generateSegment(int length) {
      final buffer = StringBuffer();
      for (int i = 0; i < length; i++) {
        final index = _secureRandom.nextInt(_tokenAlphabet.length);
        buffer.write(_tokenAlphabet[index]);
      }
      return buffer.toString();
    }

    return 'TK-${generateSegment(4)}-${generateSegment(4)}-${generateSegment(4)}';
  }

  /// Hashes a tracking token using SHA-256 for one-way storage in database.
  /// The whistleblower retains the plaintext token; the database stores ONLY the hash.
  static String hashTrackingToken(String token) {
    final normalized = token.toUpperCase().replaceAll('-', '').replaceAll(' ', '').trim();
    final bytes = utf8.encode(normalized);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Forbidden metadata keys that must NEVER be attached to an anonymous report (normalized form)
  static const Set<String> _forbiddenIdentityKeys = {
    'officerid',
    'identityid',
    'userid',
    'fullname',
    'name',
    'email',
    'phone',
    'mobile',
    'servicenumber',
    'ipaddress',
    'deviceid',
    'macaddress',
    'sessionid',
    'accesstoken',
    'fcmtoken',
  };

  /// Asserts that a submission payload does NOT leak any author identification or device tracking data
  static void assertZeroIdentityLeak(Map<String, dynamic> payload) {
    for (final key in payload.keys) {
      final normalizedKey = key.toLowerCase().replaceAll('_', '').replaceAll('-', '').trim();
      if (_forbiddenIdentityKeys.contains(normalizedKey)) {
        throw IdentityLeakException(
          'Identity Leak Blocked: Field "$key" cannot be attached to an anonymous report.',
        );
      }
    }
  }

  /// Validates that unit identifier does not reveal fine-grained individual locations (platoon, sentry post, bunk)
  static String? sanitizeUnitIdentifier(String? rawUnit) {
    if (rawUnit == null || rawUnit.trim().isEmpty) return null;

    final lower = rawUnit.toLowerCase();
    final granularKeywords = [
      'platoon',
      'section',
      'sentry',
      'bunker',
      'barrack room',
      'guard post',
      'tent',
      'picket',
    ];

    for (final kw in granularKeywords) {
      if (lower.contains(kw)) {
        throw IdentityLeakException(
          'Granular location detected ("$kw"). Please specify only general battalion or administrative sector to protect anonymity.',
        );
      }
    }

    return rawUnit.trim();
  }
}
