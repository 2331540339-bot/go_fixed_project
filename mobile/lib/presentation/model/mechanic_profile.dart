// mechanic_profile.dart
import 'common.dart';

class MechanicProfile {
  final String userId;
  final bool isOnline;
  final double? rating;      // DECIMAL(2,1)
  final GeoPoint? currentLocation;
  final DateTime? updatedAt;

  const MechanicProfile({
    required this.userId,
    required this.isOnline,
    this.rating,
    this.currentLocation,
    this.updatedAt,
  });

  factory MechanicProfile.fromJson(Map<String, dynamic> j) => MechanicProfile(
    userId: (j['user_id'] ?? '').toString(),
    isOnline: (j['is_online'] == 1) || (j['is_online'] == true),
    rating: j['rating'] == null ? null : numToDouble(j['rating']),
    currentLocation: j['current_location'] == null ? null : GeoPoint.fromJson(j['current_location']),
    updatedAt: readDate(j['updated_at']),
  );

  Map<String, dynamic> toJson() => clean({
    'user_id': userId,
    'is_online': isOnline ? 1 : 0,
    'rating': rating,
    'current_location': currentLocation?.toJson(),
    'updated_at': updatedAt?.toIso8601String(),
  });
}
