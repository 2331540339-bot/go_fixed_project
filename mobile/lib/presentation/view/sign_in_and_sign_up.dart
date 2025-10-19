import 'package:flutter/material.dart';
import 'package:mobile/common/app_button.dart';
import 'package:mobile/config/assets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/config/themes/app_color.dart';

class SignInAndSignUp extends StatelessWidget {
  const SignInAndSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.Logo_in_up,
              width: 0.5.sw, // 60% chiều rộng màn hình
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: SizedBox(
                width: double.infinity,
                child: AppButton(content: "Sign In Here", onPressed: () {}),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: SizedBox(
                width: double.infinity,
                child: AppButtonReverse(
                  content: "Sign Up Now",
                  onPressed: () {},
                ),
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Expanded(child: Divider(thickness: 1, color: Colors.black)),
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
                  Expanded(child: Divider(thickness: 1, color: Colors.black)),
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
    );
  }

  Widget _Orther({required VoidCallback onTap, Widget? child}) {
    return RawMaterialButton(
      onPressed: () {},
      fillColor: const Color(0xffD9D9D9),
      constraints: const BoxConstraints.tightFor(width: 50, height: 50),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Center(child: child ?? const Icon(Icons.more_horiz)),
    );
  }
}
