import 'package:get/get.dart';

import '../../../core/supabase_client.dart';
import '../parent_settings/parent_settings_controller.dart';
import '../profile/profile_switcher/profile_switcher_controller.dart';
import 'parent_dashboard_controller.dart';

class ParentDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // The shell this binding belongs to is a PUBLIC route (its landing tab is
    // the logged-out dashboard), so this runs for anonymous visitors too.
    // ProfileSwitcherViewModel's onInit immediately queries `children`, so only
    // create it once there is a session to query with — a signed-out visitor
    // would otherwise fire a request that can only fail. Logging in re-enters
    // the shell (`offAllNamed`), which runs this binding again with a session.
    if (supabase.auth.currentSession != null &&
        !Get.isRegistered<ProfileSwitcherViewModel>()) {
      Get.put(ProfileSwitcherViewModel(), permanent: true);
    }

    // Lazy: these are only constructed when their (gated) tab actually builds.
    if (supabase.auth.currentSession != null) {
      Get.lazyPut<ParentDashboardController>(
        () => ParentDashboardController(),
      );
      Get.lazyPut<ParentSettingsController>(() => ParentSettingsController());
    }
  }
}
