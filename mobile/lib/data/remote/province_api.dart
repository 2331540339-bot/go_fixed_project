// province_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/province.dart';

class ProvinceApi {
  static const _base = 'https://provinces.open-api.vn';

  static Future<List<Province>> getProvinces() async {
    final res = await http.get(Uri.parse('$_base/api/p'));
    if (res.statusCode != 200) throw Exception('Load provinces failed');
    final List data = jsonDecode(res.body);
    return data.map((e) => Province.fromJson(e)).toList();
  }

  static Future<List<District>> getDistricts(int provinceCode) async {
    // /api/p/{code}?depth=2 trả về districts của tỉnh
    final res = await http.get(Uri.parse('$_base/api/p/$provinceCode?depth=2'));
    if (res.statusCode != 200) throw Exception('Load districts failed');
    final data = jsonDecode(res.body);
    final List d = data['districts'] ?? [];
    return d.map((e) => District.fromJson(e)).toList();
  }

  static Future<List<Ward>> getWards(int districtCode) async {
    // /api/d/{code}?depth=2 trả về wards của quận
    final res = await http.get(Uri.parse('$_base/api/d/$districtCode?depth=2'));
    if (res.statusCode != 200) throw Exception('Load wards failed');
    final data = jsonDecode(res.body);
    final List w = data['wards'] ?? [];
    return w.map((e) => Ward.fromJson(e)).toList();
  }

  // Tìm kiếm theo tên (nếu cần): /api/p/search/?q=ha noi
  static Future<List<Province>> searchProvinces(String q) async {
    final res = await http.get(Uri.parse('$_base/api/p/search/?q=$q'));
    if (res.statusCode != 200) throw Exception('Search province failed');
    final List data = jsonDecode(res.body);
    return data.map((e) => Province.fromJson(e)).toList();
  }
}
