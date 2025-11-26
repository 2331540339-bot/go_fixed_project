import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/config/router/app_router.dart';

class PaymentApi {
  PaymentApi(this._client);

  final http.Client _client;

  static String get _base => AppRouter.main_domain;

  /// Gọi API tạo link / QR thanh toán VNPay
  /// Backend: POST /payment_online/create-qr {amount, orderId}
  /// Trả về: { paymentUrl: "https://..." }
  Future<String> createVnPayPaymentUrl({
    required double amount,
    required String orderId,
  }) async {
    final uri = Uri.parse('$_base/payment_online/create-qr');

    final res = await _client.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'amount': amount,
        'orderId': orderId,
      }),
    );

    if (res.statusCode != 200) {
      try {
        final data = jsonDecode(res.body);
        final msg = data['message'] ??
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


