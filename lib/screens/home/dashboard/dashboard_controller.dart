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

  // Search/filter for the Subjects screen.
  final searchController = TextEditingController();
  var searchQuery = ''.obs;

  var filteredSubjects = <SubjectsModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubjects();
    fetchLessons();

    ever(Get.find<SessionController>().currentStandard, (_) {
      fetchSubjects();
      fetchLessons();
    });

    // Keep filteredSubjects in sync whenever the catalog or the query changes.
    ever(subjects, (_) => _applyFilter());
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _applyFilter();
    });
  }

  void _applyFilter() {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      filteredSubjects.value = subjects;
      return;
    }
    filteredSubjects.value = subjects
        .where((s) => s.subjectTitle.toLowerCase().contains(query))
        .toList();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applyFilter();
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

  @override
  void onClose() {
    // searchController.dispose(); uncomment after adding API, cause currently it dispose and cause error
    super.onClose();
  }
}
