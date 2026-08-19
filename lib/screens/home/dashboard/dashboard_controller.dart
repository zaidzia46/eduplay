import 'dart:developer';

import 'package:eduplay/controller/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/continue_learning_model.dart';
import '../subjects/subject_repo.dart';
import '../subjects/subjects_model.dart';
import '../../profile/create_child_profile/repo/create_child_profile_repo.dart';
import '../../profile/profile_switcher/models/child_profile_model.dart';
import 'continue_learn_repo.dart';

class DashboardController extends GetxController {
  final SubjectRepository _subjectRepo = SubjectRepository();
  final LessonRepository _lessonRepo = LessonRepository();
  final ChildProfileRepository _childRepo = ChildProfileRepository();
  final SessionController _session = Get.find<SessionController>();

  final Rx<ChildProfileModel?> child = Rx<ChildProfileModel?>(null);
  final Rx<String?> avatarUrl = Rx<String?>(null);
  final RxBool isAvatarLoading = true.obs;

  var dashboardSubjects = <SubjectModel>[].obs;
  var isDashboardSubjectsLoading = true.obs;
  var errorSubjectMessage = ''.obs;

  var continueLearning = <ContinueLearningModel>[].obs;
  var isLessonLoading = true.obs;
  var errorLessonMessage = ''.obs;

  late final Worker _activeChildWorker;

  @override
  void onInit() {
    super.onInit();
    child.value = _session.activeChild.value;
    _loadAvatarUrl();
    _fetchDashboardSubjects();
    _activeChildWorker = ever(_session.activeChild, (updatedChild) {
      child.value = updatedChild;
      _loadAvatarUrl();
      _fetchDashboardSubjects();
    });
  }

  Future<void> _loadAvatarUrl() async {
    final path = child.value?.avatar;
    if (path == null) {
      avatarUrl.value = null;
      isAvatarLoading.value = false;
      return;
    }

    isAvatarLoading.value = true;
    try {
      final url = await _childRepo.getAvatarSignedUrl(path);
      if (child.value?.avatar == path) {
        avatarUrl.value = url;
      }
    } catch (e) {
      log('Could not load dashboard avatar: $e');
      if (child.value?.avatar == path) {
        avatarUrl.value = null;
      }
    } finally {
      if (child.value?.avatar == path) {
        isAvatarLoading.value = false;
      }
    }
  }

  Future<void> _fetchDashboardSubjects() async {
    final currentChild = child.value;
    final curriculumId = currentChild?.curriculumId;
    final standardId = currentChild?.standard?.id;

    if (curriculumId == null || standardId == null) {
      dashboardSubjects.value = [];
      isDashboardSubjectsLoading.value = false;
      return;
    }

    try {
      isDashboardSubjectsLoading.value = true;
      errorSubjectMessage.value = '';

      final allSubjects = await _subjectRepo.getSubjects(
        curriculumId: curriculumId,
        standardId: standardId,
      );

      // TODO: once child_progress_summary exists, sort by progress and take
      // the top 3 (e.g. subjects the child is mid-way through). For now,
      // there's no progress data to sort by, so this is just "first 3".
      dashboardSubjects.value = allSubjects.take(3).toList();
    } catch (e) {
      errorSubjectMessage.value = 'Could not load subjects';
    } finally {
      isDashboardSubjectsLoading.value = false;
    }
  }

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

  @override
  void onClose() {
    _activeChildWorker.dispose();
    super.onClose();
  }
}
