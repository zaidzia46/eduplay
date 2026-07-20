import 'package:get/get.dart';

import '../../../models/child_profile_model.dart';
import 'child_detail_controller.dart';

class ChildDetailBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    final child = args['child'] as ChildProfileModel;

    Get.lazyPut<ChildDetailController>(
      () => ChildDetailController(child: child),
    );
  }
}
