import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mechanic/config/api_config.dart';
import 'package:mechanic/presentation/services/socket_service.dart';
import 'package:mechanic/presentation/view/map_screen.dart';
import 'package:mechanic/presentation/view/open_map.dart';

class HomePage extends StatefulWidget {
  final String mechanicId;
  const HomePage({super.key, required this.mechanicId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng _mapCenter = LatLng(10.82327, 106.66312);
  final SocketService _socketService = SocketService();

  StreamSubscription<Position>? _positionStreamSubscription;
  @override
  void initState() {
    super.initState();
    _socketService.initializeSocket(widget.mechanicId, isMechanic: true);
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
            // 3. Cập nhật trạng thái _mapCenter
            setState(() {
              _mapCenter = LatLng(position.latitude, position.longitude);
              print('Vị trí mới: $_mapCenter');
            });
          },
          onError: (error) {
            // Xử lý lỗi trong quá trình theo dõi vị trí
            print('Lỗi theo dõi vị trí: $error');
          },
        );

    Position position = await Geolocator.getCurrentPosition();
    print('Vị trí hiện tại: $position');
    Position initialPosition = await Geolocator.getCurrentPosition();
    setState(() {
      _mapCenter = LatLng(initialPosition.latitude, initialPosition.longitude);
    });
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
            dest: _mapCenter,
            apiKey: ApiConfig.goongMapsApiKey,
            showDestMarker: false,
          ),
        ),
      ),
    );
  }
}
