import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_screenutil/flutter_screenutil.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/common/app_button.dart';

import 'package:mobile/config/assets/app_icon.dart';
import 'package:mobile/config/assets/app_image.dart';
import 'package:mobile/config/api_config.dart';
import 'package:mobile/data/remote/geocoding_api.dart';

import 'package:mobile/presentation/controller/user_controller.dart';
import 'package:mobile/presentation/view/loction/detailed_repair_page.dart';
import 'package:mobile/presentation/view/loction/open_map.dart';
import 'package:mobile/presentation/view/loction/services_page.dart';
// import 'package:mobile/presentation/view/loction/services_page.dart';
import 'package:mobile/presentation/widgets/appbars/main_app_bar.dart';

import 'package:mobile/data/model/vietnam_address.dart';

// Google Maps widget bạn đã chuyển sang (MapRouteBox dùng Google Maps)
import 'package:mobile/presentation/widgets/modal/showModalBottomSheet.dart';

import 'package:provider/provider.dart';
import 'package:mobile/presentation/controller/rescue_flow_controller.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  UserController? _userCtrl;
  String _name = '...';
  bool _loadingName = true;
  VietnamAddress? _p; // province
  VietnamAddress? _d; // district
  VietnamAddress? _w; // ward
  String _s = '';
  final _mapController = MapController();
  final bool _mapReady = false;

  LatLng _mapCenter = const LatLng(10.82327, 106.66312);
  LatLng? _userMarker;

  final String _location = 'Q12, TP.HCM';

  final _searchCtl = TextEditingController();

  // Địa chỉ hiển thị dưới ô tìm kiếm
  final String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _centerOnUserMarker({double zoom = 30}) {
    if (_userMarker == null) return;
    if (_mapReady) {
      _mapController.move(_userMarker!, zoom); // 👈 DI CHUYỂN MAP
    } else {
      // nếu muốn, bạn có thể lưu "pending" để gọi sau khi map ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_mapReady) _mapController.move(_userMarker!, zoom);
      });
    }
  }

  Future<void> _initControllers() async {
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
  }

  // Ghép địa chỉ từ các lựa chọn + ô đường (street)
  String _buildFullAddress() {
    final parts = <String>[];
    // _s: tên đường / số nhà (người dùng gõ)
    final street = _s.trim();
    if (street.isNotEmpty) parts.add(street);

    // _w, _d, _p: ward/district/province (VietnamAddress?)
    if (_w?.name != null && _w!.name!.trim().isNotEmpty)
      parts.add(_w!.name!.trim());
    if (_d?.name != null && _d!.name!.trim().isNotEmpty)
      parts.add(_d!.name!.trim());
    if (_p?.name != null && _p!.name!.trim().isNotEmpty)
      parts.add(_p!.name!.trim());

    // Thêm quốc gia để Goong “chắc cú”
    parts.add('Việt Nam');
    final snackBar = SnackBar(
      content: Text('Địa chỉ đã chọn: ${parts.join(', ')}'),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    return parts.join(', ');
  }

  // Gọi Goong Geocoding rồi cập nhật map + marker
  Future<void> _geocodeSelectedAddress() async {
    // Kiểm tra đầu vào tối thiểu
    if (_p == null || _d == null || _w == null || _s.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đủ: Đường/SN + Phường + Quận + Tỉnh'),
        ),
      );
      return;
    }

    final full = _buildFullAddress();
    debugPrint('➡️ Geocoding: $full');

    setState(() => _loadingName = true); // tái dụng biến loading sẵn có

    try {
      final latlng = await GeocodingApi.geocodeAddress(full);
      if (!mounted) return;

      if (latlng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy toạ độ cho: $full')),
        );
        setState(() => _loadingName = false);
        return;
      }

      // Cập nhật tâm map + marker người dùng
      setState(() {
        _mapCenter = latlng;
        _userMarker = latlng;
        _loadingName = false;
      });
      _centerOnUserMarker(); // 👈 DI CHUYỂN MAP VỀ MARKER
      debugPrint('✅ Geocoded: ${latlng.latitude}, ${latlng.longitude}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingName = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi geocoding: $e')));
    }
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MainAppBar(
        logo: Image.asset(AppImages.mainLogo, height: 100.h, width: 100.w),
        name: _name,
        loadingName: _loadingName,
        location: _location,
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
              // Ô tìm kiếm + nút bên phải
              Row(
                children: [
                  Expanded(
                    child: Showmodalbottomsheet(
                      onStreetChanged: (t) => _s = t, // ⬅️ nhận text
                      initialProvince: null,
                      initialDistrict: null,
                      initialWard: null,
                      onProvinceSelected: (p) {
                        debugPrint('Province: ${p?.name} (${p?.code})');
                        setState(() {
                          _p = p;
                        });
                      },
                      onDistrictSelected: (d) {
                        debugPrint('District: ${d?.name} (${d?.code})');
                        setState(() {
                          _d = d;
                        });
                      },
                      onWardSelected: (w) {
                        debugPrint('Ward ${w?.name} (${w?.code})');
                        setState(() {
                          _w = w;
                        });
                      },
                    ),
                  ),
                ],
              ),

              if (_selectedAddress.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Địa chỉ đã chọn: $_selectedAddress',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // MapRouteBox(
              //   dest: LatLng(10.7852743, 106.6519676),
              //   apiKey: ApiConfig.goongMapsApiKey,
              //   mapTilerKey: ApiConfig.goongMaptilesApiKey,
              //   vehicle: 'bike',
              // ),
              // const SizedBox(height: 20),
              MapOnlyBox(
                center: _mapCenter,
                userPosition: _userMarker,
                mapTilerKey: ApiConfig.goongMaptilesApiKey,
                zoom: 16,
              ),

              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.only(right: 15),
                    child: AppButton(
                      content: 'Xác nhận vị trí',
                      onPressed: () {
                        debugPrint('P: ${_p?.name} (${_p?.code})');
                        debugPrint('D: ${_d?.name} (${_d?.code})');
                        debugPrint('W: ${_w?.name} (${_w?.code})');
                        debugPrint('S: ${_s.trim()}');
                        if (_p == null ||
                            _d == null ||
                            _w == null ||
                            _s.trim().isEmpty) {
                          print('hãy điền đủ thông tin');
                          return;
                        }
                        _geocodeSelectedAddress();
                        String fullAddress = _buildFullAddress();
                        context.read<RescueFlowController>().setDescription(
                          fullAddress,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServicesPage(),
                          ),
                        );
                        if (fullAddress == '') {
                          print('Vui lòng chọn địa chỉ đầy đủ');
                        } else {
                          print('Địa chỉ đã chọn: ${fullAddress}');
                        }
                      },
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
