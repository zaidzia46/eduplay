import 'dart:developer';
import 'dart:math';

import 'package:eduplay/controller/session_controller.dart';
import 'package:eduplay/screens/home/dashboard/subject_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/continue_learning_model.dart';
import '../../../models/subjects_model.dart';
import '../../../widgets/filter_sheet.dart';
import '../../profile/create_child_profile/repo/create_child_profile_repo.dart';
import '../../profile/profile_switcher/models/child_profile_model.dart';
import 'continue_learn_repo.dart';

enum SubjectFilter { all, notStarted, inProgress, completed }

class DashboardController extends GetxController {
  final SubjectRepository _subjectRepo = SubjectRepository();
  final LessonRepository _lessonRepo = LessonRepository();
  final ChildProfileRepository _childRepo = ChildProfileRepository();
  final SessionController _session = Get.find<SessionController>();

  final Rx<ChildProfileModel?> child = Rx<ChildProfileModel?>(null);
  final Rx<String?> avatarUrl = Rx<String?>(null);

  var subjects = <SubjectsModel>[].obs;
  var dashboardSubjects = <SubjectsModel>[].obs;
  var continueLearning = <ContinueLearningModel>[].obs;
  var isSubjectsLoading = true.obs;
  var isLessonLoading = true.obs;
  var errorSubjectMessage = ''.obs;
  var errorLessonMessage = ''.obs;
  var activeFilter = SubjectFilter.all.obs;
  final searchController = TextEditingController();
  var searchQuery = ''.obs;

  var filteredSubjects = <SubjectsModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    child.value = _session.activeChild.value;
    _loadAvatarUrl();
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

  Future<void> _loadAvatarUrl() async {
    final path = child.value?.avatar;
    avatarUrl.value = path != null
        ? await _childRepo.getAvatarSignedUrl(path)
        : null;
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
      final allSubjects = await _subjectRepo.getSubjects();

      subjects.value = allSubjects;

      dashboardSubjects.value = List.of(allSubjects)
        ..sort((a, b) => b.progressPercent.compareTo(a.progressPercent));

      dashboardSubjects.value = dashboardSubjects.take(3).toList();
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
