import 'package:flutter/foundation.dart';
import 'package:mobile/presentation/model/product.dart';

class CartItem {
  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.image,
  });

  final String productId;
  final String name;
  final double price;
  int quantity;
  final String? image;
}

class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  void addProduct(Product product, {int quantity = 1}) {
    if (quantity <= 0) return;
    final existing =
        _items.where((e) => e.productId == product.id).firstOrNull;
    if (existing != null) {
      existing.quantity += quantity;
    } else {
      _items.add(
        CartItem(
          productId: product.id,
          name: product.name,
          price: product.price,
          quantity: quantity,
          image: (product.images != null && product.images!.isNotEmpty)
              ? product.images!.first
              : null,
        ),
      );
    }
    notifyListeners();
  }

  void changeQty(String productId, int delta) {
    final idx = _items.indexWhere((e) => e.productId == productId);
    if (idx == -1) return;
    final item = _items[idx];
    final nextQty = item.quantity + delta;
    if (nextQty <= 0) return;
    item.quantity = nextQty;
    notifyListeners();
  }

  void remove(String productId) {
    _items.removeWhere((e) => e.productId == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
