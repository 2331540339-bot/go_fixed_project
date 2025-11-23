import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/config/router/app_router.dart';
import 'package:mobile/data/model/product.dart';

class ProductApi {
  ProductApi(this._client);
  final http.Client _client;
  static String get _base => AppRouter.main_domain;

  Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse('$_base/commerce/product/showall');
    final res = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Fetch products failed (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    final list = data is List ? data : (data['items'] ?? []);
    return List<Map<String, dynamic>>.from(list)
        .map(Product.fromJson)
        .toList();
  }

  Future<Product> fetchProductDetail(String id) async {
    final uri = Uri.parse('$_base/commerce/product/show/$id');
    final res = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Fetch product detail failed (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    return Product.fromJson(Map<String, dynamic>.from(data));
  }

  void dispose() => _client.close();
}
