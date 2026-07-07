// viewmodels/profile_switcher_viewmodel.dart
import 'package:get/get.dart';
import '../../models/child_profile_model.dart';
import '../../routes/app_routes.dart';
import 'child_profile_repo.dart';

class ProfileSwitcherViewModel extends GetxController {
  final ChildProfileRepository _repo = ChildProfileRepository();

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
      children.value = await _repo.getChildren();
    } catch (e) {
      errorMessage.value = 'Could not load profiles.';
    } finally {
      isLoading.value = false;
    }
  }

  void selectChild(ChildProfileModel child) {
    activeChild.value = child;
    Get.offAllNamed(AppRoutes.home);
  }

  void goToCreateProfile() {
    Get.toNamed(AppRoutes.createProfile);
  }
}
