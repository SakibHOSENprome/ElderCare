class CaregiverAssignment {
  final String id;
  final String elderId;
  final String caregiverId;
  final DateTime createdAt;

  CaregiverAssignment({
    required this.id,
    required this.elderId,
    required this.caregiverId,
    required this.createdAt,
  });

  factory CaregiverAssignment.fromMap(Map<String, dynamic> map) {
    return CaregiverAssignment(
      id: map['id'] as String,
      elderId: map['elder_id'] as String,
      caregiverId: map['caregiver_id'] as String,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
