import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mechanic/config/api_config.dart';


class MapRouteBox extends StatefulWidget {
  const MapRouteBox({
    
    super.key,
    this.dest,             
    required this.apiKey,   
    this.height = 260,
    this.borderRadius = 16,
    this.onError,
    this.routeColor = Colors.red,
    this.routeWidth = 4.0,
    this.showUserMarker = true,
    this.showDestMarker = true,
    this.padding = const EdgeInsets.all(12),
    this.vehicle = 'bike',           // car | bike | truck | hd | taxi
    this.mapTilerKey,              
  });
  
  final LatLng? dest;
  final String apiKey;
  final double height;
  final double borderRadius;
  final void Function(String error)? onError;
  final Color routeColor;
  final double routeWidth;
  final bool showUserMarker;
  final bool showDestMarker;
  final EdgeInsets padding;
  final String vehicle;
  final String? mapTilerKey;

  @override
  State<MapRouteBox> createState() => _MapRouteBoxState();
}

class _MapRouteBoxState extends State<MapRouteBox> {
  final _mapController = MapController();
  late final String _mapTilerKey =
      widget.mapTilerKey ?? ApiConfig.goongMaptilesApiKey;

  LatLng? _origin;                
  List<LatLng> _route = [];        
  bool _loading = true;
  String? _error;
  bool _apiKeyInvalid = false;

  bool _mapReady = false;
  CameraFit? _pendingFit;
  
  static const LatLng _defaultCenter = LatLng(21.028511, 105.804817); 

  // Giới hạn khoảng cách gọi route (tránh call xuyên lục địa)
  bool _tooFar(LatLng a, LatLng b, {double maxKm = 800}) {
    const d = Distance();
    return d.as(LengthUnit.Kilometer, a, b) > maxKm;
  }

  void _fitBounds(LatLng a, LatLng b) {
    final fit = CameraFit.bounds(
      bounds: LatLngBounds.fromPoints([a, b]),
      padding: const EdgeInsets.all(32),
    );
    if (_mapReady) {
      _mapController.fitCamera(fit);
    } else {
      _pendingFit = fit;
    }
  }

  void _fitToPolyline() {
    if (_route.isEmpty) return;
    final fit = CameraFit.bounds(
      bounds: LatLngBounds.fromPoints(_route),
      padding: const EdgeInsets.all(32),
    );
    if (_mapReady) {
      _mapController.fitCamera(fit);
    } else {
      _pendingFit = fit;
    }
  }
  
  // Hàm set camera về vị trí hiện tại
  void _fitToCurrentLocation(LatLng location) {
    final fit = CameraFit.bounds(
      bounds: LatLngBounds.fromPoints( [location]),
      padding: const EdgeInsets.all(32),
      minZoom: 16.0, // Zoom sát hơn vào vị trí hiện tại
    );
    if (_mapReady) {
      _mapController.fitCamera(fit);
    } else {
      _pendingFit = fit;
    }
  }

  @override
  void initState() {
    super.initState();
    _initRoute();
  }

  Future<void> _initRoute() async {
    try {
      // 1) Quyền vị trí (luôn cần để lấy _origin)
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw 'Location permission denied';
      }

      // 2) Lấy vị trí hiện tại
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: ApiConfig.locationTimeout,
      );
      final current = LatLng(pos.latitude, pos.longitude);
      debugPrint('Current location: $current');

      if (widget.dest == null) {
        setState(() {
          _origin = current;
          _route = [];
          _loading = false;
          _error = null;
        });
      
        _fitToCurrentLocation(current);
        return; 
      }
      
      // 3) Kiểm tra Goong REST key (chỉ khi có dest để gọi Directions)
      if (widget.apiKey.isEmpty || widget.apiKey.length < 10) {
        throw 'Goong API key không hợp lệ. Vui lòng kiểm tra REST API key.';
      }
      
      final dest = widget.dest!; // Dùng ! vì đã kiểm tra null ở trên

      // 4) Nếu khoảng cách quá xa → không gọi Directions, chỉ hiển thị markers
      if (_tooFar(current, dest)) {
        setState(() {
          _origin = current;
          _route = [];
          _loading = false;
          _error = null;
          _apiKeyInvalid = false;
        });
        // Camera: hiển thị cả 2 điểm
        _fitBounds(current, dest);
        return;
      }

      // 5) Gọi Goong Directions API
      final params = {
        'origin': '${current.latitude},${current.longitude}',
        'destination': '${dest.latitude},${dest.longitude}',
        'vehicle': widget.vehicle,
        'api_key': widget.apiKey,
      };
      final uri = Uri.https('rsapi.goong.io', '/Direction', params);

      debugPrint('Requesting route from $current to $dest');
      debugPrint('API Key: ${widget.apiKey.substring(0, 8)}...');
      debugPrint('Full URL: $uri');

      final res = await http
          .get(
            uri,
            headers: {
              'User-Agent': 'Flutter App',
              'Accept': 'application/json',
            },
          )
          .timeout(
            ApiConfig.apiTimeout,
            onTimeout: () => throw 'Request timeout - API không phản hồi trong ${ApiConfig.apiTimeout.inSeconds} giây',
          );

      debugPrint('Goong response: ${res.body}');

      if (res.statusCode != 200) {
        if (res.statusCode == 401 || res.statusCode == 403) {
          setState(() {
            _origin = current;
            _route = [];
            _loading = false;
            _error = null;
            _apiKeyInvalid = true;
          });
          _fitBounds(current, dest);
          return;
        }
        throw 'Route failed: ${res.statusCode} ${res.reasonPhrase}\nResponse: ${res.body}';
      }
      
