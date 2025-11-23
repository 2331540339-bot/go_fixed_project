import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/config/api_config.dart';
import 'package:mobile/config/assets/app_icon.dart';
import 'package:mobile/config/assets/app_image.dart';
import 'package:mobile/config/themes/app_color.dart';
import 'package:mobile/data/remote/geocoding_api.dart';
import 'package:mobile/presentation/controller/rescue_flow_controller.dart';
import 'package:mobile/presentation/controller/user_controller.dart';
import 'package:mobile/presentation/services/socket_service.dart';
import 'package:mobile/presentation/view/loction/map_screen.dart';
import 'package:mobile/presentation/view/main_screen.dart';
import 'package:mobile/presentation/widgets/appbars/main_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/presentation/widgets/modal/showModalCenterSheet.dart';
import 'package:provider/provider.dart';

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
  LatLng? _currentLocation; // Vị trí tọa độ hiện tại (tùy chọn)
  String _currentAddress =
      'Đang tải vị trí...'; // Địa chỉ để hiển thị trên AppBar
  bool _loadingLocation = true; 

  StreamSubscription<Position>? _positionStreamSubscription;
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _initControllers();
    _startLocationStream();
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
    _initSocket();
  }

  Future<void> _initSocket() async {
    final uid = _userCtrl?.userRepository.userId;
    if (uid == null || uid.isEmpty) {
      debugPrint('SearchMechanic: userId rỗng, không thể đăng ký socket.');
      return;
    }
    _socketService.initializeSocket(
      uid,
      isMechanic: false,
      context: context,
    );
    _socketService.onAcceptedStatusRescue = (data) {
      final msg = data['message'] ?? 'Yêu cầu cứu hộ đã được cập nhật';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.toString())),
      );
    };
  }

  Future<void> _startLocationStream() async {
    // 1. Kiểm tra quyền và dịch vụ (Giữ nguyên logic từ trước)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _currentAddress = 'Vị trí bị tắt');
      return Future.error('Dịch vụ Vị trí đã bị tắt.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _currentAddress = 'Từ chối truy cập');
        return Future.error('Quyền truy cập vị trí đã bị từ chối.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _currentAddress = 'Bị từ chối vĩnh viễn');
      return Future.error('Quyền bị từ chối vĩnh viễn.');
    }

    // 2. Định cấu hình Stream
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50, // Cập nhật khi di chuyển 50 mét
    );

    // Hủy Stream cũ nếu có
    _positionStreamSubscription?.cancel();

    // Lấy vị trí ban đầu
    try {
      Position initialPosition = await Geolocator.getCurrentPosition();
      await _updateLocation(initialPosition);
    } catch (e) {
      if (mounted)
        setState(() {
          _currentAddress = 'Không lấy được vị trí ban đầu';
          _loadingLocation = false;
        });
    }

    // 3. Bắt đầu lắng nghe Stream
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            _updateLocation(position); // Gọi hàm cập nhật vị trí và địa chỉ
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _currentAddress = 'Lỗi theo dõi vị trí';
                _loadingLocation = false;
              });
            }
            debugPrint('Lỗi theo dõi vị trí: $error');
          },
        );
  }

  // Hàm mới để xử lý cập nhật vị trí và chuyển đổi sang địa chỉ
  Future<void> _updateLocation(Position position) async {
    final location = LatLng(position.latitude, position.longitude);

    // Tạm thời đặt cờ loading là true khi đang chờ chuyển đổi
    if (mounted) {
      setState(() {
        _currentLocation = location;
        _loadingLocation = true;
      });
    }

    final address = await GeocodingApi.reverseGeocode(location);

    if (mounted) {
      setState(() {
        _currentAddress = address ?? 'Không xác định được địa chỉ';
        _loadingLocation = false;
      });
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RescueFlowController>();
    final LatLng? finalOrigin = controller.latLngLocation;

    return Scaffold(
      appBar: MainAppBar(
        logo: Image.asset(AppImages.mainLogo, height: 100.h, width: 100.w),
        name: _name,
        avatarWidget: SvgPicture.asset(AppIcon.user),
        onAvatarTap: () {
          debugPrint('Avatar tapped');
        },
        location: _loadingLocation ? 'Đang tải...' : _currentAddress,
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
                initialOrigin: finalOrigin,
                dest: _selectedDestination,
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
              ),

              // Thêm các widget khác để hiển thị kết quả tìm kiếm
            ],
          ),
        ),
      ),
    );
  }
}
