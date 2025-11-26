// lib/data/remote/banner_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/endpoints.dart';
import 'package:mobile/presentation/model/banner.dart';

class BannerApi {
  BannerApi(this._client, this.baseUrl);
  final http.Client _client;
  final String baseUrl;

  Future<List<Banner>> fetchBanners() async {
    final uri = Uri.parse(Endpoints.banners);
    final res = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Fetch banners failed (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    // hỗ trợ cả dạng {items:[...]} hoặc mảng trực tiếp [...]
    final list = (data is Map && data['items'] is List)
        ? (data['items'] as List)
        : (data as List);

    return list
        .map((e) => Banner.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void dispose() => _client.close();
}
