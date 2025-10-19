import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/config/themes/app_theme.dart';
import 'package:mobile/presentation/view/home/home_page.dart';
import 'package:mobile/presentation/view/home/services_page.dart';
import 'package:mobile/presentation/view/login_page.dart';
import 'package:mobile/presentation/view/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // Kích thước thiết kế gốc
      minTextAdapt: true,               // scale text mềm mại
      splitScreenMode: true,            // hỗ trợ đa cửa sổ/tablet
      builder: (context, child) {
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
        );
        return MaterialApp(
          theme: AppTheme.appTheme,
          debugShowCheckedModeBanner: false,
          home: child,                  // quan trọng: dùng child để giữ context ScreenUtil
        );
      },
      child: const Mainscreen(),         // màn hình khởi đầu
    );
  }
}
 