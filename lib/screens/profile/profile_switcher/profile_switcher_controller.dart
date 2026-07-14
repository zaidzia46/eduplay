import 'package:eduplay/controller/session_controller.dart';
import 'package:get/get.dart';

import '../../../models/child_profile_model.dart';
import '../../../routes/app_routes.dart';
import '../../home/dashboard/subject_repo.dart';
import '../create_child_profile/create_child_profile_repo.dart';

class ProfileSwitcherViewModel extends GetxController {
  final ChildProfileRepository _repo = ChildProfileRepository();
  final SubjectRepository _subjectRepo = SubjectRepository();
  final session = Get.find<SessionController>();

  var children = <ChildProfileModel>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  // The currently active child — used by dashboard
  var activeChild = Rxn<ChildProfileModel>();

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

      // Each child needs their own overall percent (not just whoever is
      // currently active), so fetch them in parallel rather than one
      // at a time.
      final withProgress = await Future.wait(
        fetchedChildren.map((child) async {
          final percent = await _subjectRepo.getOverallPercent(
            childId: child.id,
          );
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

  void selectChild(ChildProfileModel child) async {
    await session.setActiveChild(child);
    Get.offAllNamed(AppRoutes.home);
  }

  void goToCreateProfile() {
    Get.toNamed(AppRoutes.createProfile);
  }
}
