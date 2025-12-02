import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/api/service_api.dart';
import 'package:mobile/presentation/model/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceController extends ChangeNotifier {
  ServiceController(this._api);

  final ServiceApi _api;

  bool loading = false;
  String? error;
  List<Service> items = const [];

  static Future<ServiceController> create() async {
    final api = ServiceApi(http.Client());
    return ServiceController(api);
  }

  Future<void> load({int limit = 6, String? q}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _api.listServices(limit: limit, q: q);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> sendRescueRequest({
    required String serviceId,
    required String description,
    required Map<String, dynamic> location,
    required double priceEstimate,
    required String authToken,
    required String phone,
    required String detailAddress,
    required List<String> images,
  }) async {
  
    final sp = await SharedPreferences.getInstance();
    final storedToken = sp.getString('token');
    final token = authToken.isNotEmpty ? authToken : (storedToken ?? '');

    if (token.isEmpty) {
      throw Exception(
        'Lỗi xác thực: Người dùng chưa đăng nhập hoặc token trống.',
      );
    }

    try {
      await _api.sendRescueRequest(
        serviceId: serviceId,
        description: description,
        location: location,
        priceEstimate: priceEstimate,
        phone: phone,
        detailAddress: detailAddress,
        images: images,
        authToken: token, // Truyền token vào ServiceApi
      );
    } catch (e) {
      // Ném lỗi để widget DetailPricePage xử lý và hiển thị Modal lỗi
      rethrow;
    }
  }
}
