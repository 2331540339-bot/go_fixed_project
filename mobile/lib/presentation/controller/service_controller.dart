import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/data/remote/service_api.dart';
import 'package:mobile/data/model/service.dart';

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
}
