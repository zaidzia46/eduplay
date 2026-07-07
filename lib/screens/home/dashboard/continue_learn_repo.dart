import 'dart:convert';
import 'package:flutter/services.dart';

import '../../../fns/hexToColor.dart';
import '../../../models/continue_learning_model.dart';

class LessonRepository {
  // Right now: derives "Continue Learning" by joining three local JSON
  // assets client-side — topic_progress (per-student), topics (catalog,
  // grouped by subject), and subjects (catalog). This mirrors what a
  // single backend endpoint will eventually do server-side with one
  // query joining topic_progress -> topics -> subjects.
  //
  // Only topics with status "in_progress" are included, a completed
  // topic has nothing left to "continue". Sorted by most recently
  // touched first, limited to a handful for the dashboard rail.
  Future<List<ContinueLearningModel>> getContinueLearning({
    int? standard,
  }) async {
    try {
      final progressJson = jsonDecode(
        await rootBundle.loadString('assets/data/topic_progress.json'),
      );
      final Map<String, dynamic> progressById =
          progressJson['data']['progress'];

      final topicsJson = jsonDecode(
        await rootBundle.loadString('assets/data/topics.json'),
      );
      final Map<String, dynamic> bySubject = topicsJson['data']['by_subject'];

      final subjectsJson = jsonDecode(
        await rootBundle.loadString('assets/data/subjects.json'),
      );
      final List subjectList = subjectsJson['data']['subjects'];
      final subjectsById = {for (final s in subjectList) s['id']: s};

      // Flatten topics.json's by_subject map into a single
      // topicId -> {subjectId, title} lookup.
      final topicLookup = <int, Map<String, dynamic>>{};
      bySubject.forEach((subjectIdKey, topicList) {
        for (final t in topicList) {
          topicLookup[t['id']] = {
            'subjectId': int.parse(subjectIdKey),
            'title': t['topic'],
          };
        }
      });

      final entries = <ContinueLearningModel>[];
      progressById.forEach((topicIdKey, progress) {
        if (progress['status'] != 'in_progress') return;

        final topicId = int.parse(topicIdKey);
        final topicInfo = topicLookup[topicId];
        if (topicInfo == null) return;

        final subject = subjectsById[topicInfo['subjectId']];
        if (subject == null) return;

        entries.add(
          ContinueLearningModel(
            topicId: topicId,
            subjectId: topicInfo['subjectId'],
            subjectTitle: subject['title'],
            topicTitle: topicInfo['title'],
            progressPercent: progress['percent_complete'],
            color: hexToColor(subject['button_color']),
          ),
        );
      });

      // Backend will do this ordering via ORDER BY updated_at DESC.
      // Re-parsing raw JSON here since ContinueLearningModel doesn't
      // carry the timestamp, it's only needed for this sort.
      entries.sort((a, b) {
        final aTime = progressById['${a.topicId}']['updated_at'] as String;
        final bTime = progressById['${b.topicId}']['updated_at'] as String;
        return bTime.compareTo(aTime);
      });

      return entries.take(4).toList();
    } catch (e) {
      throw Exception('Failed to load lessons: $e');
    }
  }

  // When backend is ready, replace with this: the join and ordering
  // already happened server-side.
  // Future<List<ContinueLearningModel>> getContinueLearning({int? standard}) async {
  //   final response = await dio.get('/continue-learning');
  //   final List items = response.data['data']['items'];
  //   return items.map((item) => ContinueLearningModel.fromJson(item)).toList();
  // }
}
