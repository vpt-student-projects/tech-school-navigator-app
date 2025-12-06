// lib/models/user_profile.dart
class UserProfile {
  final String id;          // uuid из таблицы profiles
  final String email;
  final String? groups;
  final int? course;
  final DateTime? createdAt;
  final String role;        // 'admin' | 'user' и т.п.
  final String? fullName;

  const UserProfile({
    required this.id,
    required this.email,
    this.groups,
    this.course,
    this.createdAt,
    required this.role,
    this.fullName,
  });

  bool get isAdmin => role == 'admin';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      groups: json['groups'] as String?,
      course: json['course'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      role: (json['role'] as String?) ?? 'user',
      fullName: json['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'groups': groups,
      'course': course,
      'created_at': createdAt?.toIso8601String(),
      'role': role,
      'full_name': fullName,
    };
  }
}
