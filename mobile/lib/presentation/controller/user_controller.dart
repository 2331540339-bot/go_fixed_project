import '../../domain/repositories/user_repository.dart';
import '../../data/model/user.dart';

class UserController {
  UserController(this._repo);
  final UserRepository _repo;

  static Future<UserController> create() async {
    final repo = await UserRepository.create();
    return UserController(repo);
  }

  String? get token => _repo.token;

  Future<bool> login({required String email, required String password}) {
    return _repo.login(email, password);
  }

  Future<String> fetchDisplayName() async {
    final u = await _repo.me();
    return u.fullname;
  }

  Future<void> logout() => _repo.logout();
}
