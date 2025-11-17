import 'package:flutter/widgets.dart';
import 'package:mechanic/presentation/models/user.dart';
import 'package:mechanic/presentation/models/enums.dart'; // để dùng UserRole, UserRoleX
import 'package:mechanic/presentation/remote/user_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // ==== state & getters ====
  String? _lastError;
  String? get lastError => _lastError;

  String? get token => _sp.getString('token');
  String? get displayName => _sp.getString('user_fullname');
  String? get email => _sp.getString('user_email');
  String? get phone => _sp.getString('user_phone');

  /// role lưu ở dạng chuỗi (json) để bền với SP
  String? get roleString => _sp.getString('user_role');

  /// Role dạng enum (map từ chuỗi)
  UserRole? get userRole => UserRoleX.from(roleString);

  bool get isMechanic => userRole == UserRole.mechanic;

  /// Đăng nhập, lưu token + hồ sơ vào SharedPreferences.
  /// Trả `true` nếu server trả token hợp lệ (không kiểm tra role tại đây).
  Future<bool> login(String email, String password) async {
    _lastError = null;
    try {
      // Gọi API login (server trả { ...user fields..., accessToken })
      final data = await _api.login(email: email, password: password);

      // Lấy token
      final t = data['accessToken'] as String?;
      if (t == null || t.isEmpty) {
        _lastError = 'Token không hợp lệ.';
        debugPrint('UserRepository: Token null/rỗng');
        return false;
      }

      // Parse user theo model của bạn
      final user = User.fromJson(data);

      // Lưu vào SharedPreferences (token + các field cần dùng lại)
      await _sp.setString('token', t);
      await _sp.setString('user_fullname', user.fullname);
      await _sp.setString('user_email', user.email);

      final ph = (user.phone).trim();
      if (ph.isNotEmpty) {
        await _sp.setString('user_phone', ph);
      } else {
        await _sp.remove('user_phone');
      }

      // Lưu role dạng chuỗi (enum -> string) nếu có
      final roleStr = user.role?.json ?? (data['role']?.toString() ?? '');
      if (roleStr.isNotEmpty) {
        await _sp.setString('user_role', roleStr);
      } else {
        await _sp.remove('user_role');
      }

      // (tuỳ nhu cầu có thể lưu thêm id/avatar…)
      if ((user.id ?? '').isNotEmpty) {
        await _sp.setString('user_id', user.id!);
      } else {
        await _sp.remove('user_id');
      }
      if ((user.avatarUrl ?? '').isNotEmpty) {
        await _sp.setString('user_avatar', user.avatarUrl!);
      } else {
        await _sp.remove('user_avatar');
      }

      debugPrint('UserRepository: Lưu token/profile OK. role=$roleStr');
      return true;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('UserRepository.login error: $e');
      return false;
    }
  }

  /// Tạo User local từ SP (đủ dùng cho UI điều hướng/quyền)
  User? get localUser {
    final name = _sp.getString('user_fullname');
    final mail = _sp.getString('user_email');
    if (name == null || mail == null) return null;

    final ph = _sp.getString('user_phone') ?? '';
    final id = _sp.getString('user_id');
    final avatar = _sp.getString('user_avatar');
    final role = userRole; // map từ roleString

    return User(
      id: id,
      fullname: name,
      email: mail,
      phone: ph,
      currentLocation: null, // không lưu SPA ở đây
      avatarUrl: avatar,
      role: role,
      isActive: true, // nếu cần chính xác, lưu thêm is_active từ API và đọc ra
      createdAt: null,
      updatedAt: null,
    );
  }

  Future<User?> getStoredProfile() async => localUser;

  Future<void> logout() async {
    await _sp.remove('token');
    await _sp.remove('user_fullname');
    await _sp.remove('user_email');
    await _sp.remove('user_phone');
    await _sp.remove('user_role');
    await _sp.remove('user_id');
    await _sp.remove('user_avatar');
  }
}
