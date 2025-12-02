import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/config/assets/app_image.dart';
import 'package:mobile/config/themes/app_color.dart';
import 'package:mobile/presentation/controller/rescue_flow_controller.dart';
import 'package:mobile/presentation/view/loction/detail_price_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  static const _red = TextStyle(color: AppColor.primaryColor);
  static const _back = TextStyle(color: Colors.black);

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final _searchCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  XFile? _imageFile;
  SharedPreferences? _sp;
  TextStyle get _baseTitle => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    fontFamily: 'AROneSans',
  );
  String? value1 = 'Nhà sản xuất';
  String? value2 = 'B';
  String? value3 = 'C';
  List<String> items = ['hãng xe', 'loại xe', 'năm sản xuất'];
  String? _selected;

  Widget _titleLine(List<InlineSpan> spans) => Text.rich(
    TextSpan(style: _baseTitle, children: spans),
    textAlign: TextAlign.center,
    maxLines: 2,
  );

  Future<void> _openCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _imageFile = photo;
      });
    }
  }

  Future<void> _openGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    _descCtl.dispose();
    _phoneCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 80.h,
          leadingWidth: 100.w,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: EdgeInsets.only(left: 12.r),
            child: Image.asset(AppImages.mainLogo, height: 100.h, width: 40.w),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _titleLine(const [
                TextSpan(text: 'KHÔNG ', style: ServicesPage._red),
                TextSpan(text: 'PHẢI ', style: ServicesPage._back),
                TextSpan(text: 'CUỐC BỘ', style: ServicesPage._red),
              ]),
              _titleLine(const [
                TextSpan(text: 'ĐÃ CÓ ', style: ServicesPage._back),
                TextSpan(text: 'MECHANIC ', style: ServicesPage._red),
                TextSpan(text: 'LO !', style: ServicesPage._back),
              ]),
            ],
          ),
        ),

        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtl,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: AppColor.primaryColor,
                        onChanged: (q) {
                          /* TODO filter */
                        },
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm...',
                          hintStyle: const TextStyle(color: Colors.black38),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                          suffixIcon: _searchCtl.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    _searchCtl.clear();
                                    setState(() {});
                                  },
                                ),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColor.primaryColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black26),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      child: ElevatedButton(
                        onPressed: () {
                          /* mở filter nâng cao */
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffF3F8FB),
                          foregroundColor: Colors.white,
                          side: BorderSide(color: AppColor.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(48, 48),
                          padding: EdgeInsets.zero,
                        ),
                        child: Icon(
                          Icons.location_on,
                          size: 16.h,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _dropMenu(
                        value: value1,
                        items: items,
                        onChanged: (v) => setState(() => value1 = v),
                        hint: 'Hãng xe',
                      ),
                      const SizedBox(width: 5),
                      _dropMenu(
                        value: value2,
                        items: items,
                        onChanged: (v) => setState(() => value2 = v),
                        hint: 'Loại xe',
                      ),
                      const SizedBox(width: 5),
                      _dropMenu(
                        value: value3,
                        items: items,
                        onChanged: (v) => setState(() => value3 = v),
                        hint: 'Năm sản xuất',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                _fieldPhone('Số điện thoại liên hệ'),
                SizedBox(height: 12.h),
                _fieldDescribe('Hãy mô tả'),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Container(
                            // width: double.infinity,
                            width: 150.w,
                            height: 150.h,
                            // color: Colors.black,
                            decoration: BoxDecoration(
                              color: const Color(0xffEDEDED),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: InkWell(
                              onTap: _openGallery,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: _imageFile == null
                                      ? null
                                      : DecorationImage(
                                          image: FileImage(
                                            File(_imageFile!.path),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                child: _imageFile == null
                                    ? Icon(
                                        Icons.camera,
                                        size: 50.sp,
                                        color: Colors.black38,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: SizedBox(
                            child: IconButton(
                              onPressed: () {
                                debugPrint('Remove image');
                                setState(() {
                                  _imageFile = null;
                                });
                              },
                              icon: Icon(Icons.cancel),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 100.w,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                        ),
                        onPressed: () {
                          _openCamera();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Icon(
                            Icons.camera_enhance,
                            color: Colors.black54,
                            size: 30.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // shape: CircleBorder(),
                        backgroundColor: AppColor.primaryColor,
                      ),
                      onPressed: () async {
                        final flow = context.read<RescueFlowController>();
                        final phone = _phoneCtl.text.trim();
                        if (phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Vui lòng nhập số điện thoại để liên hệ.'),
                            ),
                          );
                          return;
                        }

                        // Đảm bảo người dùng đã xác nhận vị trí
                        if (flow.location == null || flow.detailAddress == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vui lòng xác nhận vị trí trước khi gửi.'),
                            ),
                          );
                          return;
                        }

                        final description = _descCtl.text.trim();

                        // Chuẩn bị danh sách ảnh dưới dạng base64 (tối đa 1 ảnh hiện tại)
                        final images = <String>[];
                        if (_imageFile != null) {
                          final bytes = await _imageFile!.readAsBytes();
                          images.add(base64Encode(bytes));
                        }

                        flow
                          ..setPhone(phone)
                          ..setDescription(description)
                          ..setImages(images);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DetailPricePage(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Text(
                          'Gửi yêu cầu',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropMenu({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? hint,
    double minWidth = 120, // tuỳ chỉnh: bề ngang tối thiểu
  }) {
    return IntrinsicWidth(
      // 👈 co theo kích thước nội tại của con
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth),
        child: DropdownButtonFormField<String>(
          value: (value != null && items.contains(value)) ? value : null,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          isDense: true,
          isExpanded: false, // 👈 đừng bắt nó giãn hết ngang
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.black,
          ),
          style: const TextStyle(fontSize: 14, color: Colors.black),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            filled: true,
            fillColor: const Color(0xffF3F8FB),
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.black38,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black26),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.primaryColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldPhone(String hint) {
    return TextField(
      controller: _phoneCtl,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: Colors.black),
      cursorColor: Colors.black87,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.black54),
        prefixIcon: const Icon(Icons.phone, color: Colors.black54),
        filled: true,
        fillColor: const Color(0xffF3F8FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.primaryColor),
        ),
      ),
    );
  }

  Widget _fieldDescribe(String hint) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xffEDEDED),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: _descCtl,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        minLines: 4, // số dòng tối thiểu
        maxLines: 8, // số dòng tối đa (đủ dùng)
        // hoặc dùng expands: true nếu muốn ô tự giãn đầy chiều cao Container
        style: const TextStyle(color: Colors.black),
        cursorColor: Colors.black87,
        decoration: InputDecoration(
          isDense: true,
          hintText: hint, // ví dụ: "Mô tả sự cố của bạn..."
          hintStyle: const TextStyle(color: Colors.black45),
          border: InputBorder.none, // bỏ viền mặc định
          // contentPadding bỏ qua vì ta đã padding ở Container
        ),
      ),
    );
  }
}
