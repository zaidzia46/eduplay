import 'dart:developer';
import 'dart:ui';

import 'package:eduplay/screens/home/topics/topics_repo.dart';
import 'package:get/get.dart';

import '../../../models/subjects_model.dart';
import '../../../models/topics_model.dart';

class TopicController extends GetxController {
  final TopicRepository _topicRepo = TopicRepository();

  final SubjectsModel subject;
  TopicController({required this.subject});

  @override
  void onInit() {
    super.onInit();
    fetchTopics();
  }

  var topics = <TopicModel>[].obs;
  var isLoading = true.obs;
  var error = ''.obs;

  Future<void> fetchTopics() async {
    try {
      isLoading.value = true;
      error.value = '';
      topics.value = await _topicRepo.getTopics(subjectId: subject.id);
    } catch (e) {
      isLoading.value = false;
      error.value = '2) Failed to load topics ${e}';
    } finally {
      isLoading.value = false;
    }
  }

  // void onTopicTap(TopicModel topic) {
  //   Get.toNamed(AppRoutes.lesson, arguments: {'subject': subject, 'topic': topic});
  // }
}
