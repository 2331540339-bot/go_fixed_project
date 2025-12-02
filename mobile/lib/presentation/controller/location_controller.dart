import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/api/geocoding_api.dart';

class LocationController extends ChangeNotifier {
  LatLng? _currentLocation;
  String _currentAddress = 'Đang tải vị trí...';
  bool _loading = false;
  String? _error;

  StreamSubscription<Position>? _positionStreamSubscription;
  bool _started = false;
  bool _starting = false;

  LatLng? get currentLocation => _currentLocation;
  String get currentAddress => _currentAddress;
  bool get loading => _loading;
  String? get error => _error;

  /// Đảm bảo chỉ khởi động stream một lần.
  Future<void> ensureStarted() async {
    if (_started || _starting) return;
    _starting = true;
    await _startLocationStream();
    _starting = false;
    _started = _error == null;
  }

  Future<void> refresh() async {
    _started = false;
    await ensureStarted();
  }

  Future<void> _startLocationStream() async {
    _setLoading(true);
    _error = null;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setError('Vị trí bị tắt');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _setError('Không có quyền truy cập vị trí');
      return;
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50,
    );

    await _positionStreamSubscription?.cancel();

    try {
      final initialPosition = await Geolocator.getCurrentPosition();
      await _updateLocation(initialPosition);
    } catch (_) {
      _setError('Không lấy được vị trí ban đầu');
      return;
    }

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (position) => _updateLocation(position),
      onError: (_) => _setError('Lỗi theo dõi vị trí'),
    );
  }

  Future<void> _updateLocation(Position position) async {
    _currentLocation = LatLng(position.latitude, position.longitude);
    _setLoading(true);

    final address = await GeocodingApi.reverseGeocode(_currentLocation!);
    _currentAddress = address ?? 'Không xác định được địa chỉ';

    _setLoading(false);
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}
