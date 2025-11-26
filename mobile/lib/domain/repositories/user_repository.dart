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

  String? get email => _sp.getString('user_email');

  String? get userId => _sp.getString('user_id');

  String? get phone => _sp.getString('user_phone');

  Future<bool> login(String email, String password) async {
    // Nhận toàn bộ dữ liệu từ API
    final data = await _api.login(email: email, password: password); 
    
    final t = data['accessToken'] as String?;
   final user = User.fromJson(data);

    if (t == null || t.isEmpty) {
      debugPrint('UserRepository: Token nhận được là null/rỗng.');
      return false;
    }
    await _sp.setString('token', t);
    await _sp.setString('user_fullname', user.fullname);
    await _sp.setString('user_email', user.email);
    if (user.id != null && user.id!.isNotEmpty) {
      await _sp.setString('user_id', user.id!);
    }
    if (user.phone.isNotEmpty) {
      await _sp.setString('user_phone', user.phone);
    } else {
      await _sp.remove('user_phone'); 
    }
    

    debugPrint('UserRepository: Token và Tên đã lưu thành công: $t');
    return true;
}
  User? get localUser {
    final name = _sp.getString('user_fullname');
    final email = _sp.getString('user_email');
    final phone = _sp.getString('user_phone');
    final id = _sp.getString('user_id');
    
    if (name == null || email == null) return null;

    return User(fullname: name, email: email, phone: phone ?? '', id: id, isActive: true);
  }

   Future<bool> register({
    required String fullname,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _api.register(
      fullname: fullname,
      email: email,
      phone: phone,
      password: password,
    );

    // Với backend hiện tại chỉ trả 'Account Created'
    // → mình chỉ trả true. Nếu sau này backend trả token + user,
    //   bạn có thể lưu giống như login.
    return true;
  }

  Future<User?> getStoredProfile() async {
    return localUser;
  }

  Future<void> logout() async {
    await _sp.remove('token');
    await _sp.remove('user_id');
    await _sp.remove('user_fullname');
    await _sp.remove('user_email');
    await _sp.remove('user_phone');
  }
}
