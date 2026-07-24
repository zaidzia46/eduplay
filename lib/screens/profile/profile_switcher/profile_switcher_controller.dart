import 'dart:developer';

import 'package:eduplay/controller/session_controller.dart';
import 'package:get/get.dart';

import '../../../models/child_profile_model.dart';
import '../../../routes/app_routes.dart';
import '../../home/dashboard/subject_repo.dart';
import '../../home/progress/progress_stats_repo.dart';
import '../create_child_profile/create_child_profile_repo.dart';

class ProfileSwitcherViewModel extends GetxController {
  final ChildProfileRepository _repo = ChildProfileRepository();
  final SubjectRepository _subjectRepo = SubjectRepository();
  final ProgressStatsRepository _statsRepo = ProgressStatsRepository();
  final session = Get.find<SessionController>();

  var children = <ChildProfileModel>[].obs;
  var starsByChild = <int, int>{}.obs;
  var streakByChild = <int, int>{}.obs;
  var totalStars = 0.obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  var activeChild = Rxn<ChildProfileModel>();

  // Which card is currently mid-selection — used to show a spinner on
  // just that card, and disable taps on the others until it resolves.
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

      final withProgress = await Future.wait(
        fetchedChildren.map((child) async {
          final percent = await _subjectRepo.getOverallPercent(
            childId: child.id,
          );

          final subjects = await _subjectRepo.getSubjects(childId: child.id);
          final stats = await _statsRepo.getStats(subjects, childId: child.id);
          totalStars.value += stats.starsEarned;
          starsByChild[child.id] = stats.starsEarned;
          streakByChild[child.id] = stats.daysActive;
          return child.copyWithProgress(overallPercent: percent);
        }),
      );

      children.value = withProgress;
    } catch (e) {
      errorMessage.value = 'Could not load profiles.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectChild(ChildProfileModel child) async {
    if (loadingChildId.value != null) return; // ignore taps mid-selection
    try {
      loadingChildId.value = child.id;
      await session.setActiveChild(child);
      Get.offAllNamed(AppRoutes.home);
    } finally {
      loadingChildId.value = null;
    }
  }

  void goToCreateProfile() {
    Get.toNamed(AppRoutes.createProfile);
  }
}
