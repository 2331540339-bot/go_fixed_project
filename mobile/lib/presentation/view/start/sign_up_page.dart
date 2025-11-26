import 'package:flutter/material.dart';
import 'package:mobile/common/app_button.dart';
import 'package:mobile/config/assets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/config/themes/app_color.dart';
import 'package:mobile/presentation/controller/user_controller.dart';
import 'package:mobile/presentation/view/start/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _passCtl = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  UserController? _userCtrl;
  bool _ctrlReady = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    _userCtrl = await UserController.create();
    if (!mounted) return;
    setState(() {
      _ctrlReady = true;
    });
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _onRegisterPressed() async {
    if (!_ctrlReady || _userCtrl == null) {
      _showSnack('Đang khởi tạo, vui lòng chờ…');
      return;
    }

    final email = _emailCtl.text.trim();
    final pwd = _passCtl.text;
    final name = _nameCtl.text.trim();
    final phone = _phoneCtl.text.trim();

    if (email.isEmpty || pwd.isEmpty || name.isEmpty || phone.isEmpty) {
      _showSnack('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    FocusScope.of(context).unfocus(); // ẩn bàn phím

    setState(() => _loading = true);
    try {
      final ok = await _userCtrl!.register(
        email: email,
        password: pwd,
        fullname: name,
        phone: phone,
      );

      if (!mounted) return;

      if (ok) {
        _showSnack('Đăng ký thành công, vui lòng đăng nhập!');
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
        );
      } else {
        _showSnack('Đăng ký thất bại (server trả ok=false).');
      }
    } catch (e) {
      _showSnack('Đăng ký thất bại: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Image.asset(
                      AppImages.img_login,
                      width: 279.w,
                      height: 279.h,
                    ),
                    Positioned(
                      bottom: 50,
                      right: 0,
                      child: Image.asset(
                        AppImages.img_man,
                        width: 187.w,
                        height: 187.h,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  'Register',
                  style: TextStyle(
                    color: AppColor.primaryColor,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 20.h),
                _textFieldEmail(context),
                SizedBox(height: 20.h),
                _textFieldPwd(context),
                SizedBox(height: 20.h),
                _textFieldName(context),
                SizedBox(height: 20.h),
                _textFieldPhone(context),
                SizedBox(height: 20.h),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      content: 'Register',
                      onPressed: _loading ? null : _onRegisterPressed,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Divider(thickness: 1, color: Colors.black),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "Sign In With",
                          style: TextStyle(
                            color: AppColor.textColor,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(thickness: 1, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Orther(
                      onTap: () {
                        /* TODO */
                      },
                      child: Image.asset(
                        AppImages.img_google,
                        width: 0.5.sw,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 20),
                    _Orther(
                      onTap: () {
                        /* TODO */
                      },
                      child: Image.asset(
                        AppImages.img_facebook,
                        width: 0.5.sw,
                        fit: BoxFit.cover,
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

  // ==== CÁC TEXTFIELD ====

  Widget _textFieldEmail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xffFFEEDF),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(0, 1),
              blurRadius: 10,
              spreadRadius: -5,
            ),
          ],
        ),
        child: TextField(
          controller: _emailCtl,
          cursorColor: AppColor.primaryColor,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            prefixIcon:
                Icon(Icons.email_outlined, color: AppColor.textColor),
            hintText: 'Nhập email',
            hintStyle: const TextStyle(color: Colors.black),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black26),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColor.primaryColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textFieldPwd(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffFFEEDF),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(0, 1),
              blurRadius: 10,
              spreadRadius: -5,
            ),
          ],
        ),
        child: TextField(
          controller: _passCtl,
          cursorColor: AppColor.primaryColor,
          style: const TextStyle(color: Colors.black),
          obscureText: _obscure,
          decoration: InputDecoration(
            hintText: "PassWord",
            hintStyle: const TextStyle(color: Colors.black),
            prefixIcon: Icon(Icons.key_sharp, color: AppColor.textColor),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
                color: AppColor.textColor,
              ),
            ),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.primaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textFieldName(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffFFEEDF),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(0, 1),
              blurRadius: 10,
              spreadRadius: -5,
            ),
          ],
        ),
        child: TextField(
          controller: _nameCtl,
          cursorColor: AppColor.primaryColor,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: "Name",
            hintStyle: const TextStyle(color: Colors.black),
            prefixIcon: Icon(Icons.person, color: AppColor.textColor),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.primaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textFieldPhone(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffFFEEDF),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(0, 1),
              blurRadius: 10,
              spreadRadius: -5,
            ),
          ],
        ),
        child: TextField(
          controller: _phoneCtl,
          cursorColor: AppColor.primaryColor,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: "Phone",
            hintStyle: const TextStyle(color: Colors.black),
            prefixIcon: Icon(Icons.phone, color: AppColor.textColor),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.primaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _Orther({required VoidCallback onTap, Widget? child}) {
    return RawMaterialButton(
      onPressed: onTap,
      fillColor: const Color(0xffD9D9D9),
      constraints: const BoxConstraints.tightFor(width: 50, height: 50),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(child: child ?? const Icon(Icons.more_horiz)),
    );
  }
}
