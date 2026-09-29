import 'package:get/get.dart';

import '../parent_settings/parent_settings_controller.dart';
import '../profile/profile_switcher/profile_switcher_controller.dart';
import 'parent_dashboard_controller.dart';

class ParentDashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProfileSwitcherViewModel>()) {
      Get.put(ProfileSwitcherViewModel(), permanent: true);
    }

    Get.lazyPut<ParentDashboardController>(() => ParentDashboardController());
    Get.lazyPut<ParentSettingsController>(() => ParentSettingsController());
  }
}
