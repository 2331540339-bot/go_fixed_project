import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:mobile/config/assets/app_icon.dart';
import 'package:mobile/config/assets/app_image.dart';
import 'package:mobile/config/themes/app_color.dart';

import 'package:mobile/presentation/controller/service_controller.dart';
import 'package:mobile/presentation/controller/user_controller.dart';
import 'package:mobile/presentation/controller/rescue_flow_controller.dart';

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
  ServiceController? _serviceCtrl;
  String _name = '...';
  bool _loadingName = true;
  bool _isCallingRescue = false;

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

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  Future<void> _initControllers() async {
    _userCtrl = await UserController.create();
    _serviceCtrl = await ServiceController.create();

    if (!mounted) return;
    try {
      final n = await _userCtrl!.getProfile();
      if (!mounted) return;
      setState(() {
        _name = n!.fullname;
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

  Future<void> _callRescue() async {
    if (_isCallingRescue || _serviceCtrl == null) return;

    final rescueFlow = context.read<RescueFlowController>();
    final service = rescueFlow.service;
    final desc = rescueFlow.description ?? '';
    final loc = rescueFlow.location ?? <String, dynamic>{};
    final price = rescueFlow.priceEstimate ?? service?.basePrice ?? 0;

    if (service == null) {
      debugPrint('DetailPricePage: service null, không thể gửi rescue request');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thiếu thông tin dịch vụ, vui lòng chọn lại.'),
        ),
      );
      return;
    }

    final String? token = _userCtrl?.userRepository.token;
    if (token == null || token.isEmpty) {
      showModalCancel(context);
      return;
    }

    setState(() => _isCallingRescue = true);

    try {
      await _serviceCtrl!.sendRescueRequest(
        serviceId: service.id,
        description: desc,
        location: loc,
        priceEstimate: price,
        authToken: token,
      );

      if (!mounted) return;

      showModalSuccess(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SearchMechanic()),
      );
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('DetailPricePage: Lỗi khi gọi cứu hộ: $errorMessage');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $errorMessage')));
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

    // Lấy dữ liệu từ RescueFlowController
    final rescueFlow = context.watch<RescueFlowController>();
    final service = rescueFlow.service;
    final desc = rescueFlow.description ?? 'Không có mô tả';
    final base = rescueFlow.priceEstimate ?? service?.basePrice ?? 0;
    final plus = 100000;

    final totalPrice = base + plus;

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
        child: service == null
            ? const Center(
                child: Text('Không có thông tin dịch vụ. Vui lòng quay lại.'),
              )
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'Xe ', style: _redStyle),
                          TextSpan(
                            text: 'của bạn đang sử dụng dịch vụ ',
                            style: _baseStyle,
                          ),
                          TextSpan(text: service.name, style: _redStyle),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Mô tả sự cố: $desc',
                      style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                    ),
                    SizedBox(height: 40.h),

                    // Container chi phí tạm tính
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
                          Text(
                            'Chi phí tạm tính',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.primaryColor,
                            ),
                          ),
                          SizedBox(height: 10.h),

                          // Dòng dịch vụ chính
                          Text(
                            'Dịch vụ: ${service.name}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          // Bạn có thể tuỳ ý thêm breakdown chi tiết sau:
                          Text(
                            'Giá cơ bản: ${service.basePrice.toStringAsFixed(0)} VND',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          // Bạn có thể tuỳ ý thêm breakdown chi tiết sau:
                          Text(
                            'Chi phí sửa 100.000 VND',
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
                                'Tổng cộng:',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.primaryColor,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${totalPrice.toStringAsFixed(0)} VND',
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

                    const Spacer(),
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
                        const Spacer(),
                        // Nút Gọi ngay (Rescue)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryColor,
                          ),
                          onPressed: _isCallingRescue ? null : _callRescue,
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
