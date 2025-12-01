// order_item.dart
import 'common.dart';
class OrderItem {
  final int id;              // BIGINT
  final String orderId;
  final String productId;
  final int quantity;
  final double price;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    id: (j['id'] is int) ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
    orderId: (j['order_id'] ?? '').toString(),
    productId: (j['product_id'] ?? '').toString(),
    quantity: (j['quantity'] is int) ? j['quantity'] as int : int.tryParse('${j['quantity']}') ?? 0,
    price: numToDouble(j['price']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_id': orderId,
    'product_id': productId,
    'quantity': quantity,
    'price': price,
  };
}
