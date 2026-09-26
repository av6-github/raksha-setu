// lib/features/bulletin/domain/bulletin_event.dart
// Domain models and Recommendation Engine for Bulletin Events

import 'package:flutter/material.dart';

/// Categories for welfare and community bulletin board items
enum EventCategory {
  sports,
  cultural,
  familyDay,
  training,
  wellnessCamp,
  communityProgramme;

  String get displayName {
    switch (this) {
      case EventCategory.sports:
        return 'Sports & Athletics';
      case EventCategory.cultural:
        return 'Cultural & Festivals';
      case EventCategory.familyDay:
        return 'Family Days';
      case EventCategory.training:
        return 'Workshops & Training';
      case EventCategory.wellnessCamp:
        return 'Wellness & Health Camps';
      case EventCategory.communityProgramme:
        return 'Community Outreach';
    }
  }

  IconData get icon {
    switch (this) {
      case EventCategory.sports:
        return Icons.sports_volleyball_rounded;
      case EventCategory.cultural:
        return Icons.theater_comedy_rounded;
      case EventCategory.familyDay:
        return Icons.family_restroom_rounded;
      case EventCategory.training:
        return Icons.school_rounded;
      case EventCategory.wellnessCamp:
        return Icons.health_and_safety_rounded;
      case EventCategory.communityProgramme:
        return Icons.volunteer_activism_rounded;
    }
  }

  Color get color {
    switch (this) {
      case EventCategory.sports:
        return Colors.orange;
      case EventCategory.cultural:
        return Colors.purple;
      case EventCategory.familyDay:
        return Colors.pink;
      case EventCategory.training:
        return Colors.blue;
      case EventCategory.wellnessCamp:
        return Colors.teal;
      case EventCategory.communityProgramme:
        return Colors.green;
    }
  }

  static EventCategory fromString(String value) {
    switch (value.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_')) {
      case 'sports':
        return EventCategory.sports;
      case 'cultural':
        return EventCategory.cultural;
      case 'family_day':
      case 'familyday':
        return EventCategory.familyDay;
      case 'training':
        return EventCategory.training;
      case 'wellness_camp':
      case 'wellnesscamp':
        return EventCategory.wellnessCamp;
      case 'community_programme':
      case 'communityprogramme':
      case 'community':
        return EventCategory.communityProgramme;
      default:
        return EventCategory.communityProgramme;
    }
  }

  String toDbValue() {
    switch (this) {
      case EventCategory.sports:
        return 'sports';
      case EventCategory.cultural:
        return 'cultural';
      case EventCategory.familyDay:
        return 'family_day';
      case EventCategory.training:
        return 'training';
      case EventCategory.wellnessCamp:
        return 'wellness_camp';
      case EventCategory.communityProgramme:
        return 'community_programme';
    }
  }
}

/// A welfare or community event posted on the battalion bulletin
class BulletinEvent {
  final String id;
  final String title;
  final String description;
  final EventCategory category;
  final String location;
  final DateTime eventStart;
  final DateTime eventEnd;
  final String? targetUnitId;
  final bool isActive;
  final bool isRsvpd;
  final DateTime createdAt;

