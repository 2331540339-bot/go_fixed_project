// user.dart
import 'enums.dart';
import 'common.dart';

class User {
  final String? id;
  final String fullname;
  final String email;
  final String phone;
  final GeoPoint? currentLocation;
  final String? avatarUrl;
  final UserRole? role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    this.id,
    required this.fullname,
    required this.email,
    required this.phone,
    this.currentLocation,
    this.avatarUrl,
     this.role,
    required this.isActive,
    this.createdAt,
    this.updatedAt, String? address,
  });

  factory User.fromJson(Map<String, dynamic> j) {
    return User(
      id: (j['id'] ?? j['_id'] ?? '').toString(),
      fullname: (j['fullname'] ?? '').toString(),
      email: (j['email'] ?? '').toString(),
      phone: (j['phone'] ?? '').toString(),
      currentLocation: j['current_location'] == null ? null : GeoPoint.fromJson(j['current_location']),
      avatarUrl: j['avatar_url'] as String?,
      role: UserRoleX.from(j['role']?.toString()),
      isActive: (j['is_active'] == 1) || (j['is_active'] == true),
      createdAt: readDate(j['created_at']),
      updatedAt: readDate(j['updated_at']),
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) => clean({
    if (includeId) 'id': id,
    'fullname': fullname,
    'email': email,
    'phone': phone,
    'current_location': currentLocation?.toJson(),
    'avatar_url': avatarUrl,
    'role': role?.json,
    'is_active': isActive ? 1 : 0,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  });

  User copyWith({
    String? id,
    String? fullname,
    String? email,
    String? phone,
    GeoPoint? currentLocation,
    String? avatarUrl,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    fullname: fullname ?? this.fullname,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    currentLocation: currentLocation ?? this.currentLocation,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
