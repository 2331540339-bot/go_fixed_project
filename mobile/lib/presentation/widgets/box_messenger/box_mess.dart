import 'package:flutter/material.dart';
import 'package:mobile/config/assets/app_image.dart';
import 'package:mobile/config/themes/app_color.dart';
import 'package:mobile/main.dart';

class BoxMess extends StatelessWidget {
  const BoxMess({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Xử lý khi nhấn vào BoxMess
        debugPrint('BoxMess tapped!');
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisSize: MainAxisSize.min,
            // mainAxisAlignment: MainAxisAlignment.start,
            
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(AppImages.avt_con_meo),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Box Messenger',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.primaryColor),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This is a box messenger widget.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
