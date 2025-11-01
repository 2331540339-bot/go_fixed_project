import 'package:flutter/widgets.dart';
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
    final sp = await SharedPreferences.getInstance();
    return UserRepository(UserApi(api), sp);
  }

  String? get token => _sp.getString('token');

  String? get displayName => _sp.getString('user_fullname');

  Future<bool> login(String email, String password) async {
    // 💡 Nhận toàn bộ dữ liệu từ API
    final data = await _api.login(email: email, password: password); 
    
    final t = data['accessToken'] as String?;
    final n = data['fullname'] as String?; // 🎯 LẤY TÊN

    if (t == null || t.isEmpty) {
      debugPrint('UserRepository: Token nhận được là null/rỗng.');
      return false;
    }

    // 💡 LƯU CẢ TÊN VÀ TOKEN VÀO SHARED PREFERENCES
    await _sp.setString('token', t);
    if (n != null) {
      await _sp.setString('user_fullname', n); // 🎯 LƯU TÊN
    }

    debugPrint('UserRepository: Token và Tên đã lưu thành công: $t, $n');
    return true;
}
  Future<User> me() {
  
    return _api.me();
  }

  Future<void> logout() async => _sp.remove('token');
}
