import 'package:mobile/data/model/user.dart';

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

  Future<User?> getProfile() async {
    // Lấy dữ liệu đã được lưu sau khi login thành công
    return _repo.getStoredProfile(); 
  }

  Future<void> logout() => _repo.logout();

  
}
