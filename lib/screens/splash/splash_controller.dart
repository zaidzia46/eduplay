import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/supabase_client.dart';
import '../../fns/image_constant.dart';
import '../../routes/app_routes.dart';
import '../parent_settings/parent_settings_repo.dart';
import '../profile/profile_switcher/profile_switcher_controller.dart';

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
      precacheImage(const AssetImage(ImageConstant.splashImage), context),
    ]);

    final session = supabase.auth.currentSession;

    // Logged out: open the public App Dashboard. We deliberately do NOT create
    // an anonymous session and do NOT load any profile/child data — nothing
    // user-specific is created or read just because the app was opened. The
    // user reaches authenticated screens only by logging in or registering.
    if (session == null) {
      Get.offAllNamed(AppRoutes.appDashboard);
      return;
    }

    // Returning, authenticated user: warm the family data + avatar caches so the
    // Parent Dashboard is ready the instant it appears, then open the App
    // Dashboard — the shared landing hub — from which the user taps through to
    // the Parent Dashboard.
    final profileVm = Get.put(ProfileSwitcherViewModel(), permanent: true);
    await profileVm.loadingFuture;

    final parentRepo = ParentRepository();
    final parentId = supabase.auth.currentUser!.id;
    String? parentAvatarUrl;
    try {
      parentAvatarUrl = await parentRepo.getAvatarSignedUrl(
        '$parentId/parent.png',
      );
    } catch (e) {
      parentAvatarUrl = null;
    }
    await Future.wait([
      ...profileVm.avatarUrlByChild.values.whereType<String>().map(
        (url) => precacheImage(CachedNetworkImageProvider(url), context),
      ),
      if (parentAvatarUrl != null)
        precacheImage(CachedNetworkImageProvider(parentAvatarUrl), context),
    ]);

    Get.offAllNamed(AppRoutes.appDashboard);
  }

  @override
  void onClose() {
    animation.dispose();
    super.onClose();
  }
}
