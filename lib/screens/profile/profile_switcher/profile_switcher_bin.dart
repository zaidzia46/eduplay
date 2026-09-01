import 'package:eduplay/screens/profile/profile_switcher/profile_switcher_controller.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get.dart';

import '../../parent_settings/parent_settings_controller.dart';

class ProfileSwitcherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileSwitcherViewModel>(() => ProfileSwitcherViewModel());
    Get.lazyPut<ParentSettingsController>(() => ParentSettingsController());
  }
}
