import 'dart:convert';

import 'app_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.licenseNumber,
    this.photoUrl,
    this.createdAt,
    this.isBlocked = false,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final AppRole role;
  final String? licenseNumber;
  final String? photoUrl;
  final DateTime? createdAt;
  final bool isBlocked;

  bool get isAdmin => role == AppRole.admin;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'licenseNumber': licenseNumber,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
      'isBlocked': isBlocked,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: (json['role'] as String) == AppRole.admin.name
          ? AppRole.admin
          : AppRole.user,
      licenseNumber: json['licenseNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      isBlocked: json['isBlocked'] as bool? ?? false,
    );
  }

  static AppUser fromJsonString(String value) {
    return fromJson(Map<String, dynamic>.from(jsonDecode(value) as Map));
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    AppRole? role,
    String? licenseNumber,
    String? photoUrl,
    DateTime? createdAt,
    bool? isBlocked,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
