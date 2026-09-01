import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'quiz_list_repo.dart';
import 'quiz_model.dart';

class QuizListController extends GetxController {
  final QuizListRepository _repo = QuizListRepository();

  // Passed in from the chapter that was tapped — id drives the fetch,
  // title + color drive the header/theming to match the parent subject.
  final int chapterId;
  final String chapterTitle;
  final Color accentColor;

  QuizListController({
    required this.chapterId,
    required this.chapterTitle,
    required this.accentColor,
  });

  var quizzes = <QuizModel>[].obs;
  var isLoading = true.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    try {
      isLoading.value = true;
      error.value = '';
      quizzes.value = await _repo.getQuizzes(chapterId: chapterId);
    } catch (e) {
      error.value = 'Failed to load quizzes: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
