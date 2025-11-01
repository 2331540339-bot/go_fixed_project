import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/config/api_config.dart';
import 'package:mobile/config/assets/app_icon.dart';
import 'package:mobile/config/assets/app_image.dart';
import 'package:mobile/config/themes/app_color.dart';
import 'package:mobile/presentation/controller/user_controller.dart';
import 'package:mobile/presentation/view/loction/map_screen.dart';
import 'package:mobile/presentation/widgets/appbars/main_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/presentation/widgets/modal/showModalCenterSheet.dart';

class SearchMechanic extends StatefulWidget {
  const SearchMechanic({super.key});

  @override
  State<SearchMechanic> createState() => _SearchMechanicState();
}

class _SearchMechanicState extends State<SearchMechanic> {
  UserController? _userCtrl;
  String _name = '...';
  bool _loadingName = true;
  LatLng? _selectedDestination;

  final String _location = 'Q12, TP.HCM';
  final bool _loadingLoc = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }
  void _handleDestinationSelected(LatLng newDest) {
    setState(() {
      _selectedDestination = newDest;
    });
  }

  Future<void> _initControllers() async {
    // User
    _userCtrl = await UserController.create();
    if (!mounted) return;
    try {
      final n = await _userCtrl!.fetchDisplayName();
      if (!mounted) return;
      setState(() {
        _name = n;
        _loadingName = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _name = 'Chưa đăng nhập';
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
        avatarWidget: SvgPicture.asset(AppIcon.user),
        onAvatarTap: () {
          debugPrint('Avatar tapped');
        },
        location: _location,
        loadingName: _loadingName,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Đang tìm kiếm ',
                      style: TextStyle(fontSize: 18.sp, color: Colors.black),
                    ),
                    TextSpan(
                      text: 'THỢ',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' gần bạn...',
                      style: TextStyle(fontSize: 18.sp, color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
               MapRouteBox(
                dest: _selectedDestination , 
                apiKey: ApiConfig.goongMapsApiKey, 
                mapTilerKey: ApiConfig.goongMaptilesApiKey, 
                vehicle: 'bike', 
              ),
              const SizedBox(height: 20),
              Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                       showModalCancel(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'HỦY TÌM KIẾM',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )

              // Thêm các widget khác để hiển thị kết quả tìm kiếm
            ],
          ),
        ),
      ),
    );
  }
}
