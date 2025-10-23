import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/common/app_button.dart';

import 'package:mobile/config/assets/app_icon.dart';
import 'package:mobile/config/assets/app_image.dart';
import 'package:mobile/config/api_config.dart';

import 'package:mobile/presentation/controller/user_controller.dart';
import 'package:mobile/presentation/widgets/appbars/main_app_bar.dart';

import 'package:mobile/data/model/vietnam_address.dart';

// Google Maps widget bạn đã chuyển sang (MapRouteBox dùng Google Maps)
import 'package:mobile/presentation/view/loction/map_screen.dart';
import 'package:mobile/presentation/widgets/modal/showModalBottomSheet.dart';

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
  String _street = '';

  String _location = 'Q12, TP.HCM';

  final _searchCtl = TextEditingController();

  // Địa chỉ hiển thị dưới ô tìm kiếm
  String _selectedAddress = '';

  // Điểm đến cho bản đồ
  LatLng _destination = const LatLng(10.8232704, 106.6631168);

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  Future<void> _initControllers() async {
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
    super.dispose();
  }

  /// Khi chọn một địa chỉ trong popup gợi ý:
  // Future<void> _onAddressSelected(VietnamAddress? address) async {
  //   if (address == null) return;

  //   setState(() {
  //     _selectedAddress = address.name; // hiển thị dưới ô tìm kiếm
  //   });

  //   // Loading nho nhỏ khi geocode
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) => const Center(child: CircularProgressIndicator()),
  //   );

  //   try {
  //     // Geocode ra tọa độ
  //     final coordinates = await GeocodingApi.geocodeAddress(address.name);

  //     if (coordinates != null) {
  //       setState(() {
  //         _destination = coordinates; // cập nhật điểm đến
  //         _location = address.name; // cập nhật label trên AppBar (tuỳ ý)
  //       });
  //     } else {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Không tìm thấy tọa độ cho "${address.name}"'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Lỗi khi tìm kiếm địa chỉ: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) Navigator.of(context).pop(); // tắt loading
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      onStreetChanged: (t) => _street = t, // ⬅️ nhận text
                      initialProvince:
                          null, // nếu có, truyền VietnamAddress của tỉnh ban đầu
                      initialDistrict:
                          null, // nếu có, truyền VietnamAddress của quận ban đầu
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

                    // AddressSearchField(
                    //   hintText: 'Nhập tỉnh/quận/phường...',
                    //   onAddressSelected: _onAddressSelected, // <-- GẮN HÀM Ở ĐÂY
                    // ),
                  ),
                  const SizedBox(width: 12),
                  // SizedBox(
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       debugPrint('P: ${_p?.name} (${_p?.code})');
                  //       debugPrint('D: ${_d?.name} (${_d?.code})');
                  //       debugPrint('W: ${_w?.name} (${_w?.code})');
                  //       if (_p == null || _d == null || _w == null) {
                  //         print('hãy điền đủ thông tin');
                  //       }
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: const Color(0xffF3F8FB),
                  //       foregroundColor: Colors.white,
                  //       side: BorderSide(color: AppColor.primaryColor),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       minimumSize: const Size(48, 48),
                  //       padding: EdgeInsets.zero,
                  //     ),
                  //     child: Icon(
                  //       Icons.location_on,
                  //       color: Colors.black,
                  //       size: 16.w,
                  //     ),
                  //   ),
                  // ),
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

              // BOX bản đồ dùng Google Maps (MapRouteBox bạn đã chuyển)
              MapRouteBox(
                key: ValueKey(
                  _destination.toString(),
                ), // force rebuild khi đổi dest
                dest: _destination,
                apiKey: ApiConfig.googleMapsApiKey,
                height: 250.h,
                onError: (err) => debugPrint('Map error: $err'),
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
                        debugPrint('S: ${_street.trim()}');
                        if (_p == null ||
                            _d == null ||
                            _w == null ||
                            _street.trim().isEmpty) {
                          print('hãy điền đủ thông tin');
                          return;
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
