import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:eduplay/routes/app_routes.dart';

import 'package:eduplay/screens/splash/splash_screen.dart';

import '../screens/home/bottom_nav/bottomNavbar_bin.dart';
import '../screens/home/dashboard/dashboard_bin.dart';
import '../screens/home/home.dart';
import '../screens/home/topics/topic_bin.dart';
import '../screens/home/topics/topic_screen.dart';
import '../screens/onboarding/onboarding_bin.dart';
import '../screens/onboarding/onborading_screens/age_view.dart';
import '../screens/onboarding/onborading_screens/name_view.dart';
import '../screens/onboarding/onborading_screens/standard_view.dart';

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

    GetPage(
      name: AppRoutes.topics,
      page: () => TopicScreen(),
      binding: TopicBinding(),
    ),
  ];
}
