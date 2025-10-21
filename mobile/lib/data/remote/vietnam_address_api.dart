import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/data/model/vietnam_address.dart';

class VietnamAddressApi {
  static const _base = 'https://provinces.open-api.vn/api/v1';

  static Future<List<VietnamAddress>> searchProvinces(
    String q, {
    int limit = 6,
  }) async {
    final uri = Uri.parse('$_base/p?search=$q');
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final List data = jsonDecode(res.body);
    return data.take(limit).map((e) {
      return VietnamAddress(
        code: (e['code'] ?? '').toString(),
        name: e['name'] ?? '',
        divisionType: e['division_type'] ?? 'province',
        parentName: null,
        topName: null,
      );
    }).toList();
  }

  static Future<List<VietnamAddress>> searchDistricts(
    String q, {
    int limit = 6,
  }) async {
    final uri = Uri.parse('$_base/d?search=$q');
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final List data = jsonDecode(res.body);
    return data.take(limit).map((e) {
      return VietnamAddress(
        code: (e['code'] ?? '').toString(),
        name: e['name'] ?? '',
        divisionType: e['division_type'] ?? 'district',
        parentName: e['province_name'] ?? '', // API trả kèm
        topName: e['province_name'] ?? '',
      );
    }).toList();
  }

  static Future<List<VietnamAddress>> searchWards(
    String q, {
    int limit = 6,
  }) async {
    final uri = Uri.parse('$_base/w?search=$q');
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final List data = jsonDecode(res.body);
    return data.take(limit).map((e) {
      return VietnamAddress(
        code: (e['code'] ?? '').toString(),
        name: e['name'] ?? '',
        divisionType: e['division_type'] ?? 'ward',
        parentName: e['district_name'] ?? '',
        topName: e['province_name'] ?? '',
      );
    }).toList();
  }

  /// Gợi ý tổng hợp: province + district + ward (trộn & cắt top N)
  static Future<List<VietnamAddress>> searchAllAdministrativeLevels(
    String q, {
    int limitEach = 5,
    int totalLimit = 10,
  }) async {
    final rs = await Future.wait([
      searchProvinces(q, limit: limitEach),
      searchDistricts(q, limit: limitEach),
      searchWards(q, limit: limitEach),
    ]);

    // Ưu tiên: ward > district > province (ít chung chung hơn)
    final wards = rs[2];
    final districts = rs[1];
    final provinces = rs[0];

    final combined = <VietnamAddress>[...wards, ...districts, ...provinces];

    // Loại trùng theo (name + parentName + topName)
    final seen = <String>{};
    final dedup = <VietnamAddress>[];
    for (final a in combined) {
      final key = '${a.name}|${a.parentName}|${a.topName}';
      if (seen.add(key)) dedup.add(a);
      if (dedup.length >= totalLimit) break;
    }
    return dedup;
  }

  // Trong VietnamAddressApi
  static Future<List<VietnamAddress>> getDistrictsByProvinceCode(
    String provinceCode,
  ) async {
    if (provinceCode.isEmpty) return [];
    final uri = Uri.parse('$_base/p/$provinceCode?depth=2');
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];

    final data = jsonDecode(res.body);
    final provinceName = (data['name'] ?? '').toString();
    final List districts = (data['districts'] as List?) ?? [];

    return districts.map((e) {
      return VietnamAddress(
        code: (e['code'] ?? '').toString(),
        name: e['name'] ?? '',
        divisionType: e['division_type'] ?? 'district',
        parentName: provinceName, // cha là Tỉnh/Thành
        topName: provinceName,
      );
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
  }
  static Future<List<VietnamAddress>> getWardsByDistrictCode(String districtCode) async {
  if (districtCode.isEmpty) return [];
  final uri = Uri.parse('$_base/d/$districtCode?depth=2');
  final res = await http.get(uri);
  if (res.statusCode != 200) return [];

  final data = jsonDecode(res.body);
  final districtName = (data['name'] ?? '').toString();
  // API thường trả kèm province_name cho cấp quận; nếu không có thì để null
  final provinceName = (data['province_name'] ?? '').toString().isNotEmpty
      ? (data['province_name'] as String)
      : null;

  final List wards = (data['wards'] as List?) ?? [];

  return wards.map((e) {
    return VietnamAddress(
      code: (e['code'] ?? '').toString(),
      name: e['name'] ?? '',
      divisionType: e['division_type'] ?? 'ward',
      parentName: districtName,   // cha là Quận/Huyện
      topName: provinceName,      // Tỉnh/Thành (nếu API trả)
    );
  }).toList()
    ..sort((a, b) => a.name.compareTo(b.name));
}
}
