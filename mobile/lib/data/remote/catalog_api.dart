import 'package:http/http.dart' as http;
import 'package:mobile/config/router/app_router.dart';
import 'dart:convert';
import 'package:mobile/data/model/catalog.dart';

class CatalogApi {
  CatalogApi(this._client);
  final http.Client _client;
  static String get _base =>
       AppRouter.main_domain; 
       
  Future<List<Catalog>> fetchCatalogs() async {
    // Backend route: /commerce/catalog/showall
    final uri = Uri.parse('$_base/commerce/catalog/showall');
    final res = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Fetch catalogs failed (${res.statusCode})'); 
    }
    final data = jsonDecode(res.body);
    final list = data is List ? data : (data['items'] ?? []);
    return List<Map<String, dynamic>>.from(list)
        .map(Catalog.fromJson)
        .toList();
  }

  Future<Catalog> fetchCatalogDetail(String id) async {
    final uri = Uri.parse('$_base/commerce/catalog/detail/$id');
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
