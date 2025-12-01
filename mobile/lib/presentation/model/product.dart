// product.dart
import 'common.dart';

class Product {
  final String id;
  final String name;
  final String? description;
  /// Dùng để giữ catalog_id từ backend
  final String? category;
  final double price;
  final int stock;
  /// JSON array of URLs
  final List<String>? images;
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
        // Mongo: _id, API khác: id
        id: (j['id'] ?? j['_id'] ?? '').toString(),

        // Mongo: product_name, API khác: name
        name: (j['product_name'] ?? j['name'] ?? '').toString(),

        description: j['description'] as String?,

        // Mongo: catalog_id => mình map vào category
        category: (j['catalog_id'] ?? j['category'])?.toString(),

        // Mongo: price là Number
        price: numToDouble(j['price']),

        // Mongo: quantity => map vào stock
        stock: (j['quantity'] is int)
            ? j['quantity'] as int
            : (j['stock'] is int)
                ? j['stock'] as int
                : int.tryParse('${j['quantity'] ?? j['stock'] ?? 0}') ?? 0,

        // Mongo: image (array) => images
        images: (j['image'] is List)
            ? (j['image'] as List).map((e) => e.toString()).toList()
            : (j['images'] is List)
                ? (j['images'] as List).map((e) => e.toString()).toList()
                : null,

        // Hiện backend chưa có seller_id / install_service -> để trống / default
        sellerId: (j['seller_id'] ?? '').toString(),
        installService:
            (j['install_service'] == 1) || (j['install_service'] == true),

        // Mongoose timestamps: createdAt / updatedAt (camelCase)
        createdAt: readDate(j['createdAt'] ?? j['created_at']),
        updatedAt: readDate(j['updatedAt'] ?? j['updated_at']),
      );

  Map<String, dynamic> toJson() => clean({
        // id thường không cần gửi khi tạo mới,
        // nhưng giữ lại nếu bạn dùng để update
        'id': id,

        // match với schema Mongo
        'product_name': name,
        'description': description,
        'price': price,
        'quantity': stock,
        'image': images,
        'catalog_id': category,

        // các field dưới backend hiện chưa dùng, nhưng giữ nếu sau này cần
        'seller_id': sellerId,
        'install_service': installService ? 1 : 0,

        // Mongoose tự set createdAt / updatedAt, nên thường không cần gửi
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      });
}
