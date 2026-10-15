import 'package:eduplay/screens/student_main/progress/progress_controller.dart';
import 'package:get/get.dart';

class ProgressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgressController>(() => ProgressController());
  }
}
