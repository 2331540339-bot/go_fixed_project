import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile/config/themes/app_color.dart';
import 'package:mobile/presentation/controller/location_controller.dart';
import 'package:mobile/presentation/view/home/home_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/presentation/view/loction/location_page.dart';
import 'package:mobile/presentation/view/messenger/inbox_page.dart';
import 'package:mobile/presentation/view/setting/settings_page.dart';
import 'package:mobile/presentation/view/store/store_page.dart';
import 'package:provider/provider.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  int _index = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    context.read<LocationController>().ensureStarted();
    _pages = [
      HomePage(
        onGoToLocation: () => setState(() => _index = 3),
      ),
      const StorePage(),
      const InboxPage(),
      const LocationPage(),
      const SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true, // để nav bar "nổi" trên nền mờ
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 15.h),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.08),
            //     blurRadius: 24,
            //     offset: const Offset(0, 8),
            //   ),
            // ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Theme(
                data: Theme.of(context).copyWith(
                  navigationBarTheme: NavigationBarThemeData(
                    // Màu + style LABEL
                    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
                      states,
                    ) {
                      final selected = states.contains(WidgetState.selected);
                      return TextStyle(
                        fontSize: selected ? 12.sp : 11.sp,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? AppColor.primaryColor
                            : Colors.white.withOpacity(0.9),
                      );
                    }),
                  ),
                ),
                child: NavigationBar(
                  height: 40.h,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  indicatorColor: AppColor.primaryColor,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined, color: Color(0xff000000)),
                      selectedIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.storefront_outlined, color: Color(0xff000000)),
                      selectedIcon: Icon(Icons.storefront_rounded),
                      label: 'Store',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.message_outlined,
                        color: Color(0xff000000),
                      ),
                      selectedIcon: Icon(Icons.message),
                      label: 'message',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.location_on_outlined,
                        color: Color(0xff000000),
                      ),
                      selectedIcon: Icon(Icons.location_on),
                      label: 'location',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.person_outline,
                        color: Color(0xff000000),
                      ),
                      selectedIcon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
