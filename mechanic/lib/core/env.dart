// lib/core/env.dart
class Env {
  static const mapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const baseUrl    = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');
}
