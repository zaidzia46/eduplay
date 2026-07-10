import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';

import '../../../models/subjects_model.dart';

class SubjectRepository {
  // Right now: loads three local JSON assets and merges them client-side —
  // subjects (catalog), topics (catalog, grouped by subject), and
  // topic_progress (per-student) — mimicking the backend's future join.
  // Later: replace this method body with a single http.get(); the backend
  // does the aggregation, this method just deserializes the response.
  Future<List<SubjectsModel>> getSubjects({int? standard}) async {
    try {
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
      final Map<String, dynamic> progressById =
          progressJson['data']['progress'];

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

  // When backend is ready, replace with this: the aggregation already
  // happened server-side.
  // Future<List<SubjectsModel>> getSubjects({int? standard}) async {
  //   final response = await dio.get('/subjects');
  //   final List subjects = response.data['data']['subjects'];
  //   return subjects.map((item) => SubjectsModel.fromJson(item)).toList();
  // }
}
