// service.dart
import 'enums.dart';
import 'common.dart';

class Service {
  final String id;
  final String name;
  final double basePrice; // DECIMAL -> double
  final String? iconUrl;
  final ServiceKind kind;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Service({
    required this.id,
    required this.name,
    required this.basePrice,
    this.iconUrl,
    required this.kind,
    this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> j) => Service(
    id: (j['id'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    basePrice: numToDouble(j['base_price']),
    iconUrl: j['icon_url'] as String?,
    kind: ServiceKindX.from(j['kind']?.toString()),
    createdAt: readDate(j['created_at']),
    updatedAt: readDate(j['updated_at']),
  );

  Map<String, dynamic> toJson() => clean({
    'id': id,
    'name': name,
    'base_price': basePrice,
    'icon_url': iconUrl,
    'kind': kind.json,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  });
}
