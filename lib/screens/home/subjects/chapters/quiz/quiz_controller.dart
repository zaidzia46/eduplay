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

  /// The score (%) the child must reach for this quiz to count as passed. Comes
  /// from the quiz row (`quizzes.passing_score_percent`, default 60) and is
  /// passed in from the quiz list so the results screen can decide pass/fail
  /// without another round-trip.
  final int passingScorePercent;

  QuizController({required this.quizId, this.passingScorePercent = 60});

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

  /// Best-effort score for the *current* attempt, as a whole-number percent.
  int get scorePercent => questions.isEmpty
      ? 0
      : ((correctCount.value / questions.length) * 100).round();

  /// Whether this attempt passed. Uses the raw ratio (not the rounded
  /// [scorePercent]) so it matches the server-side pass check exactly.
  bool get passed =>
      questions.isNotEmpty &&
      (correctCount.value / questions.length) * 100 >= passingScorePercent;

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
    if (currentIndex.value < questions.length - 1) {
      hasAnswered.value = false;
      selectedOptionId.value = null;
      fillBlankController.clear();
      currentIndex.value++;
      _startQuestionTimer();
    } else {
      await _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    if (isSubmitting.value || isFinished.value) return;

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

      // Pull the freshly-updated stars/streak (and thus Progress) onto the
      // active child. A failure here must not surface as a save error — the
      // attempt itself already succeeded.
      try {
        await _session.refreshActiveChildCounters();
      } catch (_) {}
    } catch (e) {
      errorMessage.value = 'Could not save your results.';
    } finally {
      isSubmitting.value = false;
      isFinished.value = true;
    }
  }

  /// Restart the quiz from scratch after a failed attempt: clear every
  /// per-attempt value and pull a fresh (re-shuffled) question set. _loadQuiz
  /// flips isLoading, so the screen shows the "preparing" view then question 1.
  Future<void> retake() async {
    _questionTimer?.cancel();
    currentIndex.value = 0;
    correctCount.value = 0;
    selectedOptionId.value = null;
    fillBlankController.clear();
    hasAnswered.value = false;
    isCurrentAnswerCorrect.value = false;
    ranOutOfTime.value = false;
    remainingSeconds.value = 0;
    starsAwarded.value = null;
    isSubmitting.value = false;
    isFinished.value = false;
    errorMessage.value = '';
    await _loadQuiz();
  }

  @override
  void onClose() {
    _questionTimer?.cancel();
    fillBlankController.dispose();
    super.onClose();
  }
}
