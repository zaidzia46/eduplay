import 'package:get/get.dart';

import '../parent_settings/parent_settings_controller.dart';

class AppDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentSettingsController>(() => ParentSettingsController());
  }
}
