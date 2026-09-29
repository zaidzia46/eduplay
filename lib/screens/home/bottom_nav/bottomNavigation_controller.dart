import 'package:eduplay/screens/home/subjects/subjects_controller.dart';
import 'package:get/get.dart';

import '../dashboard/dashboard_controller.dart';

class BottomNavController extends GetxController {
  var currentIndex = 0.obs;
  final vm = Get.find<SubjectsController>();

  @override
  void onInit() {
    super.onInit();
    // The parent dashboard's "View Progress" enters Home on a specific tab by
    // passing {'initialTab': <index>} through Get.offAllNamed. Default entry
    // (no args) stays on the Dashboard tab (0).
    final args = Get.arguments;
    if (args is Map && args['initialTab'] is int) {
      currentIndex.value = args['initialTab'] as int;
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
    index == 1 ? vm.activeFilter.value = SubjectFilter.all : null;
  }
}
