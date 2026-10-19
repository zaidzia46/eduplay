import 'package:eduplay/screens/parent_main/parent_dashboard/parent_dashboard_screen.dart';
import 'package:eduplay/screens/parent_main/parent_settings/parent_settings_screen.dart';
import 'package:eduplay/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/supabase_client.dart';
import '../../widgets/sign_in_prompt.dart';
import 'app_dashboard/app_dashboard_screen.dart';
import 'bottom_nav_bar/bottom_nav_bar_controller.dart';

/// The public app shell: a 3-tab bottom nav whose tabs live on ONE route
/// (`/parent-home`). Tab 0 is the logged-out landing, so the route itself is
/// public — the two account-only tabs are gated per-tap by
/// [ParentBottomNavController] and simply aren't built while signed out.
class ParentHome extends StatelessWidget {
  ParentHome({super.key});

  final vm = Get.find<ParentBottomNavController>();

  @override
  Widget build(context) {
    return Obx(() {
      final index = vm.currentIndex.value;

      // Only construct the account-only tabs when there IS a session —
      // otherwise their controllers' `onInit` would fire a signed-out fetch
      // (`IndexedStack` builds every child, not just the visible one).
      final loggedIn = supabase.auth.currentSession != null;

      final screens = <Widget>[
        AppDashboardView(),
        if (loggedIn) ParentDashboardView() else const SignInPlaceholder(),
        if (loggedIn) ParentSettingsView() else const SignInPlaceholder(),
      ];

      return PopScope(
        // Back on the landing tab leaves the app; on any other tab it first
        // returns to the landing tab.
        canPop: index == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && index != 0) {
            vm.changePage(0);
          }
        },
        child: Scaffold(
          body: IndexedStack(index: index, children: screens),
          bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BottomNavigationBar(
              currentIndex: index,
              onTap: vm.changePage,
              fixedColor: AppColors.white,
              backgroundColor: AppColors.primary,
              unselectedItemColor: const Color(0xffD1C4E9),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_sharp),
                  label: 'Parent',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
