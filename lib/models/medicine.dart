enum MedicineStatus { taken, pending, upcoming }

class Medicine {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final String frequency; // Daily, Everyday, Weekly...
  final String time; // stored as HH:mm
  final bool reminder;
  final MedicineStatus status;
  final DateTime createdAt;

  Medicine({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.time,
    required this.reminder,
    required this.status,
    required this.createdAt,
  });

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? 'Daily',
      time: map['time'] ?? '08:00',
      reminder: map['reminder'] ?? true,
      status: _statusFromString(map['status']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  static MedicineStatus _statusFromString(String? value) {
    switch (value) {
      case 'taken':
        return MedicineStatus.taken;
      case 'upcoming':
        return MedicineStatus.upcoming;
      default:
        return MedicineStatus.pending;
    }
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'time': time,
      'reminder': reminder,
      'status': status.name,
    };
  }
}
