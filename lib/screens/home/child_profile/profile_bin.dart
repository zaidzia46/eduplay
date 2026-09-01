import 'package:eduplay/screens/home/child_profile/profile_controller.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get.dart';

import '../../profile/create_child_profile/create_child_profile_controller.dart';

class ChildProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateProfileViewModel>(() => CreateProfileViewModel());
    Get.lazyPut<ProfileViewModel>(() => ProfileViewModel());
  }
}
