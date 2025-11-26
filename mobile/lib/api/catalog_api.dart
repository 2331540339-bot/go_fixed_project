import 'package:http/http.dart' as http;
import 'package:mobile/core/network/endpoints.dart';
import 'dart:convert';
import 'package:mobile/presentation/model/catalog.dart';

class CatalogApi {
  CatalogApi(this._client);
  final http.Client _client;

  Future<List<Catalog>> fetchCatalogs() async {
    final uri = Uri.parse(Endpoints.catelogs);
    final res = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Fetch catalogs failed (${res.statusCode})');
    }
    final data = jsonDecode(res.body);
    final list = data is List ? data : (data['items'] ?? []);
    return List<Map<String, dynamic>>.from(list).map(Catalog.fromJson).toList();
  }

  Future<Catalog> fetchCatalogDetail(String id) async {
    final uri = Uri.parse('${Endpoints.catelogDetail}$id');
    final res = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('Fetch catalog detail failed (${res.statusCode})');
    }
    final data = jsonDecode(res.body);
    return Catalog.fromJson(Map<String, dynamic>.from(data));
  }

  void dispose() => _client.close();
}
