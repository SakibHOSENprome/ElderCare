class Appointment {
  final String id;
  final String userId;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String location;
  final bool isUpcoming;
  final String? prescriptionLink;

  Appointment({
    required this.id,
    required this.userId,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.location,
    required this.isUpcoming,
    this.prescriptionLink,
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      doctorName: map['doctor_name'] ?? '',
      specialty: map['specialty'] ?? '',
      dateTime: DateTime.parse(map['date_time']),
      location: map['location'] ?? '',
      isUpcoming: map['is_upcoming'] ?? true,
      prescriptionLink: map['prescription_link'],
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'doctor_name': doctorName,
      'specialty': specialty,
      'date_time': dateTime.toIso8601String(),
      'location': location,
      'is_upcoming': isUpcoming,
      'prescription_link': prescriptionLink,
    };
  }
}
