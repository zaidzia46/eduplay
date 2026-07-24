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

  var loadingChildId = Rxn<int>();

  // var activeChild = Rxn<ChildProfileModel>();

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

      final newStarsByChild = <int, int>{};
      final newStreakByChild = <int, int>{};

      final withProgress = await Future.wait(
        fetchedChildren.map((child) async {
          final percent = await _subjectRepo.getOverallPercent(
            childId: child.id,
          );

          final subjects = await _subjectRepo.getSubjects(childId: child.id);
          final stats = await _statsRepo.getStats(subjects, childId: child.id);
          newStarsByChild[child.id] = stats.starsEarned;
          newStreakByChild[child.id] = stats.daysActive;
          return child.copyWithProgress(overallPercent: percent);
        }),
      );

      starsByChild.value = newStarsByChild;
      streakByChild.value = newStreakByChild;
      totalStars.value = newStarsByChild.values.fold(
        0,
        (sum, stars) => sum + stars,
      );
      children.value = withProgress;
    } catch (e) {
      errorMessage.value = 'Could not load profiles.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectChild(ChildProfileModel child) async {
    await session.setActiveChild(child);
    Get.offAllNamed(AppRoutes.home);
  }

  void goToCreateProfile() {
    Get.toNamed(AppRoutes.createProfile);
  }
}
