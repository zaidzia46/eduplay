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

      // Layer per-chapter progress (passed quizzes / total) on top of the base
      // list when there's an active child. Without one we still show chapters,
      // just at 0%.
      final childId = Get.find<SessionController>().activeChild.value?.id;
      if (childId == null) {
        chapters.value = base;
        return;
      }

      final progress = await _progressRepo.getSubjectChapters(
        childId,
        subject.standardSubjectId,
      );
      final byId = {for (final p in progress) p.chapterId: p};

      chapters.value = base.map((chapter) {
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
    } catch (e) {
      error.value = 'Failed to load chapters: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
