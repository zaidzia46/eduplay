import 'dart:developer';

import 'package:eduplay/controller/session_controller.dart';
import 'package:eduplay/screens/home/dashboard/subject_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/continue_learning_model.dart';
import '../../../models/subjects_model.dart';
import '../../../widgets/filter_sheet.dart';
import 'continue_learn_repo.dart';

enum SubjectFilter { all, notStarted, inProgress, completed }

class DashboardController extends GetxController {
  final SubjectRepository _subjectRepo = SubjectRepository();
  final LessonRepository _lessonRepo = LessonRepository();

  var subjects = <SubjectsModel>[].obs;
  var continueLearning = <ContinueLearningModel>[].obs;
  var isSubjectsLoading = true.obs;
  var isLessonLoading = true.obs;
  var errorSubjectMessage = ''.obs;
  var errorLessonMessage = ''.obs;
  var activeFilter = SubjectFilter.all.obs;
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

    ever(subjects, (_) => _applyFilter());
    ever(activeFilter, (_) => _applyFilter());
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _applyFilter();
    });
  }

  void _applyFilter() {
    final query = searchQuery.value.trim().toLowerCase();

    var result = subjects.toList();

    if (query.isNotEmpty) {
      result = result
          .where((s) => s.subjectTitle.toLowerCase().contains(query))
          .toList();
    }

    switch (activeFilter.value) {
      case SubjectFilter.notStarted:
        result = result.where((s) => (s.progressPercent ?? 0) == 0).toList();
        break;
      case SubjectFilter.inProgress:
        result = result
            .where(
              (s) =>
                  (s.progressPercent ?? 0) > 0 &&
                  (s.progressPercent ?? 0) < 100,
            )
            .toList();
        break;
      case SubjectFilter.completed:
        result = result.where((s) => (s.progressPercent ?? 0) == 100).toList();
        break;
      case SubjectFilter.all:
        break;
    }

    filteredSubjects.value = result;
  }

  void setFilter(SubjectFilter filter) {
    activeFilter.value = filter;
    _applyFilter();
  }

  void showFilterSheet() {
    Get.bottomSheet(
      FilterSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
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
