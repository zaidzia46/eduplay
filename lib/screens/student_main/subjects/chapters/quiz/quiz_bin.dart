import 'package:get/get.dart';

import 'quiz_controller.dart';

class QuizBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    final quizId = args['quizId'] as int;
    // Optional — falls back to the schema default so launching the quiz from
    // anywhere without it still works.
    final passingScorePercent = args['passingScorePercent'] as int? ?? 60;

    Get.lazyPut<QuizController>(
      () => QuizController(
        quizId: quizId,
        passingScorePercent: passingScorePercent,
      ),
    );
  }
}
