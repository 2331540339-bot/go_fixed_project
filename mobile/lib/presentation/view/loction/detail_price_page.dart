import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/config/assets/app_icon.dart';
import 'package:mobile/config/assets/app_image.dart';
import 'package:mobile/config/themes/app_color.dart';
import 'package:mobile/presentation/controller/service_controller.dart';
import 'package:mobile/presentation/controller/user_controller.dart';
import 'package:mobile/presentation/view/loction/search_mechanic.dart';
import 'package:mobile/presentation/widgets/appbars/main_app_bar.dart';
import 'package:mobile/presentation/widgets/modal/showModalCenterSheet.dart';

class DetailPricePage extends StatefulWidget {
  const DetailPricePage({super.key});

  @override
  State<DetailPricePage> createState() => _DetailPricePageState();
}

class _DetailPricePageState extends State<DetailPricePage> {
  UserController? _userCtrl;
  ServiceController? _serviceCtrl; // 💡 Controller mới
  String _name = '...';
  bool _loadingName = true;
  bool _isCallingRescue = false; // 💡 Trạng thái loading cho nút Gọi ngay

  final String _location = 'Q12, TP.HCM';
  final _baseStyle = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );
  final _redStyle = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.primaryColor,
  );

  // 💡 Dữ liệu cứu hộ giả định (THAY THẾ BẰNG DỮ LIỆU THỰC TẾ CỦA TRANG NÀY)
  final String _mockServiceId = '68ea1226a641c3a9e17e90f5';
  final String _mockDescription = 'Xe bị thủng lốp và hết xăng.';
  final double _mockPrice = 450000.0;
  // Tọa độ phải là [lng, lat] theo GeoJSON
  final Map<String, dynamic> _mockLocation = {
    "coordinates": [105.854444, 21.028511],
  };
  // ---------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  Future<void> _initControllers() async {
    // Khởi tạo cả hai Controller
    _userCtrl = await UserController.create();
    _serviceCtrl = await ServiceController.create();

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

  // ---------------------------------------------------------------------
  // 🎯 HÀM GỌI RESCUE CHÍNH
  // ---------------------------------------------------------------------
  Future<void> _callRescue() async {
    // 💡 Kiểm tra null và trạng thái loading
    if (_isCallingRescue || _serviceCtrl == null) return;

    // Kiểm tra đăng nhập trước khi gọi API
    final String? token = _userCtrl?.userRepository.token;
    if (token == null || token.isEmpty) {
      // Hiện modal yêu cầu đăng nhập
      showModalCancel(context);
      return;
    }

    setState(() => _isCallingRescue = true);

    try {
      // Gọi hàm trong Controller để xử lý logic API và Token
      await _serviceCtrl!.sendRescueRequest(
        serviceId: _mockServiceId,
        description: _mockDescription,
        location: _mockLocation,
        priceEstimate: _mockPrice,
        authToken: token,
      );

      if (!mounted) return;

      // 1. Thành công: Hiện Modal thông báo
      showModalSuccess(context);

      // 2. Chuyển sang trang tìm kiếm thợ (Sau khi modal đóng hoặc sau một delay ngắn)
      // Dùng pushReplacement để người dùng không quay lại trang giá nữa.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SearchMechanic()),
      );
    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('DetailPricePage: Lỗi khi: $errorMessage');
      // 3. Thất bại: Hiện Modal lỗi
      // showModalCancel(context);
    } finally {
      if (mounted) {
        setState(() => _isCallingRescue = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? authToken = _userCtrl?.userRepository.token;
    debugPrint('DetailPricePage: authToken = $authToken');
    return Scaffold(
      appBar: MainAppBar(
        logo: Image.asset(AppImages.mainLogo, height: 100.h, width: 100.w),
        name: _name,
        loadingName: _loadingName,
        location: _location,
        onAvatarTap: () {},
        avatarWidget: SvgPicture.asset(AppIcon.user),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (Phần nội dung giá giữ nguyên)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Xe ', style: _redStyle),
                    TextSpan(text: 'của bạn đang', style: _baseStyle),
                    TextSpan(text: ' bị hỏng!!!', style: _redStyle),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              // ... (Container chi phí tạm tính)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ... (Chi tiết giá và tổng cộng)
                    Text(
                      'Chi phí tam tính',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Thay lốp xe: 200,000 VND",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "Thay dầu máy: 150,000 VND",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "Công sửa chữa: 100,000 VND",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 25.h),
                    Row(
                      children: [
                        Text(
                          "Tổng cộng:",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        Spacer(),
                        Text(
                          "450,000 VND",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Spacer(),
              Row(
                children: [
                  // Nút Hủy
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: _isCallingRescue
                        ? null
                        : () {
                            // Logic Hủy yêu cầu (hoặc quay lại trang trước)
                            Navigator.pop(context);
                          },
                    child: Text(
                      'Huỷ',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Spacer(),
                  // Nút Gọi ngay (Rescue)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                    ),
                    onPressed: _callRescue, // 🎯 GỌI HÀM _callRescue
                    child: Text(
                      'Gọi ngay',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
