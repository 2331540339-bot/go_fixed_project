import 'dart:convert';
import '../core/network/endpoints.dart';
import 'api_client.dart';
import '../presentation/model/user.dart';

class UserApi {
  UserApi(this._api);
  final ApiClient _api;
  Future<void> register({
    required String fullname,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await _api.post(
      Endpoints.register,
      body: jsonEncode({
        'fullname': fullname,
        'email': email,
        'phone': phone,
        'password_hash': password,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      String msg;
      try {
        final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
        if (body is Map<String, dynamic>) {
          msg =
              body['error']?.toString() ??
              body['message']?.toString() ??
              res.body;
        } else {
          msg = res.body;
        }
      } catch (_) {
        msg = res.body;
      }
      throw Exception('Register failed: $msg');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post(
      Endpoints.login,
      body: jsonEncode({'email': email, 'password_hash': password}),
    );
    if (res.statusCode != 200) {
      throw Exception('Login failed: ${res.body}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return map;
  }

  Future<User> me() async {
    final res = await _api.get(Endpoints.login);

    if (res.statusCode != 200) {
      String errorMessage = res.body.isNotEmpty
          ? jsonDecode(res.body)['err'] ??
                jsonDecode(res.body)['message'] ??
                res.body
          : 'Lỗi máy chủ (${res.statusCode})';

      throw Exception('Fetch /me failed: $errorMessage');
    }

    try {
      final map = jsonDecode(res.body) as Map<String, dynamic>;

      final obj = (map['user'] ?? map) as Map<String, dynamic>;

      return User.fromJson(obj);
    } catch (e) {
      throw Exception('Lỗi dữ liệu: Không thể đọc phản hồi từ Server. $e');
    }
  }
}
