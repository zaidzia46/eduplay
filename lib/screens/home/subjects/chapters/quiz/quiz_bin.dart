import 'package:get/get.dart';

import 'quiz_controller.dart';

class QuizBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    final quizId = args['quizId'] as int;

    Get.lazyPut<QuizController>(() => QuizController(quizId: quizId));
  }
}
