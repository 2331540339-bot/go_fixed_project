import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mechanic/common/app_button.dart';
import 'package:mechanic/config/assets/app_image.dart';
import 'package:mechanic/config/themes/app_color.dart';

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
                child: AppButton(content: "Sign In Here", onPressed: () { 
                  // Navigator.push(context, MaterialPageRoute(builder: (_)=> const LoginPage()));
                }),
              ),
            ),
            SizedBox(height: 20),
          
          ],
        ),
      ),
    );
  }
}
