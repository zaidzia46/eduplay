import 'package:eduplay/screens/home/topics/topic_controller.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get.dart';

import '../../../models/subjects_model.dart';

class TopicBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    final subject = args['subject'] as SubjectsModel;

    Get.lazyPut<TopicController>(() => TopicController(subject: subject));
  }
}
