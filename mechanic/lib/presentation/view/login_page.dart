import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mechanic/common/app_button.dart';
import 'package:mechanic/config/assets/app_image.dart';
import 'package:mechanic/config/themes/app_color.dart';
import 'package:mechanic/presentation/controllers/user_controller.dart';
import 'package:mechanic/presentation/view/main_tabs.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  UserController? _userCtrl;
  bool _ctrlReady = false;

  @override
  void initState() {
    super.initState();
    _initCtrl();
  }

  Future<void> _initCtrl() async {
    _userCtrl = await UserController.create();

    if (!mounted) return;
    setState(() => _ctrlReady = true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
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
                  'Log In',
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
                // SizedBox(height: 5.h),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forget password",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      content: 'Log In',
                      onPressed: _loading
                          ? null
                          : () async {
                              if (!_ctrlReady || _userCtrl == null) {
                                _showSnack('Đang khởi tạo, vui lòng chờ…');
                                return;
                              }
                              final email = _emailController.text.trim();
                              final pwd = _pwdController.text;
                              if (email.isEmpty || pwd.isEmpty) {
                                _showSnack('Vui lòng nhập email và mật khẩu');
                                return;
                              }

                              FocusScope.of(context).unfocus();
                              setState(() => _loading = true);
                              try {
                                final ok = await _userCtrl!.login(
                                  email: email,
                                  password: pwd,
                                );

                                if (!context.mounted) return;

                                if (ok) {
                                  // 💡 LẤY ID TỪ INSTANCE CỦA CONTROLLER SAU KHI ĐĂNG NHẬP THÀNH CÔNG
                                  final mechanicId = _userCtrl!.currentUserId;

                                  if (mechanicId != null) {
                                    // Điều hướng và truyền ID thợ
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => MainTabs(mechanicId: mechanicId),
                                      ),
                                      (route) => false,
                                    );
                                  } else {                                  
                                    _showSnack(
                                      'Đăng nhập thành công, nhưng không tìm thấy ID.',
                                    );
                                  }
                                } else {
                                  final msg =
                                      _userCtrl!.lastError ??
                                      'Đăng nhập thất bại. Vui lòng kiểm tra thông tin.';
                                  _showSnack(msg);
                                }
                              } catch (e) {
                                if (context.mounted) _showSnack(e.toString());
                              } finally {
                                if (context.mounted)
                                  setState(() => _loading = false);
                              }
                            },
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: [
                      Expanded(
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
                        ), // dòng chữ ở giữa
                      ),
                      Expanded(
                        child: Divider(thickness: 1, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Orther(
                      onTap: () {
                        /* TODO */
                      },
                      child: Image.asset(
                        AppImages.img_google,
                        width: 0.5.sw, // 60% chiều rộng màn hình
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 20),
                    _Orther(
                      onTap: () {
                        /* TODO */
                      },
                      child: Image.asset(
                        AppImages.img_facebook,
                        width: 0.5.sw, // 60% chiều rộng màn hình
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

  Widget _textFieldEmail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          color: Color(0xffFFEEDF),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(0, 1),
              blurRadius: 10,
              spreadRadius: -5,
            ),
          ],
        ),
        child: TextField(
          controller: _emailController,
          cursorColor: AppColor.primaryColor,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email_outlined, color: AppColor.textColor),
            hintText: 'Nhập email',
            hintStyle: TextStyle(color: Colors.black),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black26),
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
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffFFEEDF),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(0, 1),
              blurRadius: 10,
              spreadRadius: -5,
            ),
          ],
        ),
        child: TextField(
          controller: _pwdController,
          cursorColor: AppColor.primaryColor,
          style: TextStyle(color: Colors.black),
          obscureText: _obscure,
          decoration: InputDecoration(
            hintText: "PassWord",
            hintStyle: TextStyle(color: Colors.black),
            prefixIcon: Icon(Icons.key_sharp, color: AppColor.textColor),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
                color: AppColor.textColor,
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Center(child: child ?? const Icon(Icons.more_horiz)),
    );
  }
}
