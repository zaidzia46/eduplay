import 'package:get/get_instance/get_instance.dart';
import 'package:get/get.dart';

import 'create_child_profile_controller.dart';

class ChildProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateProfileViewModel>(() => CreateProfileViewModel());
  }
}
