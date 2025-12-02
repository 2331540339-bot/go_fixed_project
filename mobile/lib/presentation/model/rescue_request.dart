// rescue_request.dart
import 'enums.dart';
import 'common.dart';

class RescueRequest {
  final String id;
  final String userId;
  final String? mechanicId;
  final String? serviceId;
  final String? serviceType;
  final String? description;
  final String? phone;
  final String? detailAddress;
  final List<String> images;
  final RescueRequestStatus status;
  final GeoPoint? location;
  final double? priceEstimate;
  final PaymentStatus paymentStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RescueRequest({
    required this.id,
    required this.userId,
    this.mechanicId,
    this.serviceId,
    this.serviceType,
    this.description,
    this.phone,
    this.detailAddress,
    this.images = const [],
    required this.status,
    this.location,
    this.priceEstimate,
    required this.paymentStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory RescueRequest.fromJson(Map<String, dynamic> j) => RescueRequest(
    id: (j['id'] ?? '').toString(),
    userId: (j['user_id'] ?? '').toString(),
    mechanicId: j['mechanic_id'] as String?,
    serviceId: j['service_id'] as String?,
    serviceType: j['service_type'] as String?,
    description: j['description'] as String?,
    phone: j['phone'] as String?,
    detailAddress: j['detail_address'] as String?,
    images: j['images'] == null
        ? const []
        : List<String>.from(j['images'] as List),
    status: RescueRequestStatusX.from(j['status']?.toString()),
    location: j['location'] == null ? null : GeoPoint.fromJson(j['location']),
    priceEstimate: j['price_estimate'] == null ? null : numToDouble(j['price_estimate']),
    paymentStatus: PaymentStatusX.from(j['payment_status']?.toString()),
    createdAt: readDate(j['created_at']),
    updatedAt: readDate(j['updated_at']),
  );

  Map<String, dynamic> toJson() => clean({
    'id': id,
    'user_id': userId,
    'mechanic_id': mechanicId,
    'service_id': serviceId,
    'service_type': serviceType,
    'description': description,
    'phone': phone,
    'detail_address': detailAddress,
    'images': images,
    'status': status.json,
    'location': location?.toJson(),
    'price_estimate': priceEstimate,
    'payment_status': paymentStatus.json,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  });
}
