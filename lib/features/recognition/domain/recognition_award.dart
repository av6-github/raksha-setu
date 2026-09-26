// lib/features/recognition/domain/recognition_award.dart
// Domain models and Safety/OPSEC/Consent Engine for Recognitions & Testimonials

import 'package:flutter/material.dart';

/// Categories for recognitions and commendations
enum RecognitionCategory {
  milestone,
  leadershipCommendation,
  appreciationNote,
  peerAppreciation;

  String get displayName {
    switch (this) {
      case RecognitionCategory.milestone:
        return 'Service Milestone';
      case RecognitionCategory.leadershipCommendation:
        return 'Leadership Commendation';
      case RecognitionCategory.appreciationNote:
        return 'Welfare Appreciation';
      case RecognitionCategory.peerAppreciation:
        return 'Buddy / Peer Appreciation';
    }
  }

  IconData get icon {
    switch (this) {
      case RecognitionCategory.milestone:
        return Icons.military_tech_rounded;
      case RecognitionCategory.leadershipCommendation:
        return Icons.workspace_premium_rounded;
      case RecognitionCategory.appreciationNote:
        return Icons.favorite_rounded;
      case RecognitionCategory.peerAppreciation:
        return Icons.handshake_rounded;
    }
  }

  Color get color {
    switch (this) {
      case RecognitionCategory.milestone:
        return Colors.amber.shade700;
      case RecognitionCategory.leadershipCommendation:
        return Colors.indigo;
      case RecognitionCategory.appreciationNote:
        return Colors.teal;
      case RecognitionCategory.peerAppreciation:
        return Colors.deepPurple;
    }
  }

  static RecognitionCategory fromString(String value) {
    switch (value.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_')) {
      case 'milestone':
        return RecognitionCategory.milestone;
      case 'leadership_commendation':
      case 'leadership':
        return RecognitionCategory.leadershipCommendation;
      case 'appreciation_note':
      case 'appreciation':
        return RecognitionCategory.appreciationNote;
      case 'peer_appreciation':
      case 'peer':
      case 'buddy':
        return RecognitionCategory.peerAppreciation;
      default:
        return RecognitionCategory.peerAppreciation;
    }
  }

  String toDbValue() {
    switch (this) {
      case RecognitionCategory.milestone:
        return 'milestone';
      case RecognitionCategory.leadershipCommendation:
        return 'leadership_commendation';
      case RecognitionCategory.appreciationNote:
        return 'appreciation_note';
      case RecognitionCategory.peerAppreciation:
        return 'peer_appreciation';
    }
  }
}

/// A formal commendation, milestone, or peer appreciation record
class RecognitionAward {
  final String id;
  final String officerId;
  final String recipientName;
  final String? awardedByIdentityId;
  final String awardedByName;
  final String title;
  final String citation;
  final RecognitionCategory category;
  final bool isInstitutionLevel;
  final bool officerConsentForPublic;
  final bool opsecCleared;
  final DateTime awardedAt;

  const RecognitionAward({
    required this.id,
    required this.officerId,
    required this.recipientName,
    this.awardedByIdentityId,
    required this.awardedByName,
    required this.title,
    required this.citation,
    required this.category,
    this.isInstitutionLevel = false,
    this.officerConsentForPublic = false,
    this.opsecCleared = true,
    required this.awardedAt,
  });

  RecognitionAward copyWith({
    String? id,
    String? officerId,
    String? recipientName,
    String? awardedByIdentityId,
    String? awardedByName,
    String? title,
    String? citation,
    RecognitionCategory? category,
    bool? isInstitutionLevel,
    bool? officerConsentForPublic,
    bool? opsecCleared,
    DateTime? awardedAt,
  }) {
    return RecognitionAward(
      id: id ?? this.id,
      officerId: officerId ?? this.officerId,
      recipientName: recipientName ?? this.recipientName,
      awardedByIdentityId: awardedByIdentityId ?? this.awardedByIdentityId,
      awardedByName: awardedByName ?? this.awardedByName,
      title: title ?? this.title,
      citation: citation ?? this.citation,
      category: category ?? this.category,
      isInstitutionLevel: isInstitutionLevel ?? this.isInstitutionLevel,
      officerConsentForPublic: officerConsentForPublic ?? this.officerConsentForPublic,
      opsecCleared: opsecCleared ?? this.opsecCleared,
      awardedAt: awardedAt ?? this.awardedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'officer_id': officerId,
      'recipient_name': recipientName,
      'awarded_by_identity_id': awardedByIdentityId,
      'awarded_by_name': awardedByName,
      'title': title,
      'citation': citation,
      'award_category': category.toDbValue(),
      'is_institution_level': isInstitutionLevel,
      'officer_consent_for_public': officerConsentForPublic,
      'opsec_cleared': opsecCleared,
      'awarded_at': awardedAt.toIso8601String(),
    };
  }

