// lib/features/hrms/domain/deployment_record.dart
// Domain model for postings and operational deployment exposure

class DeploymentRecord {
  final String id;
  final String officerId;
  final String location;
  final String? operationName;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isHighHazard;
  final int hardshipScore; // 0 to 10
  final bool isActive;

  const DeploymentRecord({
    required this.id,
    required this.officerId,
    required this.location,
    this.operationName,
    required this.startDate,
    this.endDate,
    this.isHighHazard = false,
    this.hardshipScore = 0,
    this.isActive = true,
  });

  int get durationMonths {
    final end = endDate ?? DateTime.now();
    return ((end.difference(startDate).inDays) / 30.4).round();
  }

  factory DeploymentRecord.fromMap(Map<String, dynamic> map) {
    return DeploymentRecord(
      id: map['id'] as String,
      officerId: map['officer_id'] as String,
      location: map['location'] as String? ?? 'Field Operational Area',
      operationName: map['operation_name'] as String?,
      startDate: DateTime.tryParse(map['start_date'] as String? ?? '') ?? DateTime.now(),
      endDate: map['end_date'] != null ? DateTime.tryParse(map['end_date'] as String) : null,
      isHighHazard: map['is_high_hazard'] as bool? ?? false,
      hardshipScore: (map['hardship_score'] as num?)?.toInt() ?? 0,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'officer_id': officerId,
      'location': location,
      'operation_name': operationName,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate?.toIso8601String().split('T').first,
      'is_high_hazard': isHighHazard,
      'hardship_score': hardshipScore,
      'is_active': isActive,
    };
  }
}
