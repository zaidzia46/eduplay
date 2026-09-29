import 'package:get/get.dart';

import '../../controller/session_controller.dart';
import '../../routes/app_routes.dart';
import '../home/progress/models/recent_act_model.dart';
import '../home/progress/progress_repo.dart';
import '../profile/profile_switcher/models/child_profile_model.dart';
import '../profile/profile_switcher/profile_switcher_controller.dart';

class FamilyActivity {
  final String childName;
  final RecentActivityModel activity;

  const FamilyActivity({required this.childName, required this.activity});
}

class ParentDashboardController extends GetxController {
  final switcher = Get.find<ProfileSwitcherViewModel>();
  final session = Get.find<SessionController>();

  final _progressRepo = ProgressRepository();

  final recentActivity = <FamilyActivity>[].obs;
  final isLoadingActivity = true.obs;

  RxList<ChildProfileModel> get children => switcher.children;
  RxMap<int, int> get starsByChild => switcher.starsByChild;
  RxMap<int, int> get streakByChild => switcher.streakByChild;
  RxMap<int, String?> get avatarUrlByChild => switcher.avatarUrlByChild;
  RxInt get totalStars => switcher.totalStars;
  RxBool get isLoading => switcher.isLoading;
  RxString get errorMessage => switcher.errorMessage;

  @override
  void onInit() {
    super.onInit();
    _loadRecentActivity();
  }

  Future<void> _loadRecentActivity() async {
    try {
      isLoadingActivity.value = true;
      await switcher.loadingFuture;

      final perChild = await Future.wait(
        switcher.children.map((child) async {
          final items = await _progressRepo.getRecentActivity(
            child.id,
            limit: 3,
          );
          return items
              .map((a) => FamilyActivity(childName: child.name, activity: a))
              .toList();
        }),
      );

      final merged = perChild.expand((rows) => rows).toList()
        ..sort((a, b) => b.activity.timestamp.compareTo(a.activity.timestamp));

      recentActivity.value = merged.take(6).toList();
    } catch (_) {
      recentActivity.clear();
    } finally {
      isLoadingActivity.value = false;
    }
  }

  void continueLearning(ChildProfileModel child) => switcher.selectChild(child);

  /// Opens the child's Progress screen standalone (no bottom-nav shell) so the
  /// parent can peek at it and return here via the back button. We set the
  /// active child first — [ProgressController] is driven by
  /// `SessionController.activeChild` — then push (not replace) the route so
  /// `Get.back()` lands back on this dashboard.
  Future<void> viewProgress(ChildProfileModel child) async {
    await session.setActiveChild(child);
    Get.toNamed(AppRoutes.progress);
  }

  void addChild() => switcher.goToCreateProfile();

  void manageChildren() => Get.toNamed(
    AppRoutes.profileSwitcher,
    arguments: {'showBackButton': true},
  );

  void viewAllClassifieds() {
    Get.snackbar(
      'Classifieds',
      'The full classifieds marketplace is coming soon.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
