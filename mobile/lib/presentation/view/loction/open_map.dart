import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapOnlyBox extends StatelessWidget {
  const MapOnlyBox({
    super.key,
    required this.center, // tâm bản đồ
    required this.mapTilerKey, // MapTiler API key
    this.userPosition,
    this.zoom = 13,
    this.height = 260,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(12),
    this.showUserMarker = true,
    this.mapController, // 👈 thêm
    this.onMapReady, // 👈 thêm
  });

  final LatLng center;
  final String mapTilerKey;
  final LatLng? userPosition;
  final double zoom;
  final double height;
  final double borderRadius;
  final EdgeInsets padding;
  final bool showUserMarker;
  final MapController? mapController; // 👈
  final VoidCallback? onMapReady; // 👈

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '[MapOnlyBox] showUserMarker=$showUserMarker, userPosition=$userPosition',
    );
    final controller = mapController ?? MapController(); // fallback

    return Container(
      height: height,
      margin: padding,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        mapController: controller,
        options: MapOptions(
          initialCenter: center,
          initialZoom: zoom,
          onMapReady: onMapReady,
        ),
        children: [
          TileLayer(
            // Ghép key trực tiếp để tránh sai placeholder
            urlTemplate:
                'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$mapTilerKey',
            userAgentPackageName: 'com.example.app',
            // attributionBuilder: (_) => const Text('© MapTiler © OpenStreetMap contributors'),
            // Log lỗi tile nếu có (thấy 401/403/404)
            errorTileCallback: (tile, error, stack) {
              // ignore: avoid_print
              // print('TILE ERROR ${tile.coords}: $error');
            },
          ),

          if (showUserMarker && (userPosition != null))
            MarkerLayer(
              markers: [
                Marker(
                  point: userPosition!,
                  width: 40,
                  height: 40,
                  alignment: Alignment.topCenter,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
