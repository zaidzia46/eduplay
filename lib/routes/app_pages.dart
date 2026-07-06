import 'package:eduplay/bindings/bottomNavbar_bin.dart';
import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:eduplay/routes/app_routes.dart';

import 'package:eduplay/screens/splash/splash_screen.dart';
import '../bindings/dashboard_bin.dart';
import '../bindings/onboarding_bin.dart';
import '../screens/home.dart';
import '../screens/onboarding/age_view.dart';
import '../screens/onboarding/standard_view.dart';
import '../screens/onboarding/name_view.dart';

abstract class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.onboardingName,
      page: () => Name(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.onboardingAge,
      page: () => Age(),
      binding: OnboardingBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 400), // ← add this
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.onboardingReady,
      page: () => StandardView(),
      binding: OnboardingBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 400), // ← add this
      curve: Curves.easeInOut,
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => Home(),
      binding: BindingsBuilder(() {
        BottomNavBinding().dependencies();
        DashboardBinding().dependencies();
      }),
    ),
  ];
}
