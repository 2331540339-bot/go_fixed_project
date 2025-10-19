class VietnamAddress {
  final String code;        // mã (string để đồng bộ 3 loại)
  final String name;        // tên chính (ví dụ: Quận 1 / Phường 2 / Hà Nội)
  final String divisionType; // province/district/ward label
  final String? parentName; // tên cha (district -> province; ward -> district)
  final String? topName;    // tên tỉnh/thành (nếu là ward/district)

  VietnamAddress({
    required this.code,
    required this.name,
    required this.divisionType,
    this.parentName,
    this.topName,
  });

  /// Dòng hiển thị phụ (ví dụ: "Quận/Huyện • Tỉnh/Thành")
  String get subLabel {
    final parts = <String>[];
    if (parentName != null && parentName!.isNotEmpty) parts.add(parentName!);
    if (topName != null && topName!.isNotEmpty && topName != parentName) {
      parts.add(topName!);
    }
    return parts.isEmpty ? divisionType : '${parts.join(" • ")}';
  }

  /// Dòng hiển thị đầy đủ để gán vào TextField
  String get fullLabel {
    final parts = <String>[name];
    if (parentName != null && parentName!.isNotEmpty) parts.add(parentName!);
    if (topName != null && topName!.isNotEmpty && topName != parentName) {
      parts.add(topName!);
    }
    return parts.join(', ');
  }
}
