enum UserRole { elder, caregiver }

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final UserRole role;
  final int? age;
  final String? gender;
  final String? bloodGroup;
  final String? medicalCondition;
  final String? avatarUrl;
  final String? linkedElderId; // legacy single-elder link when role == caregiver

  // Caregiver directory fields — self-declared by the caregiver, shown to
  // elders browsing the "Assign Caregiver" list.
  final String? experience;
  final String? caregiverRelation;
  final String? remuneration;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.age,
    this.gender,
    this.bloodGroup,
    this.medicalCondition,
    this.avatarUrl,
    this.linkedElderId,
    this.experience,
    this.caregiverRelation,
    this.remuneration,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      fullName: map['full_name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      role: (map['role'] == 'caregiver') ? UserRole.caregiver : UserRole.elder,
      age: map['age'],
      gender: map['gender'],
      bloodGroup: map['blood_group'],
      medicalCondition: map['medical_condition'],
      avatarUrl: map['avatar_url'],
      linkedElderId: map['linked_elder_id'],
      experience: map['experience'],
      caregiverRelation: map['caregiver_relation'],
      remuneration: map['remuneration'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role == UserRole.caregiver ? 'caregiver' : 'elder',
      'age': age,
      'gender': gender,
      'blood_group': bloodGroup,
      'medical_condition': medicalCondition,
      'avatar_url': avatarUrl,
      'linked_elder_id': linkedElderId,
      'experience': experience,
      'caregiver_relation': caregiverRelation,
      'remuneration': remuneration,
    };
  }

  AppUser copyWith({
    String? fullName,
    String? email,
    String? phone,
    UserRole? role,
    int? age,
    String? gender,
    String? bloodGroup,
    String? medicalCondition,
    String? avatarUrl,
    String? linkedElderId,
    String? experience,
    String? caregiverRelation,
    String? remuneration,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medicalCondition: medicalCondition ?? this.medicalCondition,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      linkedElderId: linkedElderId ?? this.linkedElderId,
      experience: experience ?? this.experience,
      caregiverRelation: caregiverRelation ?? this.caregiverRelation,
      remuneration: remuneration ?? this.remuneration,
    );
  }
}
