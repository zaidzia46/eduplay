import 'package:eduplay/screens/home/child_profile/profile.dart';
import 'package:eduplay/screens/home/progress/progress.dart';
import 'package:eduplay/screens/home/subjects/subjects.dart';
import 'package:eduplay/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'bottom_nav/bottomNavigation_controller.dart';
import 'dashboard/dashboard.dart';

//okay for now we are using built once functionality to improve navigation speed.
// We are keeping this until we integrate real APIs to test how much delay it cause.
// After that if this things won't work right, we'll replace it with loader on profile and
// showing that your profile is being set up. Also can cache the data later for better performance.

class Home extends StatelessWidget {
  Home({super.key});

  final vm = Get.find<BottomNavController>();
  final List<bool> _builtOnce = [true, false, false, false];
  final List<Widget> _screens = [
    DashBoard(),
    SubjectView(),
    ProgressView(),
    ProfileView(),
  ];

  Future<bool> _handleBackPressed() async {
    if (vm.currentIndex.value != 0) {
      vm.changePage(0);
      return false;
    }
    return true;
  }

  Widget build(context) {
    return WillPopScope(
      onWillPop: _handleBackPressed,
      child: Scaffold(
        body: Obx(() {
          final index = vm.currentIndex.value;
          _builtOnce[index] = true;
          return IndexedStack(
            index: vm.currentIndex.value,
            children: List.generate(_screens.length, (i) {
              return _builtOnce[i] ? _screens[i] : const SizedBox.shrink();
            }),
          );
        }),

        bottomNavigationBar: Obx(
          () => ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BottomNavigationBar(
              currentIndex: vm.currentIndex.value,
              onTap: (index) => vm.changePage(index),
              fixedColor: AppColors.white,
              backgroundColor: AppColors.primary,
              unselectedItemColor: Color(0xffD1C4E9),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_sharp),
                  label: 'Subjects',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events),
                  label: 'Progress',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
