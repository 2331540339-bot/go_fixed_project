import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:mobile/config/assets/app_icon.dart';
import 'package:mobile/config/assets/app_image.dart';
import 'package:mobile/config/themes/app_color.dart';

// Controllers
import 'package:mobile/presentation/controller/user_controller.dart';
import 'package:mobile/presentation/controller/banner_controller.dart';
import 'package:mobile/presentation/controller/service_controller.dart';

// Models
import 'package:mobile/data/model/service.dart';
import 'package:mobile/presentation/widgets/appbars/main_app_bar.dart';

// UI widgets cho banner
import 'package:mobile/presentation/widgets/banner/banner_carousel.dart';
import 'package:mobile/presentation/widgets/banner/dots_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- User ---
  UserController? _userCtrl;
  String _name = '...';
  bool _loadingName = true;

  // --- Banner ---
  BannerController? _bannerCtrl;
  int _bannerIndex = 0;

  // --- Services ---
  ServiceController? _svcCtrl;

  // mock location
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

    // Banner
    _bannerCtrl = await BannerController.create();
    _bannerCtrl!.addListener(_onBannerChanged);
    await _bannerCtrl!.load(); // gọi API /banners
    if (!mounted) return;
    setState(() {}); // refresh

    // Services
    _svcCtrl = await ServiceController.create();
    _svcCtrl!.addListener(_onServiceChanged);
    await _svcCtrl!.load(limit: 6); // lấy tối đa 6 service
    if (!mounted) return;
    setState(() {}); // refresh
  }

  void _onBannerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onServiceChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _bannerCtrl?.removeListener(_onBannerChanged);
    _svcCtrl?.removeListener(_onServiceChanged);
    _bannerCtrl?.dispose();
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loadingBanners = _bannerCtrl?.loading ?? true;
    final bannerError = _bannerCtrl?.error;
    final bannerItems = _bannerCtrl?.items ?? const [];

    final svcLoading = _svcCtrl?.loading ?? true;
    final svcError = _svcCtrl?.error;
    final svcItems = _svcCtrl?.items ?? const <Service>[];

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
              // ---- Tìm kiếm + nút bên phải
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
                      child: SvgPicture.asset(
                        AppIcon.heart,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // ---- Banner + indicator
              if (loadingBanners && bannerItems.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (bannerError != null && bannerItems.isEmpty)
                Text('Lỗi banner: $bannerError')
              else ...[
                BannerCarousel(
                  images: bannerItems.map((e) => e.imageUrl).toList(),
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  onIndexChanged: (i) => setState(() => _bannerIndex = i),
                  onTap: (i) {
                    // TODO: mở bannerItems[i].linkUrl nếu có
                  },
                ),
                SizedBox(height: 10.h),
                DotsIndicator(count: bannerItems.length, index: _bannerIndex),
              ],
              SizedBox(height: 20.h),

              // Align(
              //   alignment: Alignment.centerLeft,
              //   child: Text(
              //     'Services',
              //     style: TextStyle(
              //       color: AppColor.primaryColor,
              //       fontSize: 14.sp,
              //       fontWeight: FontWeight.w900,
              //     ),
              //   ),
              // ),
              SizedBox(height: 20.h),

              // ---- Grid Services (lấy từ controller)
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (svcLoading && svcItems.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (svcError != null && svcItems.isEmpty) {
                      return Center(child: Text('Lỗi services: $svcError'));
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.1,
                          ),
                      itemCount: math.min(
                        svcItems.length,
                        6,
                      ), // chỉ hiển thị tối đa 6
                      itemBuilder: (_, i) {
                        final s = svcItems[i];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              // TODO: điều hướng sang chi tiết dịch vụ
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (s.iconUrl != null && s.iconUrl!.isNotEmpty)
                                  SizedBox(
                                    height: 100,
                                    child: Image.network(
                                      s.iconUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, progress) {
                                            if (progress == null) return child;
                                            return const Center(
                                              child: SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            );
                                          },
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image_not_supported),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.home_repair_service,
                                    size: 40,
                                  ),
                                SizedBox(height: 6.h),
                                Text(
                                  s.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                // Nếu muốn hiện giá:
                                // Text('${s.price.toStringAsFixed(0)} đ', style: const TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
