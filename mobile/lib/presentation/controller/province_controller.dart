// province_controller.dart
import '../../data/remote/province_api.dart';
import '../../data/model/province.dart';

class AddressController {
  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];

  Province? selectedProvince;
  District? selectedDistrict;
  Ward? selectedWard;

  Future<void> loadProvinces() async {
    provinces = await ProvinceApi.getProvinces();
  }

  Future<void> onSelectProvince(Province? p) async {
    selectedProvince = p;
    selectedDistrict = null;
    selectedWard = null;
    districts = p == null ? [] : await ProvinceApi.getDistricts(p.code);
    wards = [];
  }

  Future<void> onSelectDistrict(District? d) async {
    selectedDistrict = d;
    selectedWard = null;
    wards = d == null ? [] : await ProvinceApi.getWards(d.code);
  }

  void onSelectWard(Ward? w) {
    selectedWard = w;
  }

  String buildFullAddress({String? houseNo, String? street}) {
    final parts = <String>[
      if ((houseNo ?? '').isNotEmpty || (street ?? '').isNotEmpty)
        [houseNo, street].where((e) => e != null && e!.isNotEmpty).join(' '),
      if (selectedWard != null) selectedWard!.name,
      if (selectedDistrict != null) selectedDistrict!.name,
      if (selectedProvince != null) selectedProvince!.name,
    ];
    return parts.join(', ');
  }
}
