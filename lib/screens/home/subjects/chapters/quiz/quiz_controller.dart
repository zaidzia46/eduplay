import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../controller/session_controller.dart';
import 'models/question_model.dart';
import 'quiz_repo.dart';

class QuizController extends GetxController {
  final QuizRepository _repo = QuizRepository();
  final SessionController _session = Get.find<SessionController>();

  final int quizId;
  QuizController({required this.quizId});

  static const questionsPerAttempt = 10;

  var isLoading = true.obs;
  var errorMessage = ''.obs;

  var questions = <QuestionModel>[].obs;
  var currentIndex = 0.obs;

  var selectedOptionId = Rxn<String>();
  final fillBlankController = TextEditingController();
  var hasAnswered = false.obs;
  var isCurrentAnswerCorrect = false.obs;

  var correctCount = 0.obs;
  var isFinished = false.obs;
  var starsAwarded = Rxn<int>();
  var isSubmitting = false.obs;

  DateTime? _startedAt;

  @override
  void onInit() {
    super.onInit();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final pool = await _repo.getQuestionPool(quizId);
      if (pool.isEmpty) {
        errorMessage.value = 'No questions available for this quiz yet.';
        return;
      }

      pool.shuffle();
      questions.value = pool.take(questionsPerAttempt).toList();
      _startedAt = DateTime.now();
    } catch (e) {
      errorMessage.value = 'Could not load quiz. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  QuestionModel get currentQuestion => questions[currentIndex.value];

  void selectOption(String optionId) {
    if (hasAnswered.value) return;

    selectedOptionId.value = optionId;
    final option = currentQuestion.options?.firstWhereOrNull(
      (o) => o.id == optionId,
    );
    final correct = option?.isCorrect ?? false;

    hasAnswered.value = true;
    isCurrentAnswerCorrect.value = correct;
    if (correct) correctCount.value++;
  }

  void submitFillBlank() {
    if (hasAnswered.value) return;

    final typed = fillBlankController.text.trim().toLowerCase();
    if (typed.isEmpty) return;

    final accepted = currentQuestion.acceptedAnswers ?? [];
    final correct = accepted.any((a) => a.trim().toLowerCase() == typed);

    hasAnswered.value = true;
    isCurrentAnswerCorrect.value = correct;
    if (correct) correctCount.value++;
  }

  Future<void> nextQuestion() async {
    hasAnswered.value = false;
    selectedOptionId.value = null;
    fillBlankController.clear();

    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
    } else {
      await _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final childId = _session.activeChild.value?.id;
    if (childId == null) {
      errorMessage.value = 'No active profile — could not save results.';
      isFinished.value = true;
      return;
    }

    final timeSpent = DateTime.now()
        .difference(_startedAt ?? DateTime.now())
        .inSeconds;

    try {
      isSubmitting.value = true;
      starsAwarded.value = await _repo.submitAttempt(
        childId: childId,
        quizId: quizId,
        correctCount: correctCount.value,
        totalQuestions: questions.length,
        timeSpentSeconds: timeSpent,
      );
      _session.updateActiveChildStars(starsAwarded.value ?? 0);
    } catch (e) {
      errorMessage.value = 'Could not save your results.';
    } finally {
      isSubmitting.value = false;
      isFinished.value = true;
    }
  }

  @override
  void onClose() {
    fillBlankController.dispose();
    super.onClose();
  }
}
