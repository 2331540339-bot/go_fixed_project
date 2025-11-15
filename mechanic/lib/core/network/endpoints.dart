
import 'package:mechanic/config/route/app_router.dart';

class Endpoints {
  static final base = AppRouter.main_domain; 

  // user
  static final login = '$base/account/login';
  static final register = '$base/account/create';
  static final me    = '$base/account/me';

  // services
  static final services = '$base/services';
}
