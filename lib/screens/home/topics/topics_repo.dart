import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';

import '../../../models/topics_model.dart';

class TopicRepository {
  // Right now: loads two local JSON assets and merges them client-side,
  // mimicking the backend's future LEFT JOIN between the topics catalog
  // table and the per-student topic_progress table. Later: replace this
  // method body with a single http.get() — the backend does the join,
  // this method just deserializes the response.
  //
  // `subjectId` is required, the backend has no way to infer which
  // subject was tapped, unlike `standardId` which it can default from
  // the student's active standard. `standardId` is accepted but left
  // unused for now, only pass it explicitly later for a "view topics
  // for a past standard" override.
  Future<List<TopicModel>> getTopics({
    required int subjectId,
    int? standardId,
  }) async {
    try {
      final String catalogResponse = await rootBundle.loadString(
        'assets/data/topics.json',
      );
      final Map<String, dynamic> catalogJson = jsonDecode(catalogResponse);
      final Map<String, dynamic> bySubject = catalogJson['data']['by_subject'];
      final List catalogTopics = bySubject['$subjectId'] ?? [];

      final String progressResponse = await rootBundle.loadString(
        'assets/data/topic_progress.json',
      );
      final Map<String, dynamic> progressJson = jsonDecode(progressResponse);
      final Map<String, dynamic> progressById =
          progressJson['data']['progress'];

      final topics = catalogTopics.map((item) {
        final topic = TopicModel.fromJson(item);
        final progressRow = progressById['${topic.id}'];

        // No row in topic_progress means this student has never started
        // this topic, so it stays at the model's default: notStarted, 0%.
        if (progressRow == null) return topic;

        final status = switch (progressRow['status']) {
          'completed' => TopicStatus.completed,
          'in_progress' => TopicStatus.inProgress,
          _ => TopicStatus.notStarted,
        };

        return topic.copyWithProgress(
          status: status,
          progressPercent: progressRow['percent_complete'] ?? 0,
        );
      }).toList();

      log('Topics: $topics');
      return topics;
    } catch (e) {
      throw Exception('Failed to load topics: $e');
    }
  }

  // When backend is ready, replace with this: the join already happened
  // server-side, so this becomes a plain fetch-and-deserialize again.
  // Future<List<TopicModel>> getTopics({
  //   required int subjectId,
  //   int? standardId,
  // }) async {
  //   final response = await dio.get(
  //     '/subjects/$subjectId/topics',
  //     queryParameters: standardId != null ? {'standardId': standardId} : null,
  //   );
  //   final List topics = response.data['data']['topics'];
  //   return topics.map((item) => TopicModel.fromJson(item)).toList();
  // }
}
