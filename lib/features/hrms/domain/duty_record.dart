// lib/features/hrms/domain/duty_record.dart
// Domain model for duty rosters and shift fatigue signals

class DutyRecord {
  final String id;
  final String officerId;
  final DateTime date;
  final String shiftName;
  final bool isNightShift;
  final int consecutiveDaysOnDuty;
  final double overtimeHours;

  const DutyRecord({
    required this.id,
    required this.officerId,
    required this.date,
    required this.shiftName,
    this.isNightShift = false,
    this.consecutiveDaysOnDuty = 1,
    this.overtimeHours = 0.0,
  });

  bool get isElevatedFatigue => consecutiveDaysOnDuty >= 12 || (isNightShift && consecutiveDaysOnDuty >= 5);

  factory DutyRecord.fromMap(Map<String, dynamic> map) {
    return DutyRecord(
      id: map['id'] as String,
      officerId: map['officer_id'] as String,
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      shiftName: map['shifts'] != null ? map['shifts']['name'] as String? ?? 'General Shift' : 'General Shift',
      isNightShift: map['shifts'] != null ? (map['shifts']['is_night_shift'] as bool? ?? false) : false,
      consecutiveDaysOnDuty: (map['consecutive_days_on_duty'] as num?)?.toInt() ?? 1,
      overtimeHours: (map['overtime_hours'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'officer_id': officerId,
      'date': date.toIso8601String().split('T').first,
      'consecutive_days_on_duty': consecutiveDaysOnDuty,
      'overtime_hours': overtimeHours,
    };
  }
}
