// order.dart
import 'enums.dart';
import 'common.dart';
import 'order_item.dart';

class Order {
  final String id;
  final String buyerId;
  final String sellerId;
  final double totalPrice;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String? shippingAddress;
  final GeoPoint? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderItem>? items; // nếu API trả kèm

  const Order({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    this.shippingAddress,
    this.location,
    this.createdAt,
    this.updatedAt,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id: (j['id'] ?? '').toString(),
    buyerId: (j['buyer_id'] ?? '').toString(),
    sellerId: (j['seller_id'] ?? '').toString(),
    totalPrice: numToDouble(j['total_price']),
    status: OrderStatusX.from(j['status']?.toString()),
    paymentStatus: PaymentStatusX.from(j['payment_status']?.toString()),
    shippingAddress: j['shipping_address'] as String?,
    location: j['location'] == null ? null : GeoPoint.fromJson(j['location']),
    createdAt: readDate(j['created_at']),
    updatedAt: readDate(j['updated_at']),
    items: (j['items'] is List)
        ? (j['items'] as List).map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e))).toList()
        : null,
  );

  Map<String, dynamic> toJson() => clean({
    'id': id,
    'buyer_id': buyerId,
    'seller_id': sellerId,
    'total_price': totalPrice,
    'status': status.json,
    'payment_status': paymentStatus.json,
    'shipping_address': shippingAddress,
    'location': location?.toJson(),
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
  });
}