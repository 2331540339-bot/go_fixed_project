import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/data/model/service.dart';
import 'package:mobile/config/router/app_router.dart';

class ServiceApi {
  ServiceApi(this._client);

  final http.Client _client;
  static String get _base => AppRouter.main_domain; // ví dụ: http://localhost:8000

  /// GET /services?limit=&offset=&q=
  Future<List<Service>> listServices({
    int limit = 50,
    int offset = 0,
    String? q,
  }) async {
    final uri = Uri.parse('$_base/services').replace(queryParameters: {
      'limit': '$limit',
      'offset': '$offset',
      if (q != null && q.isNotEmpty) 'q': q,
    });

    final res = await _client.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('Fetch services failed (${res.statusCode})');
    }

    final body = jsonDecode(res.body);
    // Tùy backend: hoặc trả về List, hoặc {items: [...]}
    final list = body is List ? body : (body['items'] ?? []);
    return List<Map<String, dynamic>>.from(list)
        .map(Service.fromJson)
        .toList();
  }
}
