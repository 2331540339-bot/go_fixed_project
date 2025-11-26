import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/config/router/app_router.dart';

class OrderApi {
  OrderApi(this._client);

  final http.Client _client;

  static String get _base => AppRouter.main_domain;

  /// Tạo đơn hàng mới
  ///
  /// Gửi lên backend:
  /// - items: [{product_id, quantity, price}]
  /// - payment_method: "cod" | "banking" | "momo"
  /// - shipping_address: String
  /// Yêu cầu header `token: Bearer <accessToken>`
  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    required String shippingAddress,
    required String authToken,
  }) async {
    if (authToken.isEmpty) {
      throw Exception('Bạn cần đăng nhập để đặt hàng.');
    }

    final uri = Uri.parse('$_base/order/create');

    final body = jsonEncode({
      'items': items,
      'payment_method': paymentMethod,
      'shipping_address': shippingAddress,
    });

    final res = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'token': 'Bearer $authToken',
      },
      body: body,
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      try {
        final data = jsonDecode(res.body);
        final msg = data['message'] ??
            data['err'] ??
            'Tạo đơn hàng thất bại (${res.statusCode})';
        throw Exception(msg.toString());
      } catch (_) {
        throw Exception('Tạo đơn hàng thất bại (${res.statusCode})');
      }
    }

    final data = jsonDecode(res.body);
    return Map<String, dynamic>.from(data);
  }

  void dispose() => _client.close();
}


