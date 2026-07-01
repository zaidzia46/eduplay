import 'package:eduplay/screens/dashboard.dart';
import 'package:get/get.dart';
import 'package:eduplay/routes/app_routes.dart';

import 'package:eduplay/screens/splash/splash_screen.dart';
import '../bindings/onboarding_binding.dart';
import '../screens/onboarding/age_view.dart';
import '../screens/onboarding/level_view.dart';
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
    ),
    GetPage(
      name: AppRoutes.onboardingLevel,
      page: () => Level(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashBoard(),
      // binding: OnboardingBinding(),
    ),
  ];
}
