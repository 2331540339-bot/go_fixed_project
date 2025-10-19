import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/common/app_button.dart';
import 'package:mobile/config/themes/app_color.dart';

class Intropage extends StatelessWidget {
  const Intropage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "MECHANIC",
                    style: TextStyle(
                      color: AppColor.primaryColor,
                      fontFamily: "Jaro",
                      fontSize: 64.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '“Giải pháp cứu hộ chỉ với một chạm”',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColor.textColor, fontSize: 24.sp),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 50),
                child: SizedBox(
                  // đảm bảo có width hữu hạn cho Row
                  width: 100.w,
                  child: Expanded(child: AppButton(content: "Login", onPressed: () {})),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
