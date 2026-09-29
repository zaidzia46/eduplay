import 'package:eduplay/screens/home/game_demo/game.dart';
import 'package:eduplay/screens/home/progress/progress.dart';
import 'package:eduplay/screens/home/progress/progress_bin.dart';
import 'package:eduplay/screens/home/subjects/subjects_bin.dart';
import 'package:get/get.dart';
import 'package:eduplay/routes/app_routes.dart';

import 'package:eduplay/screens/splash/splash_screen.dart';

import '../screens/app_dashboard/app_dashboard_bin.dart';
import '../screens/auth/auth_binding.dart';
import '../screens/auth/login.dart';
import '../screens/auth/register.dart';
import '../screens/app_dashboard/app_dashboard_screen.dart';
import '../screens/home/bottom_nav/bottomNavbar_bin.dart';
import '../screens/home/child_profile/profile_bin.dart';
import '../screens/home/dashboard/dashboard_bin.dart';
import '../screens/home/home.dart';
import '../screens/home/subjects/chapters/chapter_bin.dart';
import '../screens/home/subjects/chapters/chapter_screen.dart';
import '../screens/home/subjects/chapters/quiz/quiz_bin.dart';
import '../screens/home/subjects/chapters/quiz/quiz_screen.dart';
import '../screens/home/subjects/chapters/quiz_list/quiz_list_bin.dart';
import '../screens/home/subjects/chapters/quiz_list/quiz_list_screen.dart';
import '../screens/parent_dashboard/parent_dashboard_bin.dart';
import '../screens/parent_dashboard/parent_dashboard_screen.dart';
import '../screens/profile/create_child_profile/create_child_profile_screen.dart';
import '../screens/profile/profile_switcher/profile_switcher_bin.dart';
import '../screens/profile/profile_switcher/profile_switcher_screen.dart';
import '../screens/splash/splash_bin.dart';

abstract class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
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
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.appDashboard,
      page: () => const AppDashboardView(),
      binding: AppDashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.parentDashboard,
      page: () => const ParentDashboardView(),
      binding: ParentDashboardBinding(),
      transition: Transition.fadeIn,
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
        SubjectBinding().dependencies();
        ProgressBinding().dependencies();
        ChildProfileBinding().dependencies();
      }),
    ),

    // Standalone, read-only Progress screen — used by the Parent Dashboard's
    // "View Progress" so a parent can peek at the active child's progress
    // without the bottom-nav shell (and with static, non-navigating subject
    // rows). The child-facing Progress tab lives inside [Home] above.
    GetPage(
      name: AppRoutes.progress,
      page: () => const ProgressView(readOnly: true),
      binding: ProgressBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.chapters,
      page: () => ChapterScreen(),
      binding: ChapterBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.quizList,
      page: () => QuizListScreen(),
      binding: QuizListBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.quiz,
      page: () => QuizScreen(),
      binding: QuizBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.game,
      page: () => GameView(),
      transition: Transition.fadeIn,
    ),
  ];
}
