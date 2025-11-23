import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/data/model/service.dart';
import 'package:mobile/config/router/app_router.dart';

class ServiceApi {
  ServiceApi(this._client);

  final http.Client _client;
  static String get _base =>
      AppRouter.main_domain; // ví dụ: http://localhost:8000

  /// GET /services?limit=&offset=&q=
  Future<List<Service>> listServices({
    int limit = 50,
    int offset = 0,
    String? q,
  }) async {
    final uri = Uri.parse('$_base/service/get').replace(
      queryParameters: {
        'limit': '$limit',
        'offset': '$offset',
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );

    final res = await _client.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('Fetch services failed (${res.statusCode})');
    }

    final body = jsonDecode(res.body);
    // Tùy backend: hoặc trả về List, hoặc {items: [...]}
    final list = body is List ? body : (body['items'] ?? []);
    return List<Map<String, dynamic>>.from(list).map(Service.fromJson).toList();
  }

  Future<void> sendRescueRequest({
    required String serviceId,
    required String description,
    required Map<String, dynamic> location,
    required double priceEstimate,
    required String authToken,
  }) async {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    // Backend (Mongo $geoNear) cần GeoJSON: {type:"Point", coordinates:[lng, lat]}
    final lat = _toDouble(
      location['lat'] ?? location['latitude'] ?? location['y'],
    );
    final lng = _toDouble(
      location['lng'] ?? location['longitude'] ?? location['x'],
    );
    if (lat == null || lng == null) {
      throw Exception('Thiếu tọa độ, vui lòng chọn lại vị trí.');
    }
    final geoLocation = {
      'type': 'Point',
      'coordinates': [lng, lat],
    };

    final uri = Uri.parse('$_base/service/rescue/$serviceId');
    // final token = _getAuthToken(); // Lấy token xác thực
    // Kiểm tra token trước khi gửi request
    if (authToken.isEmpty) {
      throw Exception('Token xác thực không được cung cấp. Vui lòng đăng nhập.');
    }

    final body = jsonEncode({
      'description': description,
      'location': geoLocation,
      'price_estimate': priceEstimate,
    });
    debugPrint('ServiceApi: Gửi yêu cầu cứu hộ với body: $body');

    try {
      final res = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'token': 'Bearer $authToken',
        },
        body: body,
      );

      if (res.statusCode == 200) {
        // Server trả về 'Request Created'
        print('Yêu cầu cứu hộ cho service $serviceId đã được tạo thành công.');
        return;
      }

      // Xử lý lỗi HTTP (ví dụ: 401, 500)
      final errorData = jsonDecode(res.body);
      final errorMessage = errorData['err'] ?? 'Lỗi không xác định';

      throw Exception(
        'Lỗi khi tạo yêu cầu cứu hộ (${res.statusCode}): $errorMessage',
      );
    } catch (e) {
      // Xử lý lỗi mạng hoặc lỗi parse JSON
      print('Lỗi: $e');
      rethrow; // Ném lỗi để tầng Controller xử lý
    }
  }
 
}
