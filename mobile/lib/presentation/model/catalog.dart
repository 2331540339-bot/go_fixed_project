import 'common.dart';
class Catalog {
  final String id;
  final String catalogName;
  final String images;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const Catalog({
    required this.id,
    required this.catalogName,
    required this.images,
    this.createdAt,
    this.updatedAt,
  });
  factory Catalog.fromJson(Map<String, dynamic> j) => Catalog(
    id: (j['_id'] ??'').toString(),
    catalogName: (j['catalog_name'] ?? '').toString(),
    images: (j['image'] ?? '').toString(),
    createdAt: readDate(j['created_at']),
    updatedAt: readDate(j['updated_at']),
  );
  Map<String, dynamic> toJson() => clean({
    'id': id,
    'catalog_name': catalogName,
    'images': images,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  });

}