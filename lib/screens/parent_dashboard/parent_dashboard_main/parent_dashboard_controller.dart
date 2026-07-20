import 'dart:developer';

import 'package:get/get.dart';

import '../../../models/child_profile_model.dart';
import '../../../routes/app_routes.dart';
import '../../home/dashboard/subject_repo.dart';
import '../../home/progress/progress_stats_repo.dart';
import '../../profile/create_child_profile/create_child_profile_repo.dart';

class ParentDashboardController extends GetxController {
  final ChildProfileRepository _childRepo = ChildProfileRepository();
  final SubjectRepository _subjectRepo = SubjectRepository();
  final ProgressStatsRepository _statsRepo = ProgressStatsRepository();

  var children = <ChildProfileModel>[].obs;
  var starsByChild = <int, int>{}.obs;
  var streakByChild = <int, int>{}.obs;
  var totalStars = 0.obs;

  var isLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChildren();
  }

  Future<void> fetchChildren() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final fetchedChildren = await _childRepo.getChildren();

      // Each child needs their own overall percent + stars/streak,
      // fetched in parallel rather than one at a time.
      final withProgress = await Future.wait(
        fetchedChildren.map((child) async {
          final percent = await _subjectRepo.getOverallPercent(
            childId: child.id,
          );

          final subjects = await _subjectRepo.getSubjects(childId: child.id);
          final stats = await _statsRepo.getStats(subjects, childId: child.id);
          totalStars.value += stats.starsEarned;
          log("Total Stars: ${totalStars.value}");
          starsByChild[child.id] = stats.starsEarned;
          streakByChild[child.id] = stats.daysActive;

          return child.copyWithProgress(overallPercent: percent);
        }),
      );

      children.value = withProgress;
    } catch (e) {
      errorMessage.value = 'Could not load children.';
    } finally {
      isLoading.value = false;
    }
  }

  void openChildDetail(ChildProfileModel child) {
    Get.toNamed(AppRoutes.childDetail, arguments: {'child': child});
  }
}
