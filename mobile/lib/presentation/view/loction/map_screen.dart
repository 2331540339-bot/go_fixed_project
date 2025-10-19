import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/config/api_config.dart';

class MapRouteBox extends StatefulWidget {
  const MapRouteBox({
    super.key,
    required this.dest,
    required this.apiKey,           // 🔑 Google Maps API key
    this.height = 260,
    this.borderRadius = 16,
    this.onError,
    this.routeColor = Colors.blueAccent,
    this.routeWidth = 4.0,
    this.showUserMarker = true,
    this.showDestMarker = true,
    this.padding = const EdgeInsets.all(12),
  });

  final LatLng dest;
  final String apiKey;
  final double height;
  final double borderRadius;
  final void Function(String error)? onError;
  final Color routeColor;
  final double routeWidth;
  final bool showUserMarker;
  final bool showDestMarker;
  final EdgeInsets padding;

  @override
  State<MapRouteBox> createState() => _MapRouteBoxState();
}

class _MapRouteBoxState extends State<MapRouteBox> {
  final _mapController = MapController();
  LatLng? _origin;
  List<LatLng> _route = [];
  bool _loading = true;
  String? _error;
  bool _apiKeyInvalid = false;

  @override
  void initState() {
    super.initState();
    _initRoute();
  }

  Future<void> _initRoute() async {
    try {
      // 0) Kiểm tra API key
      if (widget.apiKey.isEmpty || widget.apiKey.length < 10) {
        throw 'API key không hợp lệ. Vui lòng kiểm tra lại Google Maps API key.';
      }
      
      // Kiểm tra Google Maps API key format
      if (!widget.apiKey.startsWith('AIza')) {
        throw 'API key có format không đúng. Google Maps API key bắt đầu bằng "AIza". Vui lòng lấy API key thật từ https://console.cloud.google.com/';
      }
      
      // 1) Quyền vị trí
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw 'Location permission denied';
      }

      // 2) Vị trí hiện tại
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: ApiConfig.locationTimeout,
      );
      final origin = LatLng(pos.latitude, pos.longitude);
      debugPrint('Current location: $origin');

      // 3) Gọi Google Maps Directions API
      final params = {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${widget.dest.latitude},${widget.dest.longitude}',
        'key': widget.apiKey,
        'mode': 'driving',
        'units': 'metric',
      };
      
      final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', params);
      
      debugPrint('Requesting route from $origin to ${widget.dest}');
      debugPrint('API Key: ${widget.apiKey.substring(0, 8)}...');
      debugPrint('Full URL: $uri');

      final res = await http.get(
        uri,
        headers: {
          'User-Agent': 'Flutter App',
          'Accept': 'application/json',
        },
      ).timeout(
        ApiConfig.apiTimeout,
        onTimeout: () {
          throw 'Request timeout - API không phản hồi trong ${ApiConfig.apiTimeout.inSeconds} giây';
        },
      );

      if (res.statusCode != 200) {
        final errorBody = res.body;
        debugPrint('API Error: ${res.statusCode} - $errorBody');
        
        // Nếu API key không hợp lệ, hiển thị map không có route
        if (res.statusCode == 401 || res.statusCode == 403) {
          debugPrint('API key không hợp lệ, hiển thị map không có route');
          if (!mounted) return;
          setState(() {
            _origin = origin;
            _route = []; // Không có route
            _loading = false;
            _error = null; // Không hiển thị error, chỉ hiển thị map
            _apiKeyInvalid = true; // Đánh dấu API key không hợp lệ
          });
          
          // Fit camera để hiển thị cả origin và destination
          final bounds = LatLngBounds.fromPoints([origin, widget.dest]);
          _mapController.fitCamera(
            CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(32)),
          );
          return;
        }
        
        throw 'Route failed: ${res.statusCode} ${res.reasonPhrase}\nResponse: $errorBody';
      }

      final json = jsonDecode(res.body);
      
      // Kiểm tra status của Google Maps API
      if (json['status'] != 'OK') {
        throw 'Google Maps API Error: ${json['status']} - ${json['error_message'] ?? 'Unknown error'}';
      }
      
      // Lấy route từ Google Maps response
      final routes = json['routes'] as List;
      if (routes.isEmpty) {
        throw 'Không tìm thấy route từ vị trí hiện tại đến điểm đến';
      }
      
      final route = routes[0];
      final legs = route['legs'] as List;
      if (legs.isEmpty) {
        throw 'Không tìm thấy thông tin route';
      }
      
      final leg = legs[0];
      final steps = leg['steps'] as List;
      
      // Decode polyline từ Google Maps
      final polyline = leg['polyline']['points'] as String;
      final decodedPolyline = _decodePolyline(polyline);

      if (!mounted) return;
      setState(() {
        _origin = origin;
        _route = decodedPolyline;
        _loading = false;
        _error = null;
        _apiKeyInvalid = false;
      });

      // 4) Fit camera (nếu có origin)
      final bounds = LatLngBounds.fromPoints([origin, widget.dest]);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(32)),
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('MapRouteBox Error: $e');
      
      // Nếu có lỗi network hoặc API, vẫn hiển thị map không có route
      if (e.toString().contains('ClientException') || 
          e.toString().contains('Failed to fetch') ||
          e.toString().contains('SocketException')) {
        debugPrint('Network error, hiển thị map không có route');
        setState(() {
          _origin = LatLng(10.8232704, 106.6631168); // Fallback location
          _route = []; // Không có route
          _loading = false;
          _error = null; // Không hiển thị error
          _apiKeyInvalid = true; // Đánh dấu có vấn đề
        });
        
        // Fit camera để hiển thị cả origin và destination
        final bounds = LatLngBounds.fromPoints([_origin!, widget.dest]);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(32)),
        );
        return;
      }
      
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      widget.onError?.call(e.toString());
    }
  }

  // Decode Google Maps polyline
  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < polyline.length) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    final center = _origin ?? widget.dest;

    return Container(
      height: widget.height,
      margin: widget.padding,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _ErrorOverlay(
                      message: _error!,
                      onRetry: () {
                        setState(() {
                          _loading = true;
                          _error = null;
                          _route = [];
                        });
                        _initRoute();
                      },
                    )
                  : FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 14,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.app',
                        ),
                        if ((_origin != null && widget.showUserMarker) ||
                            widget.showDestMarker)
                          MarkerLayer(
                            markers: [
                              if (_origin != null && widget.showUserMarker)
                                Marker(
                                  point: _origin!,
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.topCenter,
                                  child: const Icon(
                                    Icons.my_location,
                                    color: Colors.blue,
                                  ),
                                ),
                              if (widget.showDestMarker)
                                Marker(
                                  point: widget.dest,
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.topCenter,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                        if (_route.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _route,
                                strokeWidth: widget.routeWidth,
                                color: widget.routeColor,
                              ),
                            ],
                          ),
                      ],
                    ),
          // Thông báo API key không hợp lệ
          if (_apiKeyInvalid)
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Không thể kết nối Google Maps API. Map hiển thị không có route.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _apiKeyInvalid = false;
                        });
                      },
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isApiKeyError = message.contains('API key');
    
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isApiKeyError ? Icons.key_off : Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
                if (isApiKeyError) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Để lấy Google Maps API key miễn phí:\nhttps://console.cloud.google.com/',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ),
      ],
    );
  }
}