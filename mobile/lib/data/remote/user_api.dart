import 'dart:convert';
import '../../core/network/endpoints.dart';
import '../../core/network/api_client.dart';
import '../model/user.dart';

class UserApi {
  UserApi(this._api);
  final ApiClient _api;

  Future<String?> login({required String email, required String password}) async {
    final res = await _api.post(
      Endpoints.login,
      body: jsonEncode({'email': email, 'password_hash': password}),
    );
    if (res.statusCode != 200) {
      throw Exception('Login failed: ${res.body}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return map['token'] as String?;
  }

  Future<User> me() async {
    final res = await _api.get(Endpoints.me);
    if (res.statusCode != 200) {
      throw Exception('Fetch /me failed: ${res.body}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    // server có thể trả { user: {...} } hoặc trả thẳng {...}
    final obj = (map['user'] ?? map) as Map<String, dynamic>;
    return User.fromJson(obj);
  }
}
