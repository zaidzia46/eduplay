import 'dart:developer';

import 'package:eduplay/controller/session_controller.dart';
import 'package:eduplay/screens/home/dashboard/subject_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/continue_learning_model.dart';
import '../../../models/subjects_model.dart';
import 'continue_learn_repo.dart';

class DashboardController extends GetxController {
  final SubjectRepository _subjectRepo = SubjectRepository();
  final LessonRepository _lessonRepo = LessonRepository();

  var subjects = <SubjectsModel>[].obs;
  var continueLearning = <ContinueLearningModel>[].obs;
  var isSubjectsLoading = true.obs;
  var isLessonLoading = true.obs;
  var errorSubjectMessage = ''.obs;
  var errorLessonMessage = ''.obs;

  final searchController = TextEditingController();
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubjects();
    fetchLessons();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    ever(Get.find<SessionController>().currentStandard, (_) {
      fetchSubjects();
      fetchLessons();
    });
  }

  List<SubjectsModel> get filteredSubjects {
    if (searchQuery.value.isEmpty) return subjects;
    return subjects
        .where(
          (s) => s.subjectTitle.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ),
        )
        .toList();
  }

  Future<void> fetchSubjects() async {
    try {
      isSubjectsLoading.value = true;
      errorSubjectMessage.value = '';
      subjects.value = await _subjectRepo.getSubjects();
    } catch (e) {
      errorSubjectMessage.value = 'Could not load subjects';
    } finally {
      isSubjectsLoading.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // void onSubjectTap(SubjectsModel subject) {
  //   Get.toNamed(AppRoutes.subjectHome, arguments: {'subject': subject});
  // }

  Future<void> fetchLessons() async {
    try {
      isLessonLoading.value = true;
      errorLessonMessage.value = '';
      continueLearning.value = await _lessonRepo.getContinueLearning();
    } catch (e) {
      errorLessonMessage.value = 'Could not load lessons';
      log('Error in lessons: $e');
    } finally {
      isLessonLoading.value = false;
    }
  }

  // void onLessonTap(ContinueLearningModel lessons) {
  //   Get.toNamed(AppRoutes.lessonsHome, arguments: {'lesson': lesson});
  // }
}
