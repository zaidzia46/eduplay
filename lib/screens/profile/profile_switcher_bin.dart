import 'package:eduplay/screens/profile/profile_switcher_controller.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get.dart';

import 'child_profile_controller.dart';

class ProfileSwitcherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileSwitcherViewModel>(() => ProfileSwitcherViewModel());
    Get.lazyPut<CreateProfileViewModel>(() => CreateProfileViewModel());
  }
}
