import 'package:mechanic/presentation/models/user.dart';
import 'package:mechanic/presentation/models/enums.dart';
import 'package:mechanic/presentation/repositories/user_repository.dart';

class UserController {
  UserController(this._repo);
  final UserRepository _repo;

  String? _lastError;
  String? get lastError => _lastError;

  static Future<UserController> create() async {
    final repo = await UserRepository.create();
    return UserController(repo);
  }

  UserRepository get userRepository => _repo;

  String? get token => _repo.token;

  /// Chỉ đăng nhập thành công nếu role là 'mechanic'
  Future<bool> login({required String email, required String password}) async {
    _lastError = null;

    // 1) gọi repo
    final ok = await _repo.login(email, password);
    if (!ok) {
      _lastError = _repo.lastError ?? 'Đăng nhập thất bại';
      return false;
    }

    // 2) đọc profile/role đã lưu
    final user = await _repo.getStoredProfile();
    final role = user?.role; // enum UserRole?

    if (role == UserRole.mechanic) {
      return true;
    }

    // 3) không phải thợ -> huỷ phiên + báo lỗi
    _lastError = 'Chỉ tài khoản THỢ (mechanic) được phép đăng nhập.';
    await _repo.logout();
    return false;
  }

  Future<User?> getProfile() => _repo.getStoredProfile();

  Future<void> logout() => _repo.logout();
}
