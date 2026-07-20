import 'dart:developer';

import 'package:eduplay/controller/session_controller.dart';
import 'package:eduplay/screens/home/progress/recent_act_repo.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../models/activity_category_model.dart';
import '../../../models/progress_stat_model.dart';
import '../../../models/recent_act_model.dart';
import '../../../models/subjects_model.dart';
import '../dashboard/subject_repo.dart';
import 'activitybreakdown_repo.dart';
import 'progress_stats_repo.dart';

class ProgressController extends GetxController {
  final SubjectRepository _subjectRepo = SubjectRepository();
  final ProgressStatsRepository _statsRepo = ProgressStatsRepository();
  final RecentActivityRepository _activityRepo = RecentActivityRepository();
  final ActivityBreakdownRepository _breakdownRepo =
      ActivityBreakdownRepository();

  var subjects = <SubjectsModel>[].obs;
  var stats = Rxn<ProgressStatsModel>();
  var recentActivity = <RecentActivityModel>[].obs;
  var activityBreakdown = <ActivityCategoryModel>[].obs;

  var isLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();

    ever(Get.find<SessionController>().currentStandard, (_) => fetchAll());
  }

  Future<void> fetchAll() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      subjects.value = await _subjectRepo.getSubjects();
      stats.value = await _statsRepo.getStats(subjects);
      recentActivity.value = await _activityRepo.getRecentActivity(limit: 5);
      activityBreakdown.value = await _breakdownRepo.getBreakdown();
      log("Activity breakdown: ${activityBreakdown.value}");
    } catch (e) {
      errorMessage.value = 'Could not load progress';
    } finally {
      isLoading.value = false;
    }
  }
}
