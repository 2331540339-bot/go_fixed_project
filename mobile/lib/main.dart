import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/config/themes/app_theme.dart';
import 'package:mobile/presentation/controller/cart_controller.dart';
import 'package:mobile/presentation/controller/location_controller.dart';
import 'package:mobile/presentation/controller/rescue_flow_controller.dart';
import 'package:mobile/presentation/view/home/home_page.dart';
import 'package:mobile/presentation/view/setting/settings_page.dart';
import 'package:mobile/presentation/view/start/intro_page.dart';
import 'package:mobile/presentation/view/start/main_screen.dart';
import 'package:mobile/presentation/view/store/store_page.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
        ChangeNotifierProvider(
          create: (_) => RescueFlowController(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartController(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationController(),
        ),
        // Có thể thêm các controller khác sau này
      ],
      child: const App(),
    ),
  );
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
      child: Intropage(),               // màn hình khởi đầu
    );
  }
}
 
