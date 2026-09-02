import 'package:eduplay/controller/session_controller.dart';
import 'package:get/get.dart';

import '../../../models/activity_category_model.dart';
import '../../../models/progress_overview_model.dart';
import '../../../models/recent_act_model.dart';
import 'progress_repo.dart';

class ProgressController extends GetxController {
  final ProgressRepository _repo = ProgressRepository();
  final SessionController _session = Get.find<SessionController>();

  final overview = Rxn<ProgressOverviewModel>();
  var recentActivity = <RecentActivityModel>[].obs;
  var activityBreakdown = <ActivityCategoryModel>[].obs;

  var isLoading = true.obs;
  var errorMessage = ''.obs;

  // Stars/streak live on the active child (kept fresh server-side and mirrored
  // onto the child after each quiz). Reading these getters inside the view's
  // Obx keeps the tiles reactive without importing SessionController there.
  int get starsEarned => _session.activeChild.value?.totalStars ?? 0;
  int get dayStreak => _session.activeChild.value?.currentStreak ?? 0;

  @override
  void onInit() {
    super.onInit();
    fetchAll();

    // Watch the active child (not currentStandard): refreshActiveChildCounters
    // updates activeChild after a quiz, and switching profiles also sets it,
    // so this single worker covers both "new child" and "counters changed".
    ever(_session.activeChild, (_) => fetchAll());
  }

  Future<void> reload() => fetchAll();

  Future<void> fetchAll() async {
    final childId = _session.activeChild.value?.id;
    if (childId == null) {
      overview.value = null;
      recentActivity.clear();
      activityBreakdown.clear();
      isLoading.value = false;
      return;
    }

    // Only show the full-screen loader on the very first load (nothing to show
    // yet). Tab-open/post-quiz refreshes fetch quietly and swap the numbers in
    // place, so reopening the tab doesn't flash a loader over existing data.
    final isFirstLoad = overview.value == null;
    try {
      if (isFirstLoad) isLoading.value = true;

      final result = await _repo.getOverview(childId);
      final activity = await _repo.getRecentActivity(childId, limit: 5);

      overview.value = result;
      activityBreakdown.value = _buildBreakdown(result);
      recentActivity.value = activity;
      errorMessage.value = '';
    } catch (e) {
      // Keep any existing data on a background refresh failure; only block the
      // screen with an error when there was nothing to show.
      if (isFirstLoad) errorMessage.value = 'Could not load progress';
    } finally {
      if (isFirstLoad) isLoading.value = false;
    }
  }

  List<ActivityCategoryModel> _buildBreakdown(ProgressOverviewModel o) {
    return [
      ActivityCategoryModel(
        label: 'Subjects',
        completed: o.subjectsCompleted,
        total: o.subjectsTotal,
      ),
      ActivityCategoryModel(
        label: 'Chapters',
        completed: o.chaptersCompleted,
        total: o.chaptersTotal,
      ),
      ActivityCategoryModel(
        label: 'Quizzes',
        completed: o.quizzesPassed,
        total: o.quizzesTotal,
      ),
    ];
  }
}
