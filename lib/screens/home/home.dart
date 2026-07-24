import 'package:eduplay/screens/home/profile.dart';
import 'package:eduplay/screens/home/progress/progress.dart';
import 'package:eduplay/screens/home/subjects/subjects.dart';
import 'package:eduplay/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'bottom_nav/bottomNavigation_controller.dart';
import 'dashboard/dashboard.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final vm = Get.find<BottomNavController>();

  Future<bool> _handleBackPressed() async {
    if (vm.currentIndex.value != 0) {
      vm.changePage(0);
      return false;
    }
    return true;
  }

  @override
  Widget build(context) {
    return WillPopScope(
      onWillPop: _handleBackPressed,
      child: Scaffold(
        body: Obx(() {
          final visited = vm.visitedIndices;

          return IndexedStack(
            index: vm.currentIndex.value,
            children: [
              visited.contains(0) ? DashBoard() : const SizedBox.shrink(),
              visited.contains(1) ? SubjectView() : const SizedBox.shrink(),
              visited.contains(2) ? ProgressView() : const SizedBox.shrink(),
              visited.contains(3) ? ProfileView() : const SizedBox.shrink(),
            ],
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
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.warehouse, size: 20),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.book, size: 20),
                  label: 'Subjects',
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.trophy, size: 20),
                  label: 'Progress',
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.person, size: 20),
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
