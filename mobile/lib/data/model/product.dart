// product.dart
import 'common.dart';

class Product {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final double price;
  final int stock;
  final List<String>? images; // JSON array of URLs
  final String sellerId;
  final bool installService;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.description,
    this.category,
    required this.price,
    required this.stock,
    this.images,
    required this.sellerId,
    required this.installService,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: (j['id'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    description: j['description'] as String?,
    category: j['category'] as String?,
    price: numToDouble(j['price']),
    stock: (j['stock'] is int) ? j['stock'] as int : int.tryParse('${j['stock']}') ?? 0,
    images: (j['images'] is List)
        ? (j['images'] as List).map((e) => e.toString()).toList()
        : null,
    sellerId: (j['seller_id'] ?? '').toString(),
    installService: (j['install_service'] == 1) || (j['install_service'] == true),
    createdAt: readDate(j['created_at']),
    updatedAt: readDate(j['updated_at']),
  );

  Map<String, dynamic> toJson() => clean({
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'price': price,
    'stock': stock,
    'images': images,
    'seller_id': sellerId,
    'install_service': installService ? 1 : 0,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  });
}
