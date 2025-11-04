import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Import cấu hình và theme
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

  final _searchCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Bắt đầu tải dữ liệu ngay lập tức
    _initControllers();
  }

  Future<void> _initControllers() async {
    // 1. Khởi tạo Controllers
    _userCtrl = await UserController.create();
    _bannerCtrl = await BannerController.create();
    _svcCtrl = await ServiceController.create();

    if (!mounted) return;

    // 2. Xử lý Tên người dùng (Ưu tiên)
    await _loadUserName();

    // 3. Xử lý Banner
    _bannerCtrl!.addListener(_onBannerChanged);
    await _bannerCtrl!.load();
    if (!mounted) return;
    // setState({}); // Không cần gọi lại nếu _onBannerChanged đã notify

    // 4. Xử lý Services
    _svcCtrl!.addListener(_onServiceChanged);
    await _svcCtrl!.load(limit: 6);
    if (!mounted) return;
    // setState({}); // Không cần gọi lại nếu _onServiceChanged đã notify
  }

  Future<void> _loadUserName() async {
    try {
      final n = await _userCtrl!.getProfile();
      if (!mounted) return;
      setState(() {
        _name = n!.fullname;
        _loadingName = false;
      });
    } catch (e) {
      if (!mounted) return;

      debugPrint('LỖI KHI TẢI TÊN NGƯỜI DÙNG: $e');
      String displayName = 'Lỗi dữ liệu';

      // 🎯 Logic xác định lỗi 401/lỗi xác thực
      final error = e.toString().toLowerCase();
      if (error.contains('401') ||
          error.contains('unauthorized') ||
          error.contains('not authenticated')) {
        displayName = 'Chưa đăng nhập';
      }

      setState(() {
        _name = displayName;
        _loadingName = false;
      });
    }
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
    _svcCtrl?.dispose(); // 💡 Đảm bảo dispose cả service controller
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Luôn kiểm tra null an toàn trước khi truy cập
    final loadingBanners = _bannerCtrl?.loading ?? true;
    final bannerError = _bannerCtrl?.error;
    final bannerItems = _bannerCtrl?.items ?? const [];

    final svcLoading = _svcCtrl?.loading ?? true;
    final svcError = _svcCtrl?.error;
    final svcItems = _svcCtrl?.items ?? const <Service>[];

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

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              // ---- Tìm kiếm + nút bên phải (Giữ nguyên)
              Row(
                // ... (Logic tìm kiếm)
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtl,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: AppColor.primaryColor,
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
                        /* TODO: mở bộ lọc nâng cao */
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
              // Logic hiển thị banner được tối ưu hóa để xử lý cả trường hợp rỗng
              if (loadingBanners)
                const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (bannerError != null)
                Text('Lỗi banner: $bannerError')
              else if (bannerItems.isEmpty) // 🎯 XỬ LÝ KHI DANH SÁCH RỖNG
                const SizedBox(
                  height: 150,
                  child: Center(
                    child: Text('Chưa có banner nào được đăng tải.'),
                  ),
                )
              else
                Column(
                  children: [
                    BannerCarousel(
                      images: bannerItems.map((e) => e.imageUrl).toList(),
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      onIndexChanged: (i) => setState(() => _bannerIndex = i),
                      onTap: (i) {
                        /* TODO: mở bannerItems[i].linkUrl nếu có */
                      },
                    ),
                    SizedBox(height: 10.h),
                    DotsIndicator(
                      count: bannerItems.length,
                      index: _bannerIndex,
                    ),
                  ],
                ),
              SizedBox(height: 20.h),

              // ... (Phần hiển thị Services giữ nguyên)
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (svcLoading && svcItems.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (svcError != null && svcItems.isEmpty) {
                      return Center(child: Text('Lỗi services: $svcError'));
                    }
                    if (svcItems.isEmpty) {
                      // 💡 Xử lý trường hợp service trống
                      return const Center(
                        child: Text('Không tìm thấy dịch vụ nào.'),
                      );
                    }
                    // ... (Gridview.builder)
                    return GridView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            // childAspectRatio: 0.75,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                          ),
                      itemCount: math.min(svcItems.length, 6),
                      itemBuilder: (_, i) {
                        final s = svcItems[i];
                        return Column(
                          children: [
                            Expanded(
                              child: Card(
                                // elevation: 2,
                                // margin: EdgeInsets.all( 4.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {},
                                  child: SizedBox(
                                    height: 120.h,
                                    width: 120.w,
                                    child:
                                        (s.iconUrl != null &&
                                            s.iconUrl!.isNotEmpty)
                                        // 💡 Sử dụng toán tử 3 ngôi (Ternary Operator) cho gọn
                                        ? Image.network(
                                            s.iconUrl!,
                                            height: 60.h,
                                            width: 60.w,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return const Icon(
                                                    // Icon khi load lỗi
                                                    Icons.home_repair_service,
                                                    size: 40,
                                                  );
                                                },
                                          )
                                        : const Icon(
                                            // Icon mặc định
                                            Icons.home_repair_service,
                                            size: 40,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 6.h),
                              Text(
                                s.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                          ],
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
