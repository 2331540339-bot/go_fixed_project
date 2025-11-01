import '../../domain/repositories/user_repository.dart';

class UserController {
  UserController(this._repo);
  final UserRepository _repo;

  static Future<UserController> create() async {
    final repo = await UserRepository.create();
    return UserController(repo);
  }

  UserRepository get userRepository => _repo;

  String? get token => _repo.token;

  Future<bool> login({required String email, required String password}) {
    return _repo.login(email, password);
  }

 // user_controller.dart
// ...
  Future<String> fetchDisplayName() async {
    // 💡 Thay vì gọi API /me, lấy tên từ SP
    final name = _repo.displayName; // Cần thêm getter displayName vào UserRepository
    if (name != null && name.isNotEmpty) {
      return name;
    }
    
    // Nếu chưa có, gọi API /me (Dự phòng)
    final u = await _repo.me();
    return u.fullname; 
  }
// ...

  Future<void> logout() => _repo.logout();

  
}