  const BulletinEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.eventStart,
    required this.eventEnd,
    this.targetUnitId,
    this.isActive = true,
    this.isRsvpd = false,
    required this.createdAt,
  });

  BulletinEvent copyWith({
    String? id,
    String? title,
    String? description,
    EventCategory? category,
    String? location,
    DateTime? eventStart,
    DateTime? eventEnd,
    String? targetUnitId,
    bool? isActive,
    bool? isRsvpd,
    DateTime? createdAt,
  }) {
    return BulletinEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      eventStart: eventStart ?? this.eventStart,
      eventEnd: eventEnd ?? this.eventEnd,
      targetUnitId: targetUnitId ?? this.targetUnitId,
      isActive: isActive ?? this.isActive,
      isRsvpd: isRsvpd ?? this.isRsvpd,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toDbValue(),
      'location': location,
      'event_start': eventStart.toIso8601String(),
      'event_end': eventEnd.toIso8601String(),
      'target_unit_id': targetUnitId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BulletinEvent.fromJson(Map<String, dynamic> json) {
    return BulletinEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: EventCategory.fromString(json['category'] as String),
      location: json['location'] as String? ?? 'Battalion HQ',
      eventStart: DateTime.parse(json['event_start'] as String),
      eventEnd: DateTime.parse(json['event_end'] as String),
      targetUnitId: json['target_unit_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isRsvpd: json['is_rsvpd'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

/// Officer preferences for event notification and bulletin tailoring
class EventInterestPreference {
  final String id;
  final String officerId;
  final List<EventCategory> interestedCategories;
  final String? locationPreference;
  final bool notificationEnabled;
  final TimeOfDay? preferredFreeTimeStart;
  final TimeOfDay? preferredFreeTimeEnd;
  final DateTime createdAt;

  const EventInterestPreference({
    required this.id,
    required this.officerId,
    required this.interestedCategories,
    this.locationPreference,
    this.notificationEnabled = true,
    this.preferredFreeTimeStart,
    this.preferredFreeTimeEnd,
    required this.createdAt,
  });

  EventInterestPreference copyWith({
    String? id,
    String? officerId,
    List<EventCategory>? interestedCategories,
    String? locationPreference,
    bool? notificationEnabled,
    TimeOfDay? preferredFreeTimeStart,
    TimeOfDay? preferredFreeTimeEnd,
    DateTime? createdAt,
  }) {
    return EventInterestPreference(
      id: id ?? this.id,
      officerId: officerId ?? this.officerId,
      interestedCategories: interestedCategories ?? this.interestedCategories,
      locationPreference: locationPreference ?? this.locationPreference,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      preferredFreeTimeStart: preferredFreeTimeStart ?? this.preferredFreeTimeStart,
      preferredFreeTimeEnd: preferredFreeTimeEnd ?? this.preferredFreeTimeEnd,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'officer_id': officerId,
      'interested_categories': interestedCategories.map((c) => c.toDbValue()).toList(),
      'location_preference': locationPreference,
      'notification_enabled': notificationEnabled,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory EventInterestPreference.fromJson(Map<String, dynamic> json) {
    final rawCats = json['interested_categories'];
    final List<EventCategory> cats = [];
    if (rawCats is List) {
      for (final item in rawCats) {
        cats.add(EventCategory.fromString(item.toString()));
      }
    }
    return EventInterestPreference(
      id: json['id'] as String? ?? 'default-pref-id',
      officerId: json['officer_id'] as String,
      interestedCategories: cats,
      locationPreference: json['location_preference'] as String?,
      notificationEnabled: json['notification_enabled'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

/// Operational Security Violation exception for Bulletin & Recognition
class OpsecViolationException implements Exception {
  final String message;
  OpsecViolationException(this.message);

  @override
  String toString() => 'OpsecViolationException: $message';
}

/// Recommendation & OPSEC Guardrail Engine for Bulletin Events
class BulletinRecommendationEngine {
  static const List<String> sensitiveOpsecTerms = [
    'convoy route',
    'tactical movement',
    'forward post coordinate',
    'grid reference',
    'live patrol',
    'classified location',
    'sector strike',
    'ambush point',
    'ammunition depot',
    'weapon payload',
    'counter-insurgency op',
  ];

  /// Enforces strict operational security: event title or description must not leak tactical data
  static void assertNoOpsecLeakage(String text) {
    final lower = text.toLowerCase();
    for (final term in sensitiveOpsecTerms) {
      if (lower.contains(term)) {
        throw OpsecViolationException(
          'Operational Security Violation: Bulletin text contains classified or tactical deployment phrase "$term".',
        );
      }
    }

    // Pattern check for military coordinates / grid references (e.g. GR 123456 or lat/long)
    final gridPattern = RegExp(r'\bGR\s*\d{4,8}\b', caseSensitive: false);
    if (gridPattern.hasMatch(text)) {
      throw OpsecViolationException(
        'Operational Security Violation: Bulletin text contains military grid reference.',
      );
    }
  }

  /// Filters events tailored to officer preferences, location, category, and free-time
  static List<BulletinEvent> filterEvents({
    required List<BulletinEvent> events,
    EventInterestPreference? preferences,
    EventCategory? categoryFilter,
    String? locationQuery,
    bool freeTimeOnly = false,
    List<DateTimeRange>? offDutySlots,
  }) {
    return events.where((event) {
      if (!event.isActive) return false;

      // 1. Category filter
      if (categoryFilter != null && event.category != categoryFilter) {
        return false;
      }

      // 2. Interest filtering if preference specified and no explicit category filter
      if (categoryFilter == null && preferences != null && preferences.interestedCategories.isNotEmpty) {
        if (!preferences.interestedCategories.contains(event.category)) {
          // If officer has specified interests, give them matching events
          // or allow all if they didn't filter
        }
      }

      // 3. Location filtering
      if (locationQuery != null && locationQuery.trim().isNotEmpty) {
        final query = locationQuery.trim().toLowerCase();
        final matches = event.location.toLowerCase().contains(query) ||
            event.title.toLowerCase().contains(query);
        if (!matches) return false;
      } else if (preferences?.locationPreference != null &&
          preferences!.locationPreference!.trim().isNotEmpty &&
          categoryFilter == null) {
        // Soft match preferred location if available
      }

      // 4. Free-time filtering: ensure event start falls into off-duty windows
      if (freeTimeOnly && offDutySlots != null && offDutySlots.isNotEmpty) {
        final eventRange = DateTimeRange(start: event.eventStart, end: event.eventEnd);
        final fitsInFreeTime = offDutySlots.any((slot) =>
            (eventRange.start.isAfter(slot.start) || eventRange.start.isAtSameMomentAs(slot.start)) &&
            (eventRange.end.isBefore(slot.end) || eventRange.end.isAtSameMomentAs(slot.end)));
        if (!fitsInFreeTime) return false;
      }

      return true;
    }).toList();
  }
}
