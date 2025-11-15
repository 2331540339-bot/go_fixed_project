import 'package:flutter/foundation.dart' show kReleaseMode, defaultTargetPlatform, TargetPlatform, kIsWeb;

class AppRouter {
  /// Cho phép override qua:
  /// flutter run --dart-define=API_BASE=http://192.168.1.10:8000
  static const String _envBase = String.fromEnvironment('API_BASE');

  static String get main_domain {
    // 1) Ưu tiên ENV nếu có
    if (_envBase.isNotEmpty) return _envBase;

    // 2) Release -> dùng domain thật (HTTPS)
    if (kReleaseMode) return 'https://api.yourdomain.com';

    // 3) Debug/Profiling theo nền tảng
    if (kIsWeb) return 'http://127.0.0.1:8000'; // chạy web local

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android emulator (AVD) truy cập host qua 10.0.2.2
        return 'http://10.0.2.2:8000';
      case TargetPlatform.iOS:
        // iOS Simulator dùng localhost/127.0.0.1
        return 'http://127.0.0.1:8000';
      default:
        // Desktop hoặc nền tảng khác
        return 'http://127.0.0.1:8000';
    }
  }

  /// Helper ghép endpoint
  static String api(String path) => '$main_domain$path';
}