  factory RecognitionAward.fromJson(Map<String, dynamic> json) {
    return RecognitionAward(
      id: json['id'] as String,
      officerId: json['officer_id'] as String,
      recipientName: json['recipient_name'] as String? ?? 'Officer',
      awardedByIdentityId: json['awarded_by_identity_id'] as String?,
      awardedByName: json['awarded_by_name'] as String? ?? 'Battalion Commander',
      title: json['title'] as String,
      citation: json['citation'] as String,
      category: RecognitionCategory.fromString(
        (json['award_category'] ?? json['category']) as String,
      ),
      isInstitutionLevel: json['is_institution_level'] as bool? ?? false,
      officerConsentForPublic: json['officer_consent_for_public'] as bool? ?? false,
      opsecCleared: json['opsec_cleared'] as bool? ?? true,
      awardedAt: json['awarded_at'] != null
          ? DateTime.parse(json['awarded_at'] as String)
          : DateTime.now(),
    );
  }
}

/// A curated testimonial from veteran or active personnel to overcome stigma
class Testimonial {
  final String id;
  final String title;
  final String content;
  final String authorRoleDisplay;
  final bool isApproved;
  final String? approvedByIdentityId;
  final DateTime createdAt;

  const Testimonial({
    required this.id,
    required this.title,
    required this.content,
    required this.authorRoleDisplay,
    this.isApproved = true,
    this.approvedByIdentityId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author_role_display': authorRoleDisplay,
      'is_approved': isApproved,
      'approved_by_identity_id': approvedByIdentityId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorRoleDisplay: json['author_role_display'] as String? ?? 'Veteran / Personnel',
      isApproved: json['is_approved'] as bool? ?? false,
      approvedByIdentityId: json['approved_by_identity_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

/// Recognition safety or consent violation exception
class RecognitionSafetyException implements Exception {
  final String message;
  RecognitionSafetyException(this.message);

  @override
  String toString() => 'RecognitionSafetyException: $message';
}

/// Consent violation exception
class ConsentViolationException implements Exception {
  final String message;
  ConsentViolationException(this.message);

  @override
  String toString() => 'ConsentViolationException: $message';
}

/// Anti-toxic, OPSEC, and Consent Enforcement Engine for Recognition
class RecognitionSafetyEngine {
  static const List<String> toxicTerms = [
    'lazy',
    'loser',
    'incompetent',
    'slacker',
    'demoted',
    'disciplinary',
    'punishment',
    'failing',
    'worthless',
    'idiot',
    'court martial',
    'disgrace',
    'useless',
    'shameful',
  ];

  static const List<String> tacticalOpsecTerms = [
    'convoy route',
    'forward post coordinate',
    'grid reference',
    'live patrol',
    'classified location',
    'ammunition depot',
    'tactical movement',
  ];

  /// Enforces anti-toxic and anti-sarcastic peer appreciation
  static void validateRecognition({
    required String title,
    required String citation,
    required RecognitionCategory category,
  }) {
    if (title.trim().isEmpty) {
      throw RecognitionSafetyException('Recognition title cannot be empty.');
    }
    if (citation.trim().length < 10) {
      throw RecognitionSafetyException('Citation must be meaningful (at least 10 characters).');
    }

    final combined = '${title.toLowerCase()} ${citation.toLowerCase()}';
    for (final term in toxicTerms) {
      if (combined.contains(term)) {
        throw RecognitionSafetyException(
          'Toxic Content Blocked: Recognition cannot contain derogatory, punitive, or sarcastic wording ("$term"). Badges must remain morale-boosting and positive.',
        );
      }
    }
  }

  /// Scans for OPSEC leaks in citations
  static void assertOpsecCleared(String citation) {
    final lower = citation.toLowerCase();
    for (final term in tacticalOpsecTerms) {
      if (lower.contains(term)) {
        throw RecognitionSafetyException(
          'OPSEC Violation: Citation contains tactical or deployment phrase "$term".',
        );
      }
    }

    final gridPattern = RegExp(r'\bGR\s*\d{4,8}\b', caseSensitive: false);
    if (gridPattern.hasMatch(citation)) {
      throw RecognitionSafetyException(
        'OPSEC Violation: Citation contains military grid reference.',
      );
    }
  }

  /// Enforces explicit officer consent before any recognition can appear on public wall
  static void assertPublicConsentEnforced(RecognitionAward award) {
    if (!award.officerConsentForPublic) {
      throw ConsentViolationException(
        'Consent Violation: Officer has not given explicit consent to publish award "${award.title}" on the public Wall of Commendation.',
      );
    }
    if (!award.opsecCleared) {
      throw RecognitionSafetyException(
        'OPSEC Violation: Award has not been cleared for public display.',
      );
    }
  }
}
