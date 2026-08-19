import 'package:get/get.dart';

import '../subjects_model.dart';
import 'chapter_models.dart';
import 'chapter_repo.dart';

class ChapterController extends GetxController {
  final ChapterRepository _topicRepo = ChapterRepository();

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
      chapters.value = await _topicRepo.getTopics(
        standardSubjectId: subject.standardSubjectId,
      );
    } catch (e) {
      error.value = 'Failed to load chapters: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
