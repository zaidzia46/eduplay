import 'package:get/get.dart';
import 'parent_dashboard_controller.dart';

class ParentDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentDashboardController>(() => ParentDashboardController());
  }
}
