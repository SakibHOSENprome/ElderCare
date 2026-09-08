class EmergencyContact {
  final String id;
  final String userId;
  final String name;
  final String relation; // Mother, Brother, Dr. ..., Neighbor
  final String phone;
  final String? email;
  final String? address;

  EmergencyContact({
    required this.id,
    required this.userId,
    required this.name,
    required this.relation,
    required this.phone,
    this.email,
    this.address,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] ?? '',
      relation: map['relation'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      address: map['address'],
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'name': name,
      'relation': relation,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }
}
