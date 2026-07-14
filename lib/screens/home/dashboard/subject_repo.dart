import 'dart:convert';
import 'dart:developer';
import 'package:eduplay/controller/session_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../models/subjects_model.dart';

class SubjectRepository {
  // Right now: loads three local JSON assets and merges them client-side —
  // subjects (catalog), topics (catalog, grouped by subject), and
  // topic_progress (per-child, keyed by childId) — mimicking the backend's
  // future join. Later: replace this method body with a single http.get();
  // the backend does the aggregation, this method just deserializes the
  // response.
  //
  // `childId` defaults to the currently active session child if not
  // passed, so existing call sites (Dashboard, Progress screen) don't
  // need to change. Profile Switcher passes each child's own id
  // explicitly, since it needs to show several children's progress
  // side by side, not just "whoever is active right now".
  Future<List<SubjectsModel>> getSubjects({int? standard, int? childId}) async {
    try {
      final resolvedChildId =
          childId ?? Get.find<SessionController>().activeChild.value?.id;

      final String subjectsResponse = await rootBundle.loadString(
        'assets/data/subjects.json',
      );
      final Map<String, dynamic> subjectsJson = jsonDecode(subjectsResponse);
      final List subjectList = subjectsJson['data']['subjects'];

      final String topicsResponse = await rootBundle.loadString(
        'assets/data/topics.json',
      );
      final Map<String, dynamic> topicsJson = jsonDecode(topicsResponse);
      final Map<String, dynamic> bySubject = topicsJson['data']['by_subject'];

      final String progressResponse = await rootBundle.loadString(
        'assets/data/topic_progress.json',
      );
      final Map<String, dynamic> progressJson = jsonDecode(progressResponse);
      final Map<String, dynamic> progressByChild =
          progressJson['data']['progress'];
      final Map<String, dynamic> progressById = resolvedChildId == null
          ? {}
          : (progressByChild['$resolvedChildId'] ?? {});

      return subjectList.map((item) {
        final subject = SubjectsModel.fromJson(item);
        final List topicsForSubject = bySubject['${subject.id}'] ?? [];

        final lessonCount = topicsForSubject.length;

        final completedLessonCount = topicsForSubject.where((t) {
          final progressRow = progressById['${t['id']}'];
          return progressRow != null && progressRow['status'] == 'completed';
        }).length;

        final progressPercent = lessonCount == 0
            ? 0
            : ((completedLessonCount / lessonCount) * 100).round();

        return subject.copyWithProgress(
          lessonCount: lessonCount,
          completedLessonCount: completedLessonCount,
          progressPercent: progressPercent,
        );
      }).toList();
    } catch (e) {
      log('Error in subjects: $e');
      throw Exception('Failed to load subjects: $e');
    }
  }

  // Lean helper for cards that only need one number — e.g. the Profile
  // Switcher's per-child progress badge — without the caller needing to
  // re-derive the aggregation itself.
  Future<int> getOverallPercent({required int childId}) async {
    final subjects = await getSubjects(childId: childId);
    final totalLessons = subjects.fold<int>(0, (sum, s) => sum + s.lessonCount);
    final completedLessons = subjects.fold<int>(
      0,
      (sum, s) => sum + s.completedLessonCount,
    );
    return totalLessons == 0
        ? 0
        : ((completedLessons / totalLessons) * 100).round();
  }

  // When backend is ready, replace with this: the aggregation already
  // happened server-side.
  // Future<List<SubjectsModel>> getSubjects({int? standard}) async {
  //   final response = await dio.get('/subjects');
  //   final List subjects = response.data['data']['subjects'];
  //   return subjects.map((item) => SubjectsModel.fromJson(item)).toList();
  // }
}
