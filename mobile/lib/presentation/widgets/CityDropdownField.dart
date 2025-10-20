import 'package:flutter/material.dart';
import 'package:mobile/config/themes/app_color.dart';
import 'package:mobile/data/model/vietnam_address.dart';
import 'package:mobile/data/remote/vietnam_address_api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Dropdown chỉ chọn Tỉnh/Thành phố (province/city)
/// - Không cần nhập
/// - Tải danh sách 1 lần khi khởi tạo
class CityDropdownField extends StatefulWidget {
  /// Giá trị khởi tạo (nếu có)
  final VietnamAddress? initialValue;

  /// Callback khi chọn (có thể null nếu chưa chọn)
  final void Function(VietnamAddress?) onSelected;

  /// Nhãn ô nhập
  final String label;

  /// Validator (dùng trong Form)
  final String? Function(VietnamAddress?)? validator;

  /// Tuỳ chọn padding ngoài
  final EdgeInsetsGeometry? padding;

  /// Nếu bạn đã biết provinceCode muốn set sẵn
  final String? initialProvinceCode;

  const CityDropdownField({
    super.key,
    required this.onSelected,
    this.initialValue,
    this.initialProvinceCode,
    this.label = 'Chọn Tỉnh/Thành phố',
    this.validator,
    this.padding,
  });

  @override
  State<CityDropdownField> createState() => _CityDropdownFieldState();
}

class _CityDropdownFieldState extends State<CityDropdownField> {
  List<VietnamAddress> _cities = [];
  VietnamAddress? _selected;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Lấy danh sách province. Với API hiện tại, truyền chuỗi rỗng để lấy tất cả
      // và đặt limit lớn để không bị cắt (tuỳ API thực tế).
      final list = await VietnamAddressApi.searchProvinces('', limit: 1000);

      // Lọc đảm bảo đúng cấp tỉnh/thành dựa theo divisionType
      final onlyProvinces = list.where((a) {
        final t = a.divisionType.toLowerCase();
        return t.contains('province') ||
            t.contains('thành') ||
            t.contains('city') ||
            t.contains('tỉnh');
      }).toList()..sort((x, y) => x.name.compareTo(y.name));

      // Chọn initial
      VietnamAddress? initial = widget.initialValue;
      if (initial == null && widget.initialProvinceCode != null) {
        initial = onlyProvinces.firstWhere(
          (e) => e.code == widget.initialProvinceCode,
          orElse: () => onlyProvinces.isNotEmpty
              ? onlyProvinces.first
              : null as VietnamAddress,
        );
      }

      setState(() {
        _cities = onlyProvinces;
        _selected = initial;
        _loading = false;
      });
      // Gọi onSelected ngay nếu có initial
      if (initial != null) widget.onSelected(initial);
    } catch (e) {
      setState(() {
        _error = 'Không tải được danh sách Tỉnh/Thành. Thử lại.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _loading
        ? const SizedBox(
            height: 56,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        : (_error != null
              ? Row(
                  children: [
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      onPressed: _loadCities,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                )
              : DropdownButtonFormField<VietnamAddress>(
                  value: _selected,
                  items: _cities.map((a) {
                    // Chỉ hiển thị tên tỉnh/thành; subLabel/parent/topName của province là null → không cần
                    return DropdownMenuItem<VietnamAddress>(
                      value: a,
                      child: Text(
                        a.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColor.primaryColor),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() => _selected = v);
                    widget.onSelected(v);
                  },
                  validator: widget.validator,
                  decoration: InputDecoration(
                    maintainHintSize: true,
                    labelText: widget.label,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: const Icon(
                      Icons.location_city,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.primaryColor),
                    ),
                  ),
                  dropdownColor: Colors.transparent,
                  menuMaxHeight: 300.h,
               
                ));

    return Padding(padding: widget.padding ?? EdgeInsets.zero, child: child);
  }
}
