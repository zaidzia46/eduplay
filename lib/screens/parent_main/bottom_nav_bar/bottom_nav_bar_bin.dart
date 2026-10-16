import 'package:get/get.dart';

import 'bottom_nav_bar_controller.dart';

class ParentBottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentBottomNavController>(() => ParentBottomNavController());
  }
}
