import 'package:flutter/foundation.dart';

class AppRouter {
 static const String main_domain = kReleaseMode
    ? 'https://api.yourdomain.com'
    : 'http://localhost:8000';
}