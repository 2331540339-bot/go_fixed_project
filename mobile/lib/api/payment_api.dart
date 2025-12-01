import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/core/network/endpoints.dart';

class PaymentApi {
  PaymentApi(this._client);

  final http.Client _client;

  Future<String> createVnPayPaymentUrl({
    required double amount,
    required String orderId,
  }) async {
    final uri = Uri.parse(Endpoints.createPayment);

    final res = await _client.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'amount': amount, 'orderId': orderId}),
    );

    if (res.statusCode != 200) {
      try {
        final data = jsonDecode(res.body);
        final msg =
            data['message'] ??
            data['err'] ??
            'Tạo thanh toán VNPay thất bại (${res.statusCode})';
        throw Exception(msg.toString());
      } catch (_) {
        throw Exception('Tạo thanh toán VNPay thất bại (${res.statusCode})');
      }
    }

    final data = jsonDecode(res.body);
    final url = data['paymentUrl'] ?? data['payment_url'];
    if (url == null || url.toString().isEmpty) {
      throw Exception('Server không trả về URL thanh toán.');
    }
    return url.toString();
  }

  void dispose() => _client.close();
}
