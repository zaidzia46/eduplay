import 'package:eduplay/screens/home/subjects/subjects.dart';
import 'package:eduplay/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bottom_nav/bottomNavigation_controller.dart';
import 'dashboard/dashboard.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final vm = Get.find<BottomNavController>();

  @override
  Widget build(context) {
    return Scaffold(
      body: Obx(() {
        return IndexedStack(
          index: vm.currentIndex.value,
          children: [DashBoard(), Subject()],
        );
      }),

      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: vm.currentIndex.value,
          onTap: (index) => vm.changePage(index),
          fixedColor: AppColors.primary,
          backgroundColor: AppColors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Subjects'),
          ],
        ),
      ),
    );
  }
}
