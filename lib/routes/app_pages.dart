import 'package:eduplay/screens/home/progress/progress_bin.dart';
import 'package:get/get.dart';
import 'package:eduplay/routes/app_routes.dart';

import 'package:eduplay/screens/splash/splash_screen.dart';

import '../screens/auth/auth_binding.dart';
import '../screens/auth/login.dart';
import '../screens/auth/register.dart';
import '../screens/home/bottom_nav/bottomNavbar_bin.dart';
import '../screens/home/dashboard/dashboard_bin.dart';
import '../screens/home/home.dart';
import '../screens/home/progress/progress.dart';
import '../screens/home/topics/topic_bin.dart';
import '../screens/home/topics/topic_screen.dart';
import '../screens/onboarding/onboarding_bin.dart';
import '../screens/onboarding/onborading_screens/age_view.dart';
import '../screens/onboarding/onborading_screens/name_view.dart';
import '../screens/onboarding/onborading_screens/standard_view.dart';
import '../screens/parent_settings/parent_settings_bin.dart';
import '../screens/parent_settings/parent_settings_screen.dart';
import '../screens/profile/create_child_profile/create_child_profile_bin.dart';
import '../screens/profile/create_child_profile/create_child_profile_screen.dart';
import '../screens/profile/profile_switcher/profile_switcher_bin.dart';
import '../screens/profile/profile_switcher/profile_switcher_screen.dart';

abstract class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    // GetPage(
    //   name: AppRoutes.onboardingName,
    //   page: () => Name(),
    //   binding: OnboardingBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.onboardingAge,
    //   page: () => Age(),
    //   binding: OnboardingBinding(),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: const Duration(milliseconds: 400), // ← add this
    //   curve: Curves.easeInOut,
    // ),
    // GetPage(
    //   name: AppRoutes.onboardingReady,
    //   page: () => StandardView(),
    //   binding: OnboardingBinding(),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: const Duration(milliseconds: 400), // ← add this
    //   curve: Curves.easeInOut,
    // ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.profileSwitcher,
      page: () => const ProfileSwitcherView(),
      binding: ProfileSwitcherBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.createProfile,
      page: () => const CreateProfileView(),
      binding: ChildProfileBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => Home(),
      binding: BindingsBuilder(() {
        BottomNavBinding().dependencies();
        DashboardBinding().dependencies();
        ProgressBinding().dependencies();
      }),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.topics,
      page: () => TopicScreen(),
      binding: TopicBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.parentSettings,
      page: () => const ParentSettingsView(),
      binding: ParentSettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 400),
    ),
  ];
}
