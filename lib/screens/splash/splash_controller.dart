import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../controller/session_controller.dart';
import '../../core/supabase_client.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController animation;
  late final Animation<double> logoScaleAnimation;
  late final Animation<double> logoOpacityAnimation;
  late final Animation<double> rainbowAnimation;
  late final Animation<double> mascotAnimation;

  double hoverOffset = 0;

  @override
  void onInit() {
    super.onInit();
    _navigate();

    animation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    logoScaleAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.15, 0.25, curve: Curves.easeOutBack),
    );

    logoOpacityAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.24, 0.35, curve: Curves.easeOut),
    );

    mascotAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.50, 0.65, curve: Curves.elasticOut),
    );

    rainbowAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.60, 0.75, curve: Curves.easeOut),
    );

    animation.forward();
  }

  Future<void> _navigate() async {
    final context = Get.context!;

    await Future.wait([
      Future.delayed(const Duration(seconds: 5)),
      precacheImage(
        const AssetImage('assets/images/profile_switch_bg.png'),
        context,
      ),
    ]);
    final session = Get.find<SessionController>();

    if (!session.isParentLoggedIn) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    // if (session.activeChild.value != null) {
    //   Get.offAllNamed(AppRoutes.home);
    //   return;
    // }

    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        Get.offAllNamed(AppRoutes.parentSettings);
      }
    });
  }

  @override
  void onClose() {
    animation.dispose();
    super.onClose();
  }
}
