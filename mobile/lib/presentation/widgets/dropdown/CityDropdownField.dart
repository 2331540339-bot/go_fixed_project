import 'package:flutter/material.dart';
import 'package:mobile/config/themes/app_color.dart';
import 'package:mobile/data/model/vietnam_address.dart';
import 'package:mobile/data/remote/vietnam_address_api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProvinceDistrictPicker extends StatefulWidget {
  final VietnamAddress? initialProvince;
  final VietnamAddress? initialDistrict;
  final VietnamAddress? initialWard;

  /// Bắn ra khi đổi province
  final void Function(VietnamAddress?)? onProvinceSelected;

  /// Bắn ra khi đổi district
  final void Function(VietnamAddress?)? onDistrictSelected;

  /// Bắn ra khi đổi ward
  final void Function(VietnamAddress?)? onWardSelected;

  /// Có thể truyền label
  final String provinceLabel;
  final String districtLabel;
  final String wardLabel;

  const ProvinceDistrictPicker({
    super.key,
    this.initialProvince,
    this.initialDistrict,
    this.initialWard,
    this.onProvinceSelected,
    this.onDistrictSelected,
    this.onWardSelected,
    this.provinceLabel = 'Chọn Tỉnh/Thành phố',
    this.districtLabel = 'Chọn Quận/Huyện',
    this.wardLabel = 'Chọn Xã/Phường',
  });

  @override
  State<ProvinceDistrictPicker> createState() => _ProvinceDistrictPickerState();
}

class _ProvinceDistrictPickerState extends State<ProvinceDistrictPicker> {
  List<VietnamAddress> _provinces = [];
  List<VietnamAddress> _districts = [];
  List<VietnamAddress> _wards = [];

  VietnamAddress? _selectedProvince;
  VietnamAddress? _selectedDistrict;
  VietnamAddress? _selectedWard;

  bool _loadingProvince = true;
  bool _loadingDistrict = false;
  bool _loadingWard = false;

  String? _errorProvince;
  String? _errorDistrict;
  String? _errorWard; // FIX: thay vì _errorWord

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

      // Nếu có province ban đầu, load quận (và nếu có, load tiếp xã)
      if (_selectedProvince != null) {
        await _loadDistrictsByProvince(
          _selectedProvince!.code,
          initial: widget.initialDistrict,
        );
        if (widget.initialDistrict != null) {
          await _loadWardsByDistrict(
            widget.initialDistrict!.code,
            initial: widget.initialWard,
          );
        }
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

      // Reset cấp dưới (ward) luôn khi đổi/quay lại load district
      _wards = [];
      _selectedWard = null;
      _loadingWard = false;
      _errorWard = null;
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

      // Nếu có district ban đầu, load tiếp wards
      if (_selectedDistrict != null) {
        await _loadWardsByDistrict(
          _selectedDistrict!.code,
          initial: widget.initialWard,
        );
      }
    } catch (e) {
      setState(() {
        _errorDistrict = 'Không tải được danh sách Quận/Huyện.';
        _loadingDistrict = false;
      });
    }
  }

  Future<void> _loadWardsByDistrict(
    String districtCode, {
    VietnamAddress? initial,
  }) async {
    setState(() {
      _loadingWard = true;
      _errorWard = null;
      _wards = [];
      _selectedWard = null;
    });
    try {
      final list = await VietnamAddressApi.getWardsByDistrictCode(districtCode);

      VietnamAddress? initWard = initial;
      if (initWard != null) {
        initWard = list.firstWhere(
          (e) => e.code == initWard!.code,
          orElse: () => initWard!,
        );
      }

      setState(() {
        _wards = list;
        _selectedWard = initWard;
        _loadingWard = false;
      });

      widget.onWardSelected?.call(_selectedWard);
    } catch (e) {
      setState(() {
        _errorWard = 'Không tải được danh sách Xã/Phường.';
        _loadingWard = false;
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
                  width: 150.w,
                  child: DropdownMenu<VietnamAddress>(
                    initialSelection: _selectedProvince,
                    onSelected: (v) async {
                      setState(() {
                        _selectedProvince = v;
                        // Reset cấp dưới khi đổi tỉnh
                        _districts.clear();
                        _selectedDistrict = null;
                        _wards.clear();
                        _selectedWard = null;
                        _errorDistrict = null;
                        _errorWard = null;
                      });
                      widget.onProvinceSelected?.call(v);

                      if (v != null) {
                        await _loadDistrictsByProvince(v.code);
                      } else {
                        // nếu bỏ chọn tỉnh → xoá quận/xã
                        setState(() {
                          _districts.clear();
                          _selectedDistrict = null;
                          _wards.clear();
                          _selectedWard = null;
                        });
                        widget.onDistrictSelected?.call(null);
                        widget.onWardSelected?.call(null);
                      }
                    },
                    label: Text(widget.provinceLabel),
                    leadingIcon: const Icon(Icons.location_city),
                    trailingIcon: const Icon(Icons.keyboard_arrow_down_rounded),

                    // style menu
                    menuStyle: const MenuStyle(
                      maximumSize: WidgetStatePropertyAll(Size.fromHeight(300)),
                      elevation: WidgetStatePropertyAll(4),
                    ),

                    // style ô nhập
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

                    // data
                    dropdownMenuEntries: _provinces
                        .map(
                          (p) => DropdownMenuEntry<VietnamAddress>(
                            value: p,
                            label: p.name,
                          ),
                        )
                        .toList(),
                  ),
                ));

    // --- District (Quận/Huyện) ---
    final districtField = (_selectedProvince == null)
        ? _DisabledField(label: widget.districtLabel)
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
                        width: 150.w,
                        child: DropdownMenu<VietnamAddress>(
                          initialSelection: _selectedDistrict,
                          onSelected: (v) async {
                            setState(() {
                              _selectedDistrict = v;
                              // reset ward khi đổi quận
                              _wards.clear();
                              _selectedWard = null;
                              _errorWard = null;
                            });
                            widget.onDistrictSelected?.call(v);

                            if (v != null) {
                              await _loadWardsByDistrict(v.code);
                            } else {
                              setState(() {
                                _wards.clear();
                                _selectedWard = null;
                              });
                              widget.onWardSelected?.call(null);
                            }
                          },
                          label: Text(widget.districtLabel),
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

    // --- Ward (Xã/Phường) ---
    final wardField = (_selectedDistrict == null)
        ? _DisabledField(label: widget.wardLabel)
        : (_loadingWard
              ? const _InlineLoading()
              : (_errorWard != null
                    ? _InlineError(
                        text: _errorWard!,
                        onRetry: () {
                          if (_selectedDistrict != null) {
                            _loadWardsByDistrict(_selectedDistrict!.code);
                          }
                        },
                      )
                    : SizedBox(
                        width: 150.w,
                        child: DropdownMenu<VietnamAddress>(
                          initialSelection: _selectedWard,
                          onSelected: (v) {
                            setState(() => _selectedWard = v);
                            widget.onWardSelected?.call(v);
                          },
                          label: Text(widget.wardLabel),
                          leadingIcon: const Icon(Icons.location_on),
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

                          dropdownMenuEntries: _wards
                              .map(
                                (w) => DropdownMenuEntry<VietnamAddress>(
                                  value: w,
                                  label: w.name,
                                ),
                              )
                              .toList(),
                        ),
                      )));

    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          
          children: [
            provinceField,
            const SizedBox(width: 12),
            districtField,
            const SizedBox(width: 12),
            wardField,
          ],
        ),
      ),
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
