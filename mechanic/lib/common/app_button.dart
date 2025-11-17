import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mechanic/config/themes/app_color.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.content, this.onPressed,  this.isLoading = false,});
 final String content;
  final VoidCallback? onPressed;
  final bool isLoading;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(20),
        foregroundColor: Colors.white,
        backgroundColor: AppColor.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
       onPressed: isLoading ? null : onPressed,   
      child: Text(
        content,
        textAlign: TextAlign.center, // chữ ở giữa
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp),
      ),
    );
  }
}

class AppButtonReverse extends StatelessWidget {
  const AppButtonReverse({
    super.key,
    required this.content,
    required this.onPressed,
  });
  final String content;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(20),
        foregroundColor: AppColor.primaryColor,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: AppColor.primaryColor, width: 1.5),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        content,
        textAlign: TextAlign.center, // chữ ở giữa
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
      ),
    );
  }
}
