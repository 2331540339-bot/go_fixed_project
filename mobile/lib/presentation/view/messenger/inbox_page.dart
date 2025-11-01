import 'package:flutter/material.dart';
import 'package:mobile/config/assets/app_icon.dart';
import 'package:mobile/config/assets/app_image.dart';
import 'package:mobile/presentation/controller/user_controller.dart';
import 'package:mobile/presentation/widgets/appbars/main_app_bar.dart';
import 'package:mobile/presentation/widgets/box_messenger/box_mess.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  UserController? _userCtrl;
  String _name = '...';
  bool _loadingName = true;
  String _location = 'Q12, TP.HCM';

  @override
  void initState() {
    super.initState();
    // Bắt đầu tải dữ liệu ngay lập tức
    _initControllers();
  }

  Future<void> _initControllers() async {
    // 1. Khởi tạo Controllers
    _userCtrl = await UserController.create();
    if (!mounted) return;

    // 2. Xử lý Tên người dùng (Ưu tiên)
    await _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final n = await _userCtrl!.getProfile();
      if (!mounted) return;
      setState(() {
        _name = n!.fullname;
        _loadingName = false;
        // _address = n.address ?? 'Chưa cập nhật';
      });
    } catch (e) {
      if (!mounted) return;

      debugPrint('LỖI KHI TẢI TÊN NGƯỜI DÙNG: $e');

      // 🎯 Logic xác định lỗi 401/lỗi xác thực
      final error = e.toString().toLowerCase();
      if (error.contains('401') ||
          error.contains('unauthorized') ||
          error.contains('not authenticated')) {}

      setState(() {
        _name = 'Chưa đăng nhập';
        // _address = 'Chưa đăng nhập';
        _loadingName = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        logo: Image.asset(AppImages.mainLogo, height: 100.h, width: 100.w),
        name: _name,
        loadingName: _loadingName,
        location: _location,
        onAvatarTap: () {
          // TODO: Điều hướng đến trang Profile / Login nếu _name là 'Chưa đăng nhập'
          debugPrint('Tapping avatar, current name: $_name');
        },
        avatarWidget: SvgPicture.asset(AppIcon.user),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [BoxMess()],
        ),
      ),
    );
  }
}
