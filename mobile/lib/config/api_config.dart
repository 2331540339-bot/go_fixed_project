class ApiConfig {
  // Google Maps API Key
  // Lưu ý: Trong production, nên lưu trong environment variables hoặc secure storage
  // Để lấy API key miễn phí: https://console.cloud.google.com/
  static const String googleMapsApiKey = 'AIzaSyCSssCqgxSNatX1tDJvnPe9P0y2Fp2Bzao';
  static const String goongMapsApiKey = 'P3Xc2zpQiMCXnmBFqBhBaUyoNGgdpAR7ijQWEGtd';
  static const String goongMaptilesApiKey = 'DtlvbCzY1lv2zdc4UqqX';
  

  
  // Google Maps API Endpoints
  static const String googleMapsBaseUrl = 'https://maps.googleapis.com/maps/api';
  static const String directionsEndpoint = '/directions/json';
  static const String geocodingEndpoint = '/geocoding/json';
  
  // Request timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 10);
  
  // Check if API key is valid (basic validation)
  static bool get isApiKeyValid => goongMapsApiKey.length >= 20;
}
