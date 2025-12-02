import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/presentation/model/service.dart';

class RescueFlowController extends ChangeNotifier {
  Service? _service;
  String? _description;
  Map<String, dynamic>? _location;
  double? _priceEstimate;
  String? _phone;
  String? _detailAddress;
  List<String> _images = const [];

  // GETTER
  Service? get service => _service;
  String? get description => _description;
  Map<String, dynamic>? get location => _location;
  double? get priceEstimate => _priceEstimate;
  String? get phone => _phone;
  String? get detailAddress => _detailAddress;
  List<String> get images => _images;

  // SETTER + notify
  LatLng? get latLngLocation {
    if (_location == null) return null;

    // Giả định Map lưu trữ 'lat' và 'lng' dưới dạng double
    final lat = _location!['lat'] as double?;
    final lng = _location!['lng'] as double?;

    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }
    return null;
  }

  void setService(Service service) {
    _service = service;
    // Khi chọn service mới, reset mấy field còn lại
    _description = null;
    _location = null;
    _priceEstimate = null;
    _phone = null;
    _detailAddress = null;
    _images = const [];
    notifyListeners();
  }

  void setDescription(String? desc) {
    _description = desc;
    notifyListeners();
  }

  void setPhone(String? phone) {
    _phone = phone;
    notifyListeners();
  }

  void setDetailAddress(String? address) {
    _detailAddress = address;
    notifyListeners();
  }

  void setImages(List<String> images) {
    _images = List<String>.from(images);
    notifyListeners();
  }

  void setLocation(Map<String, dynamic> loc) {
    _location = loc;
    notifyListeners();
  }

  void setPriceEstimate(double price) {
    _priceEstimate = price;
    notifyListeners();
  }

  void reset() {
    _service = null;
    _description = null;
    _location = null;
    _priceEstimate = null;
    _phone = null;
    _detailAddress = null;
    _images = const [];
    notifyListeners();
  }
}
