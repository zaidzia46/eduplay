import 'package:eduplay/screens/dashboard.dart';
import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:eduplay/routes/app_routes.dart';

import 'package:eduplay/screens/splash/splash_screen.dart';
import '../bindings/onboarding_binding.dart';
import '../screens/onboarding/age_view.dart';
import '../screens/onboarding/ready_view.dart';
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
      transitionDuration: const Duration(milliseconds: 200), // ← add this
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.onboardingReady,
      page: () => ReadyView(),
      binding: OnboardingBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200), // ← add this
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashBoard(),
      binding: OnboardingBinding(),
    ),
  ];
}
