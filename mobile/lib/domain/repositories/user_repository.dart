import 'package:shared_preferences/shared_preferences.dart';
import '../../data/remote/user_api.dart';
import '../../data/model/user.dart';
import '../../core/network/api_client.dart';

class UserRepository {
  UserRepository(this._api, this._sp);
  final UserApi _api;
  final SharedPreferences _sp;

  static Future<UserRepository> create() async {
    final api = await ApiClient.create();
    final sp  = await SharedPreferences.getInstance();
    return UserRepository(UserApi(api), sp);
  }

  String? get token => _sp.getString('token');

  Future<bool> login(String email, String password) async {
    final t = await _api.login(email: email, password: password);
    if (t == null || t.isEmpty) return false;
    await _sp.setString('token', t);
    return true;
  }

  Future<User> me() => _api.me();

  Future<void> logout() async => _sp.remove('token');
}
