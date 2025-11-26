// province_models.dart
class Province {
  final int code;
  final String name;
  Province({required this.code, required this.name});
  factory Province.fromJson(Map<String, dynamic> j)
    => Province(code: j['code'], name: j['name']);
}

class District {
  final int code;
  final String name;
  final int provinceCode;
  District({required this.code, required this.name, required this.provinceCode});
  factory District.fromJson(Map<String, dynamic> j)
    => District(code: j['code'], name: j['name'], provinceCode: j['province_code']);
}

class Ward {
  final int code;
  final String name;
  final int districtCode;
  Ward({required this.code, required this.name, required this.districtCode});
  factory Ward.fromJson(Map<String, dynamic> j)
    => Ward(code: j['code'], name: j['name'], districtCode: j['district_code']);
}
