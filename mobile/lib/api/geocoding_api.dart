import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mobile/config/api_config.dart';

class GeocodingApi {
  /// Forward geocoding: địa chỉ -> toạ độ (Goong)
  static Future<LatLng?> geocodeAddress(String address) async {
    try {
      final params = {
        'address': address,
        'api_key': ApiConfig.goongMapsApiKey,
      };

      final uri = Uri.https('rsapi.goong.io', '/geocode', params);
      debugPrint('Goong Geocode request: $uri');

      final res = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
          'User-Agent': 'Flutter App',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('Goong Geocode status: ${res.statusCode}');
      debugPrint('Goong Geocode body: ${res.body}');

      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      if (data is Map &&
          (data['status'] == 'OK') &&
          (data['results'] is List) &&
          (data['results'] as List).isNotEmpty) {
        final loc = data['results'][0]['geometry']?['location'];
        if (loc is Map && loc['lat'] != null && loc['lng'] != null) {
          return LatLng(
            (loc['lat'] as num).toDouble(),
            (loc['lng'] as num).toDouble(),
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('Goong geocode error: $e');
      return null;
    }
  }

  /// Reverse geocoding: toạ độ -> địa chỉ (Goong)
  static Future<String?> reverseGeocode(LatLng location) async {
    try {
      final params = {
        'latlng': '${location.latitude},${location.longitude}',
        'api_key': ApiConfig.goongMapsApiKey,
      };

      final uri = Uri.https('rsapi.goong.io', '/Geocode', params);
      debugPrint('Goong Reverse request: $uri');

      final res = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
          'User-Agent': 'Flutter App',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('Goong Reverse status: ${res.statusCode}');
      debugPrint('Goong Reverse body: ${res.body}');

      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      if (data is Map &&
          (data['status'] == 'OK') &&
          (data['results'] is List) &&
          (data['results'] as List).isNotEmpty) {
        return data['results'][0]['formatted_address'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Goong reverse geocode error: $e');
      return null;
    }
  }
}
