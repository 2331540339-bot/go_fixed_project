import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/config/themes/app_color.dart';
import 'package:mobile/presentation/model/vietnam_address.dart';
import 'package:mobile/api/vietnam_address_api.dart';

class AddressSearchField extends StatefulWidget {
  final Function(VietnamAddress?) onAddressSelected;
  final String hintText;
  final TextEditingController? controller;

  const AddressSearchField({
    super.key,
    required this.onAddressSelected,
    this.hintText = 'Tìm kiếm địa chỉ...',
    this.controller,
  });

  @override
  State<AddressSearchField> createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  late final TextEditingController _ctl;
  final _focusNode = FocusNode();
  final _fieldKey = GlobalKey(); // NEW: đo size TextField

  // overlay
  final _link = LayerLink();
  OverlayEntry? _listEntry;
  OverlayEntry? _barrierEntry;

  // state
  Timer? _debounce;
  bool _loading = false;
  List<VietnamAddress> _results = [];

  @override
  void initState() {
    super.initState();
    _ctl = widget.controller ?? TextEditingController();
    _focusNode.addListener(_onFocus);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _focusNode.removeListener(_onFocus);
    _focusNode.dispose();
    if (widget.controller == null) _ctl.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (_focusNode.hasFocus && _results.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      final query = q.trim().toLowerCase();

      if (query.length < 2) {
        // NEW: ngưỡng 2 ký tự
        setState(() => _results = []);
        _removeOverlay();
        return;
      }

      setState(() => _loading = true);
      try {
        final rs = await VietnamAddressApi.searchAllAdministrativeLevels(query);
        if (!mounted) return;
        setState(() {
          _results = rs;
          _loading = false;
        });
        if (_focusNode.hasFocus && _results.isNotEmpty) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _results = [];
          _loading = false;
        });
        _removeOverlay();
      }
    });
  }

  void _select(VietnamAddress addr) {
    _ctl.text = addr.fullLabel; // hiển thị đẹp
    _removeOverlay();
    widget.onAddressSelected(addr);
    _focusNode.unfocus();
  }

  // ===== Overlay helpers =====
  void _showOverlay() {
    _removeOverlay();

    // barrier để click ra ngoài đóng popup
    _barrierEntry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _removeOverlay,
        ),
      ),
    );

    // danh sách gợi ý
    _listEntry = OverlayEntry(
      builder: (context) {
        // đo kích thước TextField bằng CompositedTransformTarget/Follower
        return CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          offset: const Offset(0, 52), // cách dưới TextField
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280, minWidth: 280),
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final a = _results[i];
                        return ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.location_on,
                            size: 20,
                            color: Colors.blue,
                          ),
                          title: Text(
                            a.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            a.subLabel, // ví dụ “Quận/Huyện • Tỉnh/Thành”
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          onTap: () => {_select(a)},
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );

    final overlay = Overlay.of(context, rootOverlay: true);
    overlay.insertAll([_barrierEntry!, _listEntry!]);
  }

  void _removeOverlay() {
    _listEntry?..remove();
    _barrierEntry?..remove();
    _listEntry = null;
    _barrierEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: TextField(
        key: _fieldKey, // NEW
        controller: _ctl,
        focusNode: _focusNode,
        onChanged: _onChanged,
        onTap: () {
          if (_results.isNotEmpty) _showOverlay();
        },
        textInputAction: TextInputAction.search, // optional
        onSubmitted: (_) {
          if (_results.isNotEmpty)
            _select(_results.first); // Enter để chọn gợi ý đầu tiên
        },
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : const Icon(Icons.search, color: Colors.black),
          suffixIcon: _ctl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black),
                  onPressed: () {
                    _ctl.clear();
                    setState(() => _results = []);
                    _removeOverlay();
                    widget.onAddressSelected(null);
                  },
                )
              : null,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black26),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColor.primaryColor),
          ),
        ),
      ),
    );
  }
}