      final data = jsonDecode(res.body);

      // 6) Bắt lỗi theo format Goong
      if (data is Map && data['error'] != null) {
        final err = data['error'];
        throw 'Goong Directions Error: ${err['code'] ?? 'UNKNOWN'} - ${err['message'] ?? 'Unknown error'}';
      }
      final status = data['status'] as String?;
      if (status != null && status != 'OK') {
        throw 'Goong Directions Error: $status - ${data['error_message'] ?? 'Unknown error'}';
      }

      // 7) Parse routes
      final routes = (data['routes'] as List?) ?? [];
      if (routes.isEmpty) {
        // Không có route → vẫn hiển thị markers
        setState(() {
          _origin = current;
          _route = [];
          _loading = false;
          _error = null;
          _apiKeyInvalid = false;
        });
        _fitBounds(current, dest);
        return;
      }

      // Ưu tiên overview_polyline
      String? encoded =
          routes.first['overview_polyline']?['points'] as String?;
      List<LatLng> decodedPolyline;
      if (encoded != null && encoded.isNotEmpty) {
        decodedPolyline = _decodePolyline(encoded);
      } else {
        // Fallback: ghép từ steps[].polyline.points
        final legs = (routes.first['legs'] as List?) ?? [];
        if (legs.isEmpty) throw 'Không tìm thấy thông tin legs trong route';
        final steps = (legs.first['steps'] as List?) ?? [];
        final pts = <LatLng>[];
        for (final s in steps) {
          final sp = s['polyline']?['points'] as String?;
          if (sp != null && sp.isNotEmpty) {
            pts.addAll(_decodePolyline(sp));
          }
        }
        decodedPolyline = pts;
      }

      // Lấy start/end thật sự của route (để hiển thị hợp lý tại VN)
      final legs = (routes.first['legs'] as List?) ?? [];
      final leg = legs.first;
      final start = leg['start_location'];
      final routeStart = LatLng(
        (start['lat'] as num).toDouble(),
        (start['lng'] as num).toDouble(),
      );

      // 8) Cập nhật state & fit theo polyline
      if (!mounted) return;
      setState(() {
        _origin = routeStart;      // dùng start của route (snap theo Goong)
        _route = decodedPolyline;
        _loading = false;
        _error = null;
        _apiKeyInvalid = false;
      });
      _fitToPolyline();
    } catch (e) {
      if (!mounted) return;
      debugPrint('MapRouteBox Error: $e');

      final msg = e.toString();
      if (msg.contains('ClientException') ||
          msg.contains('Failed to fetch') ||
          msg.contains('SocketException') ||
          msg.contains('HandshakeException')) {
        setState(() {
          _origin = null;
          _route = [];
          _loading = false;
          _error = null;
          _apiKeyInvalid = true;
        });
        // Giữ camera tại đích (nếu có) hoặc mặc định
        if (widget.dest != null) {
          _fitBounds(widget.dest!, widget.dest!);
        }
        return;
      }

      setState(() {
        _error = msg;
        _loading = false;
      });
      widget.onError?.call(msg);
    }
  }

  // Decode polyline kiểu Google/Goong
  List<LatLng> _decodePolyline(String polyline) {
    final points = <LatLng>[];
    int index = 0, lat = 0, lng = 0;

    while (index < polyline.length) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    // Logic hiển thị Map mới
    final initialCenter = widget.dest ?? _origin ?? _defaultCenter;
    final showDest = widget.dest != null && widget.showDestMarker;
    final showUser = _origin != null && widget.showUserMarker;

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
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            _ErrorOverlay(
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
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initialCenter, // Dùng dest, hoặc origin, hoặc default
                initialZoom: 14,
                onMapReady: () {
                  _mapReady = true;
                  if (_pendingFit != null) {
                    _mapController.fitCamera(_pendingFit!);
                    _pendingFit = null;
                  } else if (widget.dest == null && _origin != null) {
                    // Nếu không có dest, nhưng có origin, zoom vào origin khi map sẵn sàng
                    _fitToCurrentLocation(_origin!);
                  }
                },
              ),
              children: [
                
                TileLayer(
                  urlTemplate:
                      'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key={key}',
                  additionalOptions: {'key': _mapTilerKey},
                  userAgentPackageName: 'com.example.app',
                ),

                // Markers 
                if (showUser || showDest)
                  MarkerLayer(
                    markers: [
                    
                      if (showUser)
                        Marker(
                          point: _origin!,
                          width: 40,
                          height: 40,
                          alignment: Alignment.topCenter,
                          child: const Icon(Icons.my_location, color: Colors.blue),
                        ),
                      // Marker điểm đích (widget.dest) - Chỉ hiển thị khi có dest
                      if (showDest && widget.dest != null)
                        Marker(
                          point: widget.dest!,
                          width: 40,
                          height: 40,
                          alignment: Alignment.topCenter,
                          child:
                              const Icon(Icons.location_pin, color: Colors.red),
                        ),
                    ],
                  ),

                // Polyline route - Chỉ hiển thị khi có route
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

          // Banner cảnh báo API (nếu có)
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
                    const Expanded(
                      child: Text(
                        'Không thể kết nối Goong Directions. Map hiển thị không có route.',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _apiKeyInvalid = false),
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
    final isApiKeyError = message.contains('api_key') || message.contains('API key');
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isApiKeyError ? Icons.key_off : Icons.error_outline,
                    color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14)),
                if (isApiKeyError) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Lưu ý: Goong Directions dùng REST api_key.\nLấy/kiểm tra key: https://account.goong.io/keys',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
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