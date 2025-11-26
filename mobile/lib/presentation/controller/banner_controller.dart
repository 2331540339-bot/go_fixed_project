// lib/controller/banner_controller.dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/api/banner_api.dart';
import 'package:mobile/presentation/model/banner.dart';
import 'package:mobile/config/router/app_router.dart';

class BannerController extends ChangeNotifier {
  BannerController(this._api);

  final BannerApi _api;

  bool _loading = false;
  String? _error;
  List<Banner> _items = const [];

  bool get loading => _loading;
  String? get error => _error;
  List<Banner> get items => _items;

  static Future<BannerController> create({String? baseUrl}) async {
    final api = BannerApi(http.Client(), baseUrl ?? AppRouter.main_domain);
    return BannerController(api);
  }

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _api.fetchBanners();
      _items = list;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }
}
