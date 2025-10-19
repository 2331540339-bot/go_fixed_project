import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mobile/config/api_config.dart';

class GeocodingApi {
  // Chuyển đổi địa chỉ thành tọa độ sử dụng Google Geocoding API
  static Future<LatLng?> geocodeAddress(String address) async {
    try {
      final params = {
        'address': address,
        'key': ApiConfig.googleMapsApiKey,
        'region': 'VN', // Ưu tiên kết quả Việt Nam
      };
      
      final uri = Uri.https('maps.googleapis.com', '/maps/api/geocoding/json', params);
      
      debugPrint('Geocoding request: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Flutter App',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('Geocoding response status: ${response.statusCode}');
      debugPrint('Geocoding response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        if (json['status'] == 'OK' && json['results'].isNotEmpty) {
          final location = json['results'][0]['geometry']['location'];
          final latLng = LatLng(
            location['lat'].toDouble(),
            location['lng'].toDouble(),
          );
          debugPrint('Geocoding result: $latLng');
          return latLng;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Geocoding error: $e');
      return null;
    }
  }

  // Chuyển đổi tọa độ thành địa chỉ sử dụng Google Reverse Geocoding API
  static Future<String?> reverseGeocode(LatLng location) async {
    try {
      final params = {
        'latlng': '${location.latitude},${location.longitude}',
        'key': ApiConfig.googleMapsApiKey,
        'language': 'vi', // Ngôn ngữ tiếng Việt
      };
      
      final uri = Uri.https('maps.googleapis.com', '/maps/api/geocoding/json', params);
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Flutter App',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        if (json['status'] == 'OK' && json['results'].isNotEmpty) {
          return json['results'][0]['formatted_address'];
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
      return null;
    }
  }
}