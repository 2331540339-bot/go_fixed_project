// lib/domain/model/banner_item.dart
class Banner {
  final String id;
  final String imageUrl; // ảnh để hiển thị
  final String? linkUrl; // bấm vào mở đâu (tuỳ)
  final String? title; // caption (tuỳ)

  const Banner({
    required this.id,
    required this.imageUrl,
    this.linkUrl,
    this.title,
  });

  factory Banner.fromJson(Map<String, dynamic> j) => Banner(
    id: (j['id'] ?? j['_id'] ?? '').toString(),
    imageUrl: (j['image_url'] ?? j['imageUrl'] ?? '').toString(),
    linkUrl: (j['link_url'] ?? j['linkUrl']) as String?,
    title: j['title'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'image_url': imageUrl,
    if (linkUrl != null) 'link_url': linkUrl,
    if (title != null) 'title': title,
  };
}
