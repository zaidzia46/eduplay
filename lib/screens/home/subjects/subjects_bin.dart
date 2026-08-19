import 'package:eduplay/screens/home/subjects/subjects_controller.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get.dart';

class SubjectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubjectsController>(() => SubjectsController());
  }
}
