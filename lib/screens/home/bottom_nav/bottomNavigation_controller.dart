import 'package:get/get.dart';

import '../dashboard/dashboard_controller.dart';

class BottomNavController extends GetxController {
  var currentIndex = 0.obs;
  final vm = Get.find<DashboardController>();
  var visitedIndices = <int>{0}.obs;

  void changePage(int index) {
    visitedIndices.add(index);
    currentIndex.value = index;
    index == 1 ? vm.activeFilter.value = SubjectFilter.all : null;
  }
}
