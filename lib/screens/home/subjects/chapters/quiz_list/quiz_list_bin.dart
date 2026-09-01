import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'quiz_list_controller.dart';

class QuizListBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;

    Get.lazyPut<QuizListController>(
      () => QuizListController(
        chapterId: args['chapterId'] as int,
        chapterTitle: args['chapterTitle'] as String,
        accentColor: args['accentColor'] as Color,
      ),
    );
  }
}
