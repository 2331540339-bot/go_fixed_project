import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mechanic/config/api_config.dart';
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
  @override
  void initState() {
    super.initState();
    _socketService.initializeSocket(widget.mechanicId, isMechanic: true);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trạng thái: ${_socketService.isConnected ? 'Online' : 'Offline'}',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: MapRouteBox(
            dest: _customerDest,
            apiKey: ApiConfig.goongMapsApiKey,
            showDestMarker: _customerDest != null,
          ),
        ),
      ),
    );
  }
}
