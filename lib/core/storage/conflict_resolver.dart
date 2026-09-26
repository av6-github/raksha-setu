// lib/core/storage/conflict_resolver.dart
// Conflict detection and resolution strategies for offline-first sync operations

enum ConflictResolutionStrategy {
  clientWins,
  serverWins,
  latestTimestampWins;

  String get displayName {
    switch (this) {
      case ConflictResolutionStrategy.clientWins:
        return 'Client Wins (Officer Personal Input)';
      case ConflictResolutionStrategy.serverWins:
        return 'Server Wins (Operational Roster Authority)';
      case ConflictResolutionStrategy.latestTimestampWins:
        return 'Latest Timestamp Wins';
    }
  }
}

class ConflictResolver {
  /// Resolves conflict between client offline mutation and current server state
  static Map<String, dynamic> resolveConflict({
    required Map<String, dynamic> clientRecord,
    required Map<String, dynamic> serverRecord,
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.clientWins,
  }) {
    switch (strategy) {
      case ConflictResolutionStrategy.clientWins:
        return Map<String, dynamic>.from(clientRecord);

      case ConflictResolutionStrategy.serverWins:
        return Map<String, dynamic>.from(serverRecord);

      case ConflictResolutionStrategy.latestTimestampWins:
        final clientTimeStr = clientRecord['updated_at'] ?? clientRecord['created_at'];
        final serverTimeStr = serverRecord['updated_at'] ?? serverRecord['created_at'];

        if (clientTimeStr != null && serverTimeStr != null) {
          final clientTime = DateTime.tryParse(clientTimeStr.toString());
          final serverTime = DateTime.tryParse(serverTimeStr.toString());

          if (clientTime != null && serverTime != null) {
            if (serverTime.isAfter(clientTime)) {
              return Map<String, dynamic>.from(serverRecord);
            } else {
              return Map<String, dynamic>.from(clientRecord);
            }
          }
        }
        // Fallback to clientWins if timestamps cannot be reliably parsed
        return Map<String, dynamic>.from(clientRecord);
    }
  }

  /// Automatically selects the appropriate strategy based on the table/endpoint type
  static ConflictResolutionStrategy defaultStrategyForEndpoint(String endpoint) {
    final lower = endpoint.toLowerCase();
    if (lower.contains('roster') || lower.contains('deployment') || lower.contains('unit')) {
      return ConflictResolutionStrategy.serverWins;
    }
    // All personal check-ins, assessments, and preferences are client-authoritative
    return ConflictResolutionStrategy.clientWins;
  }
}
