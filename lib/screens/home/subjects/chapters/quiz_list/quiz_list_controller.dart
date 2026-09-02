import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../controller/session_controller.dart';
import 'quiz_list_repo.dart';
import 'quiz_model.dart';

class QuizListController extends GetxController {
  final QuizListRepository _repo = QuizListRepository();
  final SessionController _session = Get.find<SessionController>();

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
      await _mergeProgress();
    } catch (e) {
      error.value = 'Failed to load quizzes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Re-pull only the per-quiz progress and layer it onto the quizzes already
  /// on screen. Used when returning from a quiz — no skeleton flash, since the
  /// list itself hasn't changed, only the scores.
  Future<void> refreshProgress() async {
    try {
      await _mergeProgress();
    } catch (_) {
      // Leave the last-known percentages in place on a transient failure.
    }
  }

  /// Fetch best-score / pass state for the active child and fold it onto the
  /// current quiz list. No-op (progress stays at defaults) when there's no
  /// active child.
  Future<void> _mergeProgress() async {
    final childId = _session.activeChild.value?.id;
    if (childId == null || quizzes.isEmpty) return;

    final progress = await _repo.getQuizProgress(
      childId: childId,
      chapterId: chapterId,
    );

    quizzes.value = quizzes.map((q) {
      final p = progress[q.id];
      return q.copyWithProgress(
        bestPercent: p?.bestPercent ?? 0,
        isPassed: p?.isPassed ?? false,
        attempted: p?.attempted ?? false,
      );
    }).toList();
  }
}
