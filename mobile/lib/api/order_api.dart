import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/endpoints.dart';

class OrderApi {
  OrderApi(this._client);

  final http.Client _client;

  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    required String shippingAddress,
    required String authToken,
  }) async {
    if (authToken.isEmpty) {
      throw Exception('Bạn cần đăng nhập để đặt hàng.');
    }

    final uri = Uri.parse(Endpoints.createOrder);

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


