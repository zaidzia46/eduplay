import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';

import '../../../models/topics_model.dart';

class TopicRepository {
  // ── Right now: loads from local JSON asset, filtered by subjectId ──
  // ── Later: replace this method body with an http.get() ─────────────
  //
  // `subjectId` is required — the backend has no way to infer which
  // subject was tapped, unlike `standardId` which it can default from
  // the student's active standard. `standardId` is accepted but left
  // unused for now; only pass it explicitly later for a "view topics
  // for a past standard" override.
  Future<List<TopicModel>> getTopics({
    required int subjectId,
    int? standardId,
  }) async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/topics.json',
      );
      final Map<String, dynamic> json = jsonDecode(response);
      final Map<String, dynamic> bySubject = json['data']['by_subject'];

      final List topics = bySubject['$subjectId'] ?? [];
      log('Topics: $topics');
      return topics.map((item) => TopicModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('1) Failed to load topics: $e');
    }
  }

  // ────────────── When backend is ready, replace with this: ─────────────────
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
