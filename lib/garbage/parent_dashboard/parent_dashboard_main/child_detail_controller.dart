// import 'package:get/get.dart';
//
// import '../../../models/child_profile_model.dart';
// import '../../../models/progress_stat_model.dart';
// import '../../../models/recent_act_model.dart';
// import '../../../models/subjects_model.dart';
// import '../../home/dashboard/subject_repo.dart';
// import '../../home/progress/progress_stats_repo.dart';
// import '../../home/progress/recent_act_repo.dart';
//
// Same data as ProgressController, but for a specific child a parent
// picked from the Parent Dashboard — not tied to session.activeChild,
// since a parent needs to view any child's detail, not just whichever
// one is currently active on the device.
// class ChildDetailController extends GetxController {
//   final ChildProfileModel child;
//   ChildDetailController({required this.child});
//
//   final SubjectRepository _subjectRepo = SubjectRepository();
//   final ProgressStatsRepository _statsRepo = ProgressStatsRepository();
//   final RecentActivityRepository _activityRepo = RecentActivityRepository();
//
//   var subjects = <SubjectsModel>[].obs;
//   var stats = Rxn<ProgressStatsModel>();
//   var recentActivity = <RecentActivityModel>[].obs;
//
//   var isLoading = true.obs;
//   var errorMessage = ''.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchAll();
//   }
//
//   Future<void> fetchAll() async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       subjects.value = await _subjectRepo.getSubjects(childId: child.id);
//       stats.value = await _statsRepo.getStats(subjects, childId: child.id);
//       recentActivity.value = await _activityRepo.getRecentActivity(
//         limit: 5,
//         childId: child.id,
//       );
//     } catch (e) {
//       errorMessage.value = 'Could not load progress';
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
