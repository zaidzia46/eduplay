import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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

  var remainingSeconds = 0.obs;
  var ranOutOfTime = false.obs;
  Timer? _questionTimer;

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

      await _precacheQuestionImages(questions);

      _startedAt = DateTime.now();
      _startQuestionTimer();
    } catch (e) {
      errorMessage.value = 'Could not load quiz. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _precacheQuestionImages(List<QuestionModel> selected) async {
    final urls = <String>{};

    for (final q in selected) {
      if (q.questionImage != null) {
        urls.add(_repo.getPublicImageUrl(q.questionImage!));
      }
      for (final option in q.options ?? const []) {
        if (option.type == 'image') {
          urls.add(_repo.getPublicImageUrl(option.value));
        }
      }
    }

    await Future.wait(
      urls.map((url) async {
        try {
          await DefaultCacheManager().downloadFile(url);
        } catch (_) {
          // Swallowed on purpose: CachedNetworkImage will just show its
          // errorWidget for this one image later, same as if we'd never
          // precached at all.
        }
      }),
    );
  }

  QuestionModel get currentQuestion => questions[currentIndex.value];

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    ranOutOfTime.value = false;
    remainingSeconds.value = currentQuestion.timeLimitSeconds;

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds.value <= 1) {
        _questionTimer?.cancel();
        remainingSeconds.value = 0;
        if (!hasAnswered.value) {
          // Time ran out with no answer selected — counts as wrong, same as
          // a normal incorrect answer, just with a distinct message so the
          // child understands why (ranOutOfTime vs. actually picked wrong).
          hasAnswered.value = true;
          isCurrentAnswerCorrect.value = false;
          ranOutOfTime.value = true;
        }
      } else {
        remainingSeconds.value--;
      }
    });
  }

  void selectOption(String optionId) {
    if (hasAnswered.value) return;

    _questionTimer?.cancel();
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

    _questionTimer?.cancel();
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
      _startQuestionTimer();
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
    } catch (e) {
      errorMessage.value = 'Could not save your results.';
    } finally {
      isSubmitting.value = false;
      isFinished.value = true;
    }
  }

  @override
  void onClose() {
    _questionTimer?.cancel();
    fillBlankController.dispose();
    super.onClose();
  }
}
