import 'package:get/get_instance/get_instance.dart';
import 'package:get/get.dart';

import '../subjects_model.dart';
import 'chapter_controller.dart';

class ChapterBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    final subject = args['subject'] as SubjectModel;

    Get.lazyPut<ChapterController>(() => ChapterController(subject: subject));
  }
}
