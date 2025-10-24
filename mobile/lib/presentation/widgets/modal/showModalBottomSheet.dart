import 'package:flutter/material.dart';
import 'package:mobile/config/themes/app_color.dart';
import 'package:mobile/data/model/vietnam_address.dart';
import 'package:mobile/data/remote/vietnam_address_api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Showmodalbottomsheet extends StatefulWidget {
  final VietnamAddress? initialProvince;
  final VietnamAddress? initialDistrict;
  final VietnamAddress? initialWard;
  final ValueChanged<String>? onStreetChanged;

  final void Function(VietnamAddress?)? onProvinceSelected;
  final void Function(VietnamAddress?)? onDistrictSelected;
  final void Function(VietnamAddress?)? onWardSelected;

  final String provinceLabel;
  final String districtLabel;
  final String wardLabel;

  const Showmodalbottomsheet({
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
    this.onStreetChanged,
  });

  @override
  State<Showmodalbottomsheet> createState() => _ShowmodalbottomsheetState();
}

class _ShowmodalbottomsheetState extends State<Showmodalbottomsheet> {
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
  String? _errorWard;

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

  // =========================
  // Modal Bottom Sheet helper
  // =========================
  Future<T?> _showPickerSheet<T>({
    required String title,
    required List<T> items,
    required T? current,
    required String Function(T) labelOf,
  }) async {
    T? temp = current;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setMState) {
            return SafeArea(
              
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColor.primaryColor,
                            ),
                            onPressed: () => Navigator.pop<T>(context, null),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Container(
                      height: 350.h,
                      decoration: BoxDecoration(color: Colors.transparent),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox.shrink(), // không kẻ

                        itemBuilder: (_, i) {
                          final item = items[i];
                          final selected = item == temp;
                          return RadioListTile<T>(
                            dense: true,
                            isThreeLine: false,
                            title: Text(
                              labelOf(item),
                              style: TextStyle(
                                color: AppColor.primaryColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            activeColor: AppColor.primaryColor,
                            value: item,
                            groupValue: temp,
                            onChanged: (v) => setMState(() => temp = v),
                            secondary: selected
                                ? const Icon(
                                    Icons.check,
                                    color: AppColor.primaryColor,
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop<T>(context, null),
                              child: const Text(
                                'Hủy',
                                style: TextStyle(color: AppColor.primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColor.primaryColor,
                              ),
                              onPressed: () => Navigator.pop<T>(context, temp),
                              child: const Text(
                                'Xong',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Nút hiển thị giá trị + mở modal chọn
  Widget _pickerButton({
    required String label,
    required String? valueText,
    required VoidCallback? onPressed,
    double? width,
    bool loading = false,
    String? errorText,
  }) {
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColor.textColor, fontSize: 12)),
        const SizedBox(height: 6),
        loading
            ? const _InlineLoading()
            : (errorText != null
                  ? _InlineError(text: errorText, onRetry: onPressed ?? () {})
                  : SizedBox(
                      width: width ?? 200,
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: onPressed,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                valueText?.isNotEmpty == true
                                    ? valueText!
                                    : '—',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: valueText?.isNotEmpty == true
                                      ? AppColor.textColor
                                      : Colors.black45,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    )),
      ],
    );

    // Nếu disabled (onPressed == null), vẫn render button nhưng tắt
    if (onPressed == null && !loading && errorText == null) {
      return Opacity(opacity: 0.6, child: IgnorePointer(child: child));
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final double itemWidth = 150.w;
    final TextEditingController _streetCtrl = TextEditingController();

    // Province button
    final provinceField = _pickerButton(
      label: widget.provinceLabel,
      valueText: _selectedProvince?.name,
      width: itemWidth,
      loading: _loadingProvince,
      errorText: _errorProvince,
      onPressed: () async {
        final picked = await _showPickerSheet<VietnamAddress>(
          title: widget.provinceLabel,
          items: _provinces,
          current: _selectedProvince,
          labelOf: (p) => p.name,
        );
        if (picked == null) return;
        if (picked.code == _selectedProvince?.code) return;

        setState(() {
          _selectedProvince = picked;

          // Reset dưới
          _districts.clear();
          _selectedDistrict = null;
          _errorDistrict = null;

          _wards.clear();
          _selectedWard = null;
          _errorWard = null;
        });
        widget.onProvinceSelected?.call(picked);

        await _loadDistrictsByProvince(picked.code);
      },
    );

    // District button
    final districtField = _pickerButton(
      label: widget.districtLabel,
      valueText: _selectedDistrict?.name,
      width: itemWidth,
      loading: _loadingDistrict,
      errorText: _errorDistrict,
      onPressed: (_selectedProvince == null)
          ? null
          : () async {
              final picked = await _showPickerSheet<VietnamAddress>(
                title: widget.districtLabel,
                items: _districts,
                current: _selectedDistrict,
                labelOf: (d) => d.name,
              );
              if (picked == null) return;
              if (picked.code == _selectedDistrict?.code) return;

              setState(() {
                _selectedDistrict = picked;

                _wards.clear();
                _selectedWard = null;
                _errorWard = null;
              });
              widget.onDistrictSelected?.call(picked);

              await _loadWardsByDistrict(picked.code);
            },
    );

    // Ward button
    final wardField = _pickerButton(
      label: widget.wardLabel,
      valueText: _selectedWard?.name,
      width: itemWidth,
      loading: _loadingWard,
      errorText: _errorWard,
      onPressed: (_selectedDistrict == null)
          ? null
          : () async {
              final picked = await _showPickerSheet<VietnamAddress>(
                title: widget.wardLabel,
                items: _wards,
                current: _selectedWard,
                labelOf: (w) => w.name,
              );
              if (picked == null) return;
              if (picked.code == _selectedWard?.code) return;

              setState(() => _selectedWard = picked);
              widget.onWardSelected?.call(picked);
            },
    );
    final streetField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ghi địa chỉ cụ thể",
          style: TextStyle(color: AppColor.textColor, fontSize: 12),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 150.w,    
          child: TextFormField(
            cursorColor: AppColor.primaryColor,
            keyboardType: TextInputType.streetAddress,
            style: TextStyle(color: Colors.black),
            controller: _streetCtrl, // ⬅️ dùng controller
            onChanged: widget.onStreetChanged, // ⬅️ bắn ra parent
            textCapitalization: TextCapitalization.words,
            autocorrect: true,
            decoration: InputDecoration(
              hintText: 'Địa chỉ',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black45),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.primaryColor),
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [provinceField, const SizedBox(width: 12), districtField],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [wardField, const SizedBox(width: 12), streetField],
        ),
      ],
    );
  }
}

class _InlineLoading extends StatelessWidget {
  const _InlineLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 48,
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
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
        IconButton(onPressed: onRetry, icon: const Icon(Icons.refresh)),
      ],
    );
  }
}
