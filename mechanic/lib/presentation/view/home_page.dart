import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mechanic/config/api_config.dart';
import 'package:mechanic/config/themes/app_color.dart';
import 'package:mechanic/presentation/services/socket_service.dart';
import 'package:mechanic/presentation/view/map_screen.dart';
import 'package:mechanic/presentation/widgets/modal/showModalCenterSheet.dart';

class HomePage extends StatefulWidget {
  final String mechanicId;
  const HomePage({super.key, required this.mechanicId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SocketService _socketService = SocketService();

  LatLng? _customerDest;
  StreamSubscription<Position>? _positionStreamSubscription;
  void _handleSocketChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _socketService.initializeSocket(widget.mechanicId, isMechanic: true);
    _socketService.addListener(_handleSocketChange);
    _socketService.onIncomingRescueRequest = (data) {
      if (!mounted) return;
      showModalConfirm(
        context,
        message: 'Bạn có muốn nhận yêu cầu cứu hộ này không?',
        onConfirm: () {
          // Gửi sự kiện chấp nhận yêu cầu cứu hộ đến server
          _socketService.socket.emit('accept_rescue_request', {
            'mechanicId': widget.mechanicId,
            'requestId': data['_id'],
          });
          final dest = _parseCustomerLatLng(data['location']);
          if (dest != null) {
            setState(() => _customerDest = dest);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không tìm được tọa độ khách, chỉ hiển thị vị trí của bạn.'),
              ),
            );
          }
        },
      );
    };
    _determinePosition();
  }

  @override
  void dispose() {
    _socketService.disconnect();
    _socketService.removeListener(_handleSocketChange);
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Dịch vụ Vị trí đã bị tắt.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Quyền truy cập vị trí đã bị từ chối.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Quyền bị từ chối vĩnh viễn. Vui lòng vào Cài đặt để bật.',
      );
    }
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Cập nhật vị trí khi người dùng di chuyển 10 mét
      // intervalDuration: Duration(seconds: 5), // Có thể thêm khoảng thời gian
    );
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            // Theo dõi vị trí hiện tại để phục vụ định tuyến, MapRouteBox sẽ tự lấy.
            debugPrint('Vị trí mới: ${position.latitude}, ${position.longitude}');
          },
          onError: (error) {
            // Xử lý lỗi trong quá trình theo dõi vị trí
            print('Lỗi theo dõi vị trí: $error');
          },
        );

    Position position = await Geolocator.getCurrentPosition();
    print('Vị trí hiện tại: $position');
  }

  LatLng? _parseCustomerLatLng(dynamic location) {
    if (location == null) return null;
    try {
      if (location is Map) {
        // Backend lưu GeoJSON: {type: "Point", coordinates: [lng, lat]}
        final coords = location['coordinates'];
        if (coords is List && coords.length >= 2) {
          final lng = coords[0];
          final lat = coords[1];
          if (lng is num && lat is num) {
            return LatLng(lat.toDouble(), lng.toDouble());
          }
        }
        // Fallback nếu backend trả {lat, lng}
        final lat = location['lat'] ?? location['latitude'];
        final lng = location['lng'] ?? location['longitude'];
        if (lat is num && lng is num) {
          return LatLng(lat.toDouble(), lng.toDouble());
        }
      }
    } catch (_) {
      // Bỏ qua và trả null
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = _socketService.isConnected;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: isOnline ? Colors.greenAccent : Colors.orangeAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isOnline ? Colors.green : Colors.orange).withOpacity(.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isOnline ? 'Đang trực tuyến' : 'Đang chờ kết nối',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refreshLocation,
            icon: const Icon(Icons.gps_fixed, color: Colors.black87),
            tooltip: 'Làm mới vị trí',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.primaryColor.withOpacity(.08), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.ev_station_rounded,
                          color: AppColor.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sẵn sàng nhận cứu hộ',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _customerDest != null
                                  ? 'Có yêu cầu đang chờ định tuyến'
                                  : 'Chưa có yêu cầu mới',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black54,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isOnline ? Colors.green.shade200 : Colors.orange.shade200,
                          ),
                        ),
                        child: Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: isOnline ? Colors.green.shade800 : Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Điểm đến hiện tại',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.black54)),
                            const SizedBox(height: 8),
                            Text(
                              _customerDest != null
                                  ? 'Lat: ${_customerDest!.latitude.toStringAsFixed(5)}\nLng: ${_customerDest!.longitude.toStringAsFixed(5)}'
                                  : 'Chưa có',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColor.primaryColor.withOpacity(.12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mẹo nhanh',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.black54)),
                            const SizedBox(height: 8),
                            Text(
                              'Giữ ứng dụng mở để nhận yêu cầu.\nĐảm bảo bật GPS độ chính xác cao.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bản đồ định tuyến',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            if (_customerDest != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Có điểm đến',
                                  style: TextStyle(
                                    color: AppColor.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 380,
                          color: Colors.grey.shade100,
                          child: MapRouteBox(
                            dest: _customerDest,
                            apiKey: ApiConfig.goongMapsApiKey,
                            showDestMarker: _customerDest != null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _refreshLocation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.gps_fixed_rounded),
                                label: const Text('Làm mới vị trí'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Giữ ứng dụng mở để tiếp tục nhận yêu cầu.'),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColor.primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: Icon(Icons.notifications_active_outlined,
                                    color: AppColor.primaryColor),
                                label: Text(
                                  'Thông báo',
                                  style: TextStyle(color: AppColor.primaryColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshLocation() async {
    try {
      await _determinePosition();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật vị trí')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể cập nhật vị trí: $e')),
      );
    }
  }
}
