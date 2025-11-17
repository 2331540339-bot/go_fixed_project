import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/config/assets/app_image.dart';
import 'package:mobile/data/remote/geocoding_api.dart';
import 'package:mobile/presentation/controller/user_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  XFile? _imageFile;
  UserController? _userCtrl;
  String _name = '...';
  bool _loadingName = true;
  String _email = '...';
  String _phone = '...';
  String _address = '...';

  LatLng? _currentLocation; // Vị trí tọa độ hiện tại (tùy chọn)
  String _currentAddress =
      'Đang tải vị trí...'; // Địa chỉ để hiển thị trên AppBar
  bool _loadingLocation = true; // Cờ để hiển thị loading

  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _startLocationStream();
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
        _email = n.email;
        _phone = n.phone;
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
        _email = 'Chưa đăng nhập';
        _phone = 'Chưa đăng nhập';
        // _address = 'Chưa đăng nhập';
        _loadingName = false;
      });
    }
  }

  Future<void> _openGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: InkWell(
                onTap: () {
                  debugPrint('Avatar tapped');
                  _openGallery();
                },
                child: CircleAvatar(
                  radius: 100,

                  backgroundImage: _imageFile != null
                      ? FileImage(File(_imageFile!.path)) as ImageProvider
                      : AssetImage(AppImages.avt_con_meo),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      debugPrint('Name tapped');
                    },
                    child: Text(
                      'Name: $_name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      debugPrint('Email tapped');
                    },
                    child: Text(
                      'Email: $_email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      debugPrint('Phone tapped');
                    },
                    child: Text(
                      'Phone: $_phone',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Address: ${_loadingLocation ? 'Đang tải...' : _currentAddress}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
