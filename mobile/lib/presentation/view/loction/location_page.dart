import 'package:flutter/material.dart';
import 'package:mobile/config/assets/app_icon.dart';
import 'package:mobile/config/assets/app_image.dart';
import 'package:mobile/config/themes/app_color.dart';
import 'package:mobile/presentation/controller/user_controller.dart';
import 'package:mobile/presentation/view/loction/map_screen.dart';
import 'package:mobile/presentation/widgets/appbars/main_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  UserController? _userCtrl;
  String _name = '...';
  bool _loadingName = true;
  final String _location = 'Q12, TP.HCM';
  final bool _loadingLoc = false;
  final _searchCtl = TextEditingController();
  @override
  void initState() {
    super.initState();
    _initControllers();
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
  void dispose() {
    _searchCtl.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        logo: Image.asset(AppImages.mainLogo, height: 100.h, width: 40.w),
        name: _name,
        loadingName: _loadingName,
        location: _location, // hoặc null nếu không cần
        onAvatarTap: () {
          // mở trang profile / settings
        },
        avatarWidget: SvgPicture.asset(AppIcon.user),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtl,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: AppColor.primaryColor,
                      onChanged: (q) {
                        // TODO: lọc dữ liệu nếu cần
                      },
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm...',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        suffixIcon: _searchCtl.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  _searchCtl.clear();
                                  setState(() {});
                                },
                              ),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColor.primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColor.primaryColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: mở bộ lọc nâng cao
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffF3F8FB),
                        foregroundColor: Colors.white,
                        side: BorderSide(color: AppColor.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(48, 48),
                        padding: EdgeInsets.zero,
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.black,
                        size: 16.w,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              MapRouteBox(
                dest: const LatLng(10.776, 106.700), // điểm đến
                apiKey:
                    "https://api.openrouteservice.org/v2/directions/driving-car?api_key=eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjZlNzBmN2ZhNGJjMTQ2NTJhZjM4N2I1MWI2ZDVhNDM4IiwiaCI6Im11cm11cjY0In0=&start=8.681495,49.41461&end=8.687872,49.420318", // đừng hardcode—đọc từ secrets/.env
                height: 260,
                onError: (err) => debugPrint('Map error: $err'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
