import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/presentation/model/product.dart';
import 'package:mobile/api/product_api.dart';

class ProductController extends ChangeNotifier {
  ProductController(this._api);

  final ProductApi _api;

  bool _loading = false;
  String? _error;
  List<Product> _items = const [];

  bool get loading => _loading;
  String? get error => _error;
  List<Product> get items => _items;

  static Future<ProductController> create() async {
    final api = ProductApi(http.Client());
    return ProductController(api);
  }

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _api.fetchProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  Future<Product?> loadDetail(String id) async {
    try {
      final product = await _api.fetchProductDetail(id);
      return product;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }
}
