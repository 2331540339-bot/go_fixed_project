import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapRouteBox extends StatefulWidget {
  const MapRouteBox({
    super.key,
    required this.dest,
    required this.apiKey,           // 🔑 API key OpenRouteService (đừng public)
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

  @override
  void initState() {
    super.initState();
    _initRoute();
  }

  Future<void> _initRoute() async {
    try {
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
      final pos = await Geolocator.getCurrentPosition();
      final origin = LatLng(pos.latitude, pos.longitude);

      // 3) Gọi OpenRouteService (driving-car)
      final url =
          Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car');
      final body = jsonEncode({
        'coordinates': [
          [origin.longitude, origin.latitude],
          [widget.dest.longitude, widget.dest.latitude],
        ]
      });

      final res = await http.post(
        url,
        headers: {
          'Authorization': widget.apiKey, // ✅ ĐÚNG format
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (res.statusCode != 200) {
        throw 'Route failed: ${res.statusCode} ${res.reasonPhrase}';
      }

      final json = jsonDecode(res.body);
      final List coords = json['features'][0]['geometry']['coordinates'];
      final polyline = coords
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();

      if (!mounted) return;
      setState(() {
        _origin = origin;
        _route = polyline;
        _loading = false;
        _error = null;
      });

      // 4) Fit camera (nếu có origin)
      final bounds = LatLngBounds.fromPoints([origin, widget.dest]);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(32)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      widget.onError?.call(e.toString());
    }
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
      child: _loading
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
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
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
