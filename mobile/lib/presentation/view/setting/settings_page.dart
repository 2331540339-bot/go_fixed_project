import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/config/assets/app_image.dart';
import 'package:mobile/presentation/controller/location_controller.dart';
import 'package:mobile/presentation/controller/user_controller.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  XFile? _imageFile;
  UserController? _userCtrl;
  String _name = '...';
  bool _loadingName = true;
  String _email = '...';
  String _phone = '...';

  @override
  void initState() {
    super.initState();
    context.read<LocationController>().ensureStarted();
    _initControllers();
  }

  Future<void> _initControllers() async {
    // 1. Khởi tạo Controllers
    _userCtrl = await UserController.create();
    if (!mounted) return;

    // 2. Xử lý Tên người dùng (Ưu tiên)
    await _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final n = await _userCtrl!.getProfile();
      if (!mounted) return;
      setState(() {
        _name = n!.fullname;
        _loadingName = false;
        _email = n.email;
        _phone = n.phone;
        // _address = n.address ?? 'Chưa cập nhật';
      });
    } catch (e) {
      if (!mounted) return;

      debugPrint('LỖI KHI TẢI TÊN NGƯỜI DÙNG: $e');
      final error = e.toString().toLowerCase();
      if (error.contains('401') ||
          error.contains('unauthorized') ||
          error.contains('not authenticated')) {}

      setState(() {
        _name = 'Chưa đăng nhập';
        _email = 'Chưa đăng nhập';
        _phone = 'Chưa đăng nhập';
        // _address = 'Chưa đăng nhập';
        _loadingName = false;
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
  Widget build(BuildContext context) {
    final locationCtrl = context.watch<LocationController>();
    final addressText =
        locationCtrl.loading ? 'Đang tải...' : (locationCtrl.error ?? locationCtrl.currentAddress);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: InkWell(
                onTap: () {
                  debugPrint('Avatar tapped');
                  _openGallery();
                },
                child: CircleAvatar(
                  radius: 100,

                  backgroundImage: _imageFile != null
                      ? FileImage(File(_imageFile!.path)) as ImageProvider
                      : AssetImage(AppImages.avt_con_meo),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      debugPrint('Name tapped');
                    },
                    child: Text(
                      'Name: $_name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      debugPrint('Email tapped');
                    },
                    child: Text(
                      'Email: $_email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      debugPrint('Phone tapped');
                    },
                    child: Text(
                      'Phone: $_phone',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Address: $addressText",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
