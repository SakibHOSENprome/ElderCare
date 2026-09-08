class HealthRecord {
  final String id;
  final String userId;
  final DateTime recordedAt;
  final int? bpSystolic;
  final int? bpDiastolic;
  final int? sugar; // mg/dL
  final double? weight; // kg
  final int? pulse; // bpm

  HealthRecord({
    required this.id,
    required this.userId,
    required this.recordedAt,
    this.bpSystolic,
    this.bpDiastolic,
    this.sugar,
    this.weight,
    this.pulse,
  });

  String get bpDisplay =>
      (bpSystolic != null && bpDiastolic != null) ? '$bpSystolic/$bpDiastolic' : '--';

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      recordedAt: DateTime.parse(map['recorded_at']),
      bpSystolic: map['bp_systolic'],
      bpDiastolic: map['bp_diastolic'],
      sugar: map['sugar'],
      weight: (map['weight'] as num?)?.toDouble(),
      pulse: map['pulse'],
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'recorded_at': recordedAt.toIso8601String(),
      'bp_systolic': bpSystolic,
      'bp_diastolic': bpDiastolic,
      'sugar': sugar,
      'weight': weight,
      'pulse': pulse,
    };
  }
}
