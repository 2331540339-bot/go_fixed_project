import 'package:flutter/material.dart';
import 'package:mobile/config/themes/app_color.dart';
import 'package:mobile/data/model/vietnam_address.dart';
import 'package:mobile/data/remote/vietnam_address_api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProvinceDistrictPicker extends StatefulWidget {
  final VietnamAddress? initialProvince;
  final VietnamAddress? initialDistrict;

  /// Bắn ra khi đổi province
  final void Function(VietnamAddress?)? onProvinceSelected;

  /// Bắn ra khi đổi district
  final void Function(VietnamAddress?)? onDistrictSelected;

  /// Có thể truyền label
  final String provinceLabel;
  final String districtLabel;

  const ProvinceDistrictPicker({
    super.key,
    this.initialProvince,
    this.initialDistrict,
    this.onProvinceSelected,
    this.onDistrictSelected,
    this.provinceLabel = 'Chọn Tỉnh/Thành phố',
    this.districtLabel = 'Chọn Quận/Huyện',
  });

  @override
  State<ProvinceDistrictPicker> createState() => _ProvinceDistrictPickerState();
}

class _ProvinceDistrictPickerState extends State<ProvinceDistrictPicker> {
  List<VietnamAddress> _provinces = [];
  List<VietnamAddress> _districts = [];

  VietnamAddress? _selectedProvince;
  VietnamAddress? _selectedDistrict;

  bool _loadingProvince = true;
  bool _loadingDistrict = false;

  String? _errorProvince;
  String? _errorDistrict;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    setState(() {
      _loadingProvince = true;
      _errorProvince = null;
    });
    try {
      final list = await VietnamAddressApi.searchProvinces('', limit: 1000);
      final onlyProvinces = list.where((a) {
        final t = a.divisionType.toLowerCase();
        return t.contains('province') ||
            t.contains('city') ||
            t.contains('tỉnh') ||
            t.contains('thành');
      }).toList()..sort((x, y) => x.name.compareTo(y.name));

      // set initial
      VietnamAddress? initProvince = widget.initialProvince;
      if (initProvince != null) {
        initProvince = onlyProvinces.firstWhere(
          (e) => e.code == widget.initialProvince!.code,
          orElse: () => initProvince!,
        );
      }

      setState(() {
        _provinces = onlyProvinces;
        _selectedProvince = initProvince;
        _loadingProvince = false;
      });

      // Nếu có province ban đầu, load quận tương ứng
      if (_selectedProvince != null) {
        await _loadDistrictsByProvince(
          _selectedProvince!.code,
          initial: widget.initialDistrict,
        );
      }
      widget.onProvinceSelected?.call(_selectedProvince);
    } catch (e) {
      setState(() {
        _errorProvince = 'Không tải được danh sách Tỉnh/Thành.';
        _loadingProvince = false;
      });
    }
  }

  Future<void> _loadDistrictsByProvince(
    String provinceCode, {
    VietnamAddress? initial,
  }) async {
    setState(() {
      _loadingDistrict = true;
      _errorDistrict = null;
      _districts = [];
      _selectedDistrict = null;
    });
    try {
      final list = await VietnamAddressApi.getDistrictsByProvinceCode(
        provinceCode,
      );

      VietnamAddress? initDistrict = initial;
      if (initDistrict != null) {
        initDistrict = list.firstWhere(
          (e) => e.code == initDistrict!.code,
          orElse: () => initDistrict!,
        );
      }

      setState(() {
        _districts = list;
        _selectedDistrict = initDistrict;
        _loadingDistrict = false;
      });

      widget.onDistrictSelected?.call(_selectedDistrict);
    } catch (e) {
      setState(() {
        _errorDistrict = 'Không tải được danh sách Quận/Huyện.';
        _loadingDistrict = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Province (Tỉnh/Thành phố) ---
    final provinceField = _loadingProvince
        ? const _InlineLoading()
        : (_errorProvince != null
              ? _InlineError(text: _errorProvince!, onRetry: _loadProvinces)
              : SizedBox(
                  width: 250.w,
                  child: DropdownMenu<VietnamAddress>(
                    initialSelection: _selectedProvince,
                    onSelected: (v) async {
                      setState(() => _selectedProvince = v);
                      widget.onProvinceSelected?.call(v);

                      if (v != null) {
                        await _loadDistrictsByProvince(v.code);
                      } else {
                        setState(() {
                          _districts.clear();
                          _selectedDistrict = null;
                        });
                        widget.onDistrictSelected?.call(null);
                      }
                    },
                    // hiển thị nhãn & icon
                    label: const Text('Tỉnh/Thành phố'),
                    leadingIcon: const Icon(Icons.location_city),
                    trailingIcon: const Icon(Icons.keyboard_arrow_down_rounded),

                    // style phần menu xổ xuống
                    menuStyle: const MenuStyle(
                      maximumSize: WidgetStatePropertyAll(Size.fromHeight(300)),
                      elevation: WidgetStatePropertyAll(4),
                    ),

                    // style phần ô nhập
                    inputDecorationTheme: InputDecorationTheme(
                      isDense: true,
                      labelStyle: TextStyle(color: AppColor.textColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: AppColor.primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),

                    textStyle: TextStyle(color: AppColor.secconColor),

                    // danh sách item
                    dropdownMenuEntries: _provinces
                        .map(
                          (p) => DropdownMenuEntry<VietnamAddress>(
                            value: p,
                            label: p
                                .name, // DropdownMenu dùng 'label' để render text
                          ),
                        )
                        .toList(),
                  ),
                ));

    // --- District (Quận/Huyện) ---
    final districtField = (_selectedProvince == null)
        ? const _DisabledField(label: 'Chọn Quận/Huyện')
        : (_loadingDistrict
              ? const _InlineLoading()
              : (_errorDistrict != null
                    ? _InlineError(
                        text: _errorDistrict!,
                        onRetry: () {
                          if (_selectedProvince != null) {
                            _loadDistrictsByProvince(_selectedProvince!.code);
                          }
                        },
                      )
                    : SizedBox(
                        width: 250.w,
                        child: DropdownMenu<VietnamAddress>(
                          initialSelection: _selectedDistrict,
                          onSelected: (v) {
                            setState(() => _selectedDistrict = v);
                            widget.onDistrictSelected?.call(v);
                          },

                          label: const Text('Quận/Huyện'),
                          leadingIcon: const Icon(Icons.maps_home_work),
                          trailingIcon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                          ),

                          menuStyle: const MenuStyle(
                            maximumSize: WidgetStatePropertyAll(
                              Size.fromHeight(300),
                            ),
                            elevation: WidgetStatePropertyAll(4),
                          ),

                          inputDecorationTheme: InputDecorationTheme(
                            isDense: true,
                            labelStyle: TextStyle(color: AppColor.textColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: AppColor.primaryColor,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),

                          textStyle: TextStyle(color: AppColor.textColor),

                          dropdownMenuEntries: _districts
                              .map(
                                (d) => DropdownMenuEntry<VietnamAddress>(
                                  value: d,
                                  label: d.name,
                                ),
                              )
                              .toList(),
                        ),
                      )));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [provinceField, const SizedBox(height: 12), districtField],
    );
  }
}

class _InlineLoading extends StatelessWidget {
  const _InlineLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 56,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;
  const _InlineError({required this.text, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.red)),
        ),
        IconButton(onPressed: onRetry, icon: const Icon(Icons.refresh)),
      ],
    );
  }
}

class _DisabledField extends StatelessWidget {
  final String label;
  const _DisabledField({required this.label});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
