import 'package:eduplay/controller/session_controller.dart';
import 'package:get/get.dart';

import '../../progress/progress_repo.dart';
import '../subjects_model.dart';
import 'chapter_models.dart';
import 'chapter_repo.dart';

class ChapterController extends GetxController {
  final ChapterRepository _topicRepo = ChapterRepository();
  final ProgressRepository _progressRepo = ProgressRepository();

  final SubjectModel subject;
  ChapterController({required this.subject});

  var chapters = <ChapterModel>[].obs;
  var isLoading = true.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChapters();
  }

  Future<void> fetchChapters() async {
    try {
      isLoading.value = true;
      error.value = '';

      final base = await _topicRepo.getTopics(
        standardSubjectId: subject.standardSubjectId,
      );
      chapters.value = await _withProgress(base);
    } catch (e) {
      error.value = 'Failed to load chapters: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Re-pull only per-chapter progress and fold it onto the chapters already on
  /// screen — used when returning from the quiz list so the bars/percentages
  /// aren't stale. No isLoading toggle, so there's no skeleton flash.
  Future<void> refreshProgress() async {
    if (chapters.isEmpty) return;
    try {
      chapters.value = await _withProgress(chapters);
    } catch (_) {
      // Keep last-known percentages on a transient failure.
    }
  }

  /// Layer per-chapter progress (passed quizzes / total) on top of [base] when
  /// there's an active child. Without one we still show chapters, just at 0%.
  /// Always returns a fresh list.
  Future<List<ChapterModel>> _withProgress(List<ChapterModel> base) async {
    final childId = Get.find<SessionController>().activeChild.value?.id;
    if (childId == null) return List<ChapterModel>.from(base);

    final progress = await _progressRepo.getSubjectChapters(
      childId,
      subject.standardSubjectId,
    );
    final byId = {for (final p in progress) p.chapterId: p};

    return base.map((chapter) {
      final p = byId[chapter.id];
      if (p == null) return chapter;
      final status = p.isCompleted
          ? ChapterStatus.completed
          : (p.quizzesPassed > 0
                ? ChapterStatus.inProgress
                : ChapterStatus.notStarted);
      return chapter.copyWithProgress(
        status: status,
        progressPercent: p.percent,
      );
    }).toList();
  }
}
