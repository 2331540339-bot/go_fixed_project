import 'dart:async';

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
import 'package:mobile/api/geocoding_api.dart';

import 'package:mobile/presentation/controller/user_controller.dart';
import 'package:mobile/presentation/controller/location_controller.dart';
import 'package:mobile/presentation/view/loction/open_map.dart';
import 'package:mobile/presentation/view/loction/services_page.dart';
import 'package:mobile/presentation/widgets/appbars/main_app_bar.dart';

import 'package:mobile/presentation/model/vietnam_address.dart';

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

  final _searchCtl = TextEditingController();
  final String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
    context.read<LocationController>().ensureStarted();
    _initControllers();
  }

  void _centerOnUserMarker({double zoom = 30}) {
    if (_userMarker == null) return;
    if (_mapReady) {
      _mapController.move(_userMarker!, zoom); // DI CHUYỂN MAP
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
    // Sử dụng 'name' của address model nếu không null
    if (_w?.name != null && _w!.name!.trim().isNotEmpty)
      parts.add(_w!.name!.trim());
    if (_d?.name != null && _d!.name!.trim().isNotEmpty)
      parts.add(_d!.name!.trim());
    if (_p?.name != null && _p!.name!.trim().isNotEmpty)
      parts.add(_p!.name!.trim());

    // Thêm quốc gia để Goong “chắc cú”
    parts.add('Việt Nam');

    // SnackBar này là để debug, có thể bỏ
    /*
    final snackBar = SnackBar(
      content: Text('Địa chỉ đã chọn: ${parts.join(', ')}'),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    */

    return parts.join(', ');
  }

  // Hàm Geocode độc lập, chỉ trả về LatLng
  Future<LatLng?> _getGeocodedLatLng(String address) async {
    try {
      final latlng = await GeocodingApi.geocodeAddress(address);
      if (latlng == null) {
        debugPrint('Không tìm thấy toạ độ cho: $address');
      }
      return latlng;
    } catch (e) {
      debugPrint('Lỗi geocoding cho $address: $e');
      return null;
    }
  }

  // Gọi Goong Geocoding rồi cập nhật map + marker (Được giữ nguyên cho mục đích hiển thị map)
  Future<void> _geocodeSelectedAddressAndRefreshMap() async {
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

    final latlng = await _getGeocodedLatLng(full);

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
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        // Đặt thời gian hiển thị mong muốn
        duration: const Duration(seconds: 3),
        // Tùy chọn: Thêm hành động (Action)
        action: SnackBarAction(
          label: 'Đóng',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationCtrl = context.watch<LocationController>();
    final currentLocation = locationCtrl.currentLocation;
    final currentAddress = locationCtrl.error ?? locationCtrl.currentAddress;
    final loadingLocation = locationCtrl.loading;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MainAppBar(
        logo: Image.asset(AppImages.mainLogo, height: 100.h, width: 100.w),
        name: _name,
        loadingName: _loadingName,
        location: loadingLocation ? 'Đang tải...' : currentAddress,
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
                      onStreetChanged: (t) => _s = t, //  nhận text
                      initialProvince: null,
                      initialDistrict: null,
                      initialWard: null,
                      onProvinceSelected: (p) {
                        debugPrint('Province: ${p?.name} (${p?.code})');
                        setState(() {
                          _p = p;
                          _d = null; // Reset District
                          _w = null; // Reset Ward
                        });
                      },
                      onDistrictSelected: (d) {
                        debugPrint('District: ${d?.name} (${d?.code})');
                        setState(() {
                          _d = d;
                          _w = null; // Reset Ward
                        });
                      },
                      onWardSelected: (w) {
                        debugPrint('Ward ${w?.name} (${w?.code})');
                        setState(() {
                          _w = w;
                        });
                      },
                      // Kích hoạt Geocode khi người dùng đóng modal (hoặc một hành động phù hợp)
                      // onClosed: _geocodeSelectedAddressAndRefreshMap,
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
                          // Nếu có _userMarker (đã Geocode thành công) thì ưu tiên hiển thị
                          _userMarker != null
                              ? _buildFullAddress()
                              : 'Địa chỉ đã chọn: $_selectedAddress',
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
              // Map chỉ hiển thị marker
              MapOnlyBox(
                center: _mapCenter,
                userPosition: _userMarker, // Sử dụng _userMarker
                mapTilerKey: ApiConfig.goongMaptilesApiKey,
                zoom: 16,
              ),

              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: AppButton(
                      content: 'Xác nhận vị trí',
                      // Chuyển sang async để chờ Geocode (nếu cần)
                      onPressed: () async {
                        // 🛠️ Khởi tạo biến để lưu trữ dữ liệu cuối cùng
                        String finalDetailAddress = '';
                        LatLng? finalLocationLatLng;

                        final bool isManualAddressComplete =
                            (_p != null &&
                            _d != null &&
                            _w != null &&
                            _s.trim().isNotEmpty);

                        if (isManualAddressComplete) {
                          // Trường hợp 1: Có địa chỉ thủ công
                          finalDetailAddress = _buildFullAddress();

                          // Tạm thời hiển thị loading cho người dùng
                          setState(() => _loadingName = true);

                          // Gọi Geocode để lấy tọa độ (không cập nhật Map)
                          finalLocationLatLng = await _getGeocodedLatLng(
                            finalDetailAddress,
                          );

                          setState(() => _loadingName = false);

                          if (finalLocationLatLng == null) {
                            _showSnackbar(
                              context,
                              'Không tìm thấy tọa độ cho địa chỉ đã nhập. Vui lòng kiểm tra lại.',
                            );
                            return;
                          }
                          debugPrint(
                            'Sử dụng địa chỉ thủ công: $finalDetailAddress, LatLng: $finalLocationLatLng',
                          );
                        } else if (currentLocation != null &&
                            currentAddress != 'Đang tải vị trí...') {
                          // Trường hợp 2: Dùng vị trí hiện tại (Đã có tọa độ và địa chỉ)
                          finalDetailAddress = currentAddress;
                          finalLocationLatLng = currentLocation;
                          debugPrint(
                            'Sử dụng vị trí hiện tại: $finalDetailAddress, LatLng: $finalLocationLatLng',
                          );
                        } else {
                          // Trường hợp 3: Vị trí hiện tại cũng không có
                          _showSnackbar(
                            context,
                            'Vui lòng chọn địa chỉ hoặc chờ tải vị trí hiện tại.',
                          );
                          return; // Dừng lại
                        }

                        //  Kiểm tra cuối cùng trước khi lưu và chuyển trang
                        if (finalLocationLatLng == null ||
                            finalDetailAddress.isEmpty) {
                          _showSnackbar(
                            context,
                            'Lỗi: Không xác định được tọa độ hoặc địa chỉ.',
                          );
                          return;
                        }

                        //  BƯỚC QUAN TRỌNG: Lưu dữ liệu vào RescueFlowController
                        final controller = context.read<RescueFlowController>();

                        // Lưu địa chỉ chi tiết
                        controller.setDetailAddress(finalDetailAddress);

                        // Lưu tọa độ dưới dạng Map<String, dynamic>
                        controller.setLocation({
                          'lat': finalLocationLatLng.latitude,
                          'lng': finalLocationLatLng.longitude,
                          // Bạn có thể lưu thêm 'address' ở đây nếu muốn
                        });

                        // Chuyển trang
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ServicesPage(),
                          ),
                        );
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
