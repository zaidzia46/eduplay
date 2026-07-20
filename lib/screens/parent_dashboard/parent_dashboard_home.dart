import 'package:eduplay/screens/parent_dashboard/parentBottomNavController.dart';
import 'package:eduplay/screens/parent_dashboard/parent_dashboard_main/parent_dashboard_screen.dart';
import 'package:eduplay/screens/parent_dashboard/report/report_screen.dart';
import 'package:eduplay/screens/parent_dashboard/settings/settings_screen.dart';
import 'package:eduplay/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ParentDashboardHome extends StatelessWidget {
  ParentDashboardHome({super.key});

  final vm = Get.find<ParentBottomNavController>();

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
          return IndexedStack(
            index: vm.currentIndex.value,
            children: [
              ParentDashboardScreen(),
              ReportScreen(),
              SettingsScreen(),
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
                  icon: FaIcon(FontAwesomeIcons.house, size: 20),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.chartLine, size: 20),
                  label: 'Report',
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.gear, size: 20),
                  label: 'Setting',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
