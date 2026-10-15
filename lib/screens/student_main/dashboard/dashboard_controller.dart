import 'dart:developer';

import 'package:eduplay/controller/session_controller.dart';
import 'package:get/get.dart';

import '../subjects/subject_repo.dart';
import '../subjects/subjects_model.dart';
import '../../profile/create_child_profile/repo/create_child_profile_repo.dart';
import '../../profile/profile_switcher/models/child_profile_model.dart';

class DashboardController extends GetxController {
  final SubjectRepository _subjectRepo = SubjectRepository();
  final ChildProfileRepository _childRepo = ChildProfileRepository();
  final SessionController _session = Get.find<SessionController>();

  final Rx<ChildProfileModel?> child = Rx<ChildProfileModel?>(null);
  final Rx<String?> avatarUrl = Rx<String?>(null);
  final RxBool isAvatarLoading = true.obs;

  var dashboardSubjects = <SubjectModel>[].obs;
  var isDashboardSubjectsLoading = true.obs;
  var errorSubjectMessage = ''.obs;

  // var continueLearning = <ContinueLearningModel>[].obs;
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
      final previous = child.value;
      child.value = updatedChild;
      // A pure counter refresh (stars / streak / overall%) still has to update
      // child.value so the stat chips rebuild, but it shouldn't re-hit the
      // subjects / avatar endpoints — only reload those when the child identity
      // or its enrollment actually changed.
      if (_needsContentReload(previous, updatedChild)) {
        _loadAvatarUrl();
        _fetchDashboardSubjects();
      }
    });
    // The cached active child can hold a stale streak / stars — e.g. after the
    // daily streak-decay job or a quiz played elsewhere — so re-read the server
    // counters on every open to keep the chips in sync with the backend. The
    // worker above picks up the result and rebuilds the chips.
    _session.refreshActiveChildCounters().catchError((_) {});
  }

  bool _needsContentReload(
    ChildProfileModel? previous,
    ChildProfileModel? next,
  ) {
    if (previous == null || next == null) return true;
    return previous.id != next.id ||
        previous.curriculumId != next.curriculumId ||
        previous.standard?.id != next.standard?.id ||
        previous.avatar != next.avatar;
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

      dashboardSubjects.value = allSubjects.take(3).toList();
    } catch (e) {
      errorSubjectMessage.value = 'Could not load subjects';
    } finally {
      isDashboardSubjectsLoading.value = false;
    }
  }

  @override
  void onClose() {
    _activeChildWorker.dispose();
    super.onClose();
  }
}
