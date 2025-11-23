import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/config/router/app_router.dart';
import 'package:mobile/data/model/catalog.dart';
import 'package:mobile/data/remote/catalog_api.dart';

class CatalogController extends ChangeNotifier {
  CatalogController(this._api);

  final CatalogApi _api;

  bool _loading = false;
  String? _error;
  List<Catalog> _items = const [];

  bool get loading => _loading;
  String? get error => _error;
  List<Catalog> get items => _items;

  static Future<CatalogController> create({String? baseUrl}) async {
    final api = CatalogApi(http.Client());
    return CatalogController(api);
  }

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _api.fetchCatalogs();
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
