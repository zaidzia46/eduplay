import 'package:eduplay/controller/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../create_child_profile/repo/create_child_profile_repo.dart';
import 'models/child_profile_model.dart';

class ProfileSwitcherViewModel extends GetxController {
  final ChildProfileRepository _repo = ChildProfileRepository();
  final session = Get.find<SessionController>();

  var children = <ChildProfileModel>[].obs;
  var starsByChild = <int, int>{}.obs;
  var streakByChild = <int, int>{}.obs;
  var avatarUrlByChild = <int, String?>{}.obs;
  var totalStars = 0.obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  var loadingChildId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    fetchChildren();
  }

  Future<void> fetchChildren() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final fetchedChildren = await _repo.getChildren();

      starsByChild.value = {
        for (final c in fetchedChildren) c.id: c.totalStars,
      };
      streakByChild.value = {
        for (final c in fetchedChildren) c.id: c.currentStreak,
      };
      totalStars.value = starsByChild.values.fold(0, (sum, s) => sum + s);

      final avatarEntries = await Future.wait(
        fetchedChildren.map((c) async {
          final url = c.avatar != null
              ? await _repo.getAvatarSignedUrl(c.avatar!)
              : null;
          return MapEntry(c.id, url);
        }),
      );
      avatarUrlByChild.value = Map.fromEntries(avatarEntries);

      children.value = fetchedChildren
          .map((c) => c.copyWithProgress(overallPercent: 0))
          .toList();
    } catch (e) {
      errorMessage.value = 'Could not load profiles.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectChild(ChildProfileModel child) async {
    await session.setActiveChild(child);
    final context = Get.context!;
    await Future.wait([
      //dashboard bg is used in both dashboard and profile tab.
      precacheImage(
        const AssetImage('assets/images/dashboard_bg.png'),
        context,
      ),
      precacheImage(const AssetImage('assets/images/subjects_bg.png'), context),
      precacheImage(const AssetImage('assets/images/progress_bg.png'), context),
    ]);
    Get.offAllNamed(AppRoutes.home);
  }

  void goToCreateProfile() {
    Get.toNamed(AppRoutes.createProfile);
  }
}
