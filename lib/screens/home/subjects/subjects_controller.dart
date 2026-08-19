import 'package:eduplay/controller/session_controller.dart';
import 'package:eduplay/screens/home/subjects/widgets/filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'subject_repo.dart';
import 'subjects_model.dart';

enum SubjectFilter { all, notStarted, inProgress, completed }

class SubjectsController extends GetxController {
  final SubjectRepository _subjectRepo = SubjectRepository();
  final SessionController _session = Get.find<SessionController>();

  var subjects = <SubjectModel>[].obs;
  var filteredSubjects = <SubjectModel>[].obs;
  var isSubjectsLoading = true.obs;
  var errorSubjectMessage = ''.obs;
  var activeFilter = SubjectFilter.all.obs;

  var searchQuery = ''.obs;

  late final Worker _activeChildWorker;

  @override
  void onInit() {
    super.onInit();
    fetchSubjects();

    ever(subjects, (_) => _applyFilter());
    ever(activeFilter, (_) => _applyFilter());
    _activeChildWorker = ever(_session.activeChild, (_) => fetchSubjects());
  }

  Future<void> fetchSubjects() async {
    final currentChild = _session.activeChild.value;
    final curriculumId = currentChild?.curriculumId;
    final standardId = currentChild?.standard?.id;

    if (curriculumId == null || standardId == null) {
      subjects.value = [];
      isSubjectsLoading.value = false;
      return;
    }

    try {
      isSubjectsLoading.value = true;
      errorSubjectMessage.value = '';

      subjects.value = await _subjectRepo.getSubjects(
        curriculumId: curriculumId,
        standardId: standardId,
      );
    } catch (e) {
      errorSubjectMessage.value = 'Could not load subjects';
    } finally {
      isSubjectsLoading.value = false;
    }
  }

  void _applyFilter() {
    final query = searchQuery.value.trim().toLowerCase();

    var result = subjects.toList();

    if (query.isNotEmpty) {
      result = result
          .where((s) => s.name.toLowerCase().contains(query))
          .toList();
    }

    // NOTE: progressPercent defaults to 0 for every subject until
    // child_progress_summary exists — so notStarted/inProgress/completed
    // filters will currently just put everything in "notStarted". Wiring
    // stays in place so this works automatically once that table lands.
    switch (activeFilter.value) {
      case SubjectFilter.notStarted:
        result = result.where((s) => s.progressPercent == 0).toList();
        break;
      case SubjectFilter.inProgress:
        result = result
            .where((s) => s.progressPercent > 0 && s.progressPercent < 100)
            .toList();
        break;
      case SubjectFilter.completed:
        result = result.where((s) => s.progressPercent == 100).toList();
        break;
      case SubjectFilter.all:
        break;
    }

    filteredSubjects.value = result;
  }

  void setFilter(SubjectFilter filter) {
    activeFilter.value = filter;
  }

  void showFilterSheet() {
    Get.bottomSheet(
      FilterSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void clearSearch() {
    searchQuery.value = '';
    _applyFilter();
  }

  void updateSearchQuery(String value) {
    searchQuery.value = value;
    _applyFilter();
  }

  @override
  void onClose() {
    _activeChildWorker.dispose();
    super.onClose();
  }
}
