import 'package:flutter/material.dart';
import 'package:mechanic/config/themes/app_color.dart';
import 'package:mechanic/presentation/view/home_page.dart';
import 'package:mechanic/presentation/view/request_page.dart';
import 'package:mechanic/presentation/view/setting_page.dart';

class MainTabs extends StatefulWidget {
  final String mechanicId;
  const MainTabs({super.key, required this.mechanicId});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(mechanicId: widget.mechanicId),
      RequestPage(mechanicId: widget.mechanicId),
      SettingPage(mechanicId: widget.mechanicId),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: AppColor.primaryColor,
          unselectedItemColor: Colors.grey.shade500,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              label: 'Yêu cầu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
    );
  }
}
