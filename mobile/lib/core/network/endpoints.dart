class Endpoints {
  static const base = 'http://localhost:8000'; // đổi theo môi trường

  // user
  static const login = '$base/account/login';
  static const register = '$base/account/create';
  static const me    = '$base/account/me';

  // services
  static const services = '$base/services';
}
