import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/endpoints.dart';
import 'package:mobile/presentation/model/product.dart';

class ProductApi {
  ProductApi(this._client);
  final http.Client _client;

  Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse(Endpoints.products);
    final res = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Fetch products failed (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    final list = data is List ? data : (data['items'] ?? []);
    return List<Map<String, dynamic>>.from(list).map(Product.fromJson).toList();
  }

  Future<Product> fetchProductDetail(String id) async {
    final uri = Uri.parse('${Endpoints.productDetail}$id');
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
