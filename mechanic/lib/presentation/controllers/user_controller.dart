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
  String? _currentUserId;
  String? get currentUserId => _currentUserId;


  Future<bool> login({required String email, required String password}) async {
    _lastError = null;
    _currentUserId = null; 


    final ok = await _repo.login(email, password);
    if (!ok) {
      _lastError = _repo.lastError ?? 'Đăng nhập thất bại';
      return false;
    }

    final user = await _repo.getStoredProfile();
    final role = user?.role; 
    final userId = user?.id; 

    if (role == UserRole.mechanic && userId != null) {
      _currentUserId = userId;
      return true;
    }
    _lastError = 'Chỉ tài khoản THỢ (mechanic) được phép đăng nhập.';
    await _repo.logout();
    return false;
  }

  Future<User?> getProfile() => _repo.getStoredProfile();

  Future<void> logout() => _repo.logout();
}
