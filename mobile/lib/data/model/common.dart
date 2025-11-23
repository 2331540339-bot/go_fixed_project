// common.dart
class GeoPoint {
  final double lat;
  final double lng;
  const GeoPoint(this.lat, this.lng);

  /// Hỗ trợ vài format phổ biến:
  /// - {"lat":10.7,"lng":106.6}
  /// - {"latitude":10.7,"longitude":106.6}
  /// - {"x":106.6,"y":10.7} // (x=lng, y=lat)
  /// - "POINT(106.6 10.7)"
  factory GeoPoint.fromJson(dynamic json) {
    if (json == null) return const GeoPoint(0, 0);
    if (json is String && json.startsWith('POINT(')) {
      final t = json.replaceAll(RegExp(r'[A-Z()]'), '').trim().split(RegExp(r'\s+'));
      final lng = double.tryParse(t[0]) ?? 0;
      final lat = double.tryParse(t[1]) ?? 0;
      return GeoPoint(lat, lng);
    }
    if (json is Map) {
      final lat = (json['lat'] ?? json['latitude'] ?? json['1']);
      final lng = (json['lng'] ?? json['longitude'] ?? json['0']);
      return GeoPoint(
        numToDouble(lat),
        numToDouble(lng),
      );
    }
    return const GeoPoint(0, 0);
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

DateTime? readDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
  return null;
}

double numToDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}

Map<String, dynamic> clean(Map<String, dynamic> m) {
  m.removeWhere((k, v) => v == null);
  return m;
}
