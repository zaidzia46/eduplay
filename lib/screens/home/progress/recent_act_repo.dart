import 'dart:convert';
import 'package:eduplay/controller/session_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../fns/hexToColor.dart';
import '../../../models/recent_act_model.dart';

class RecentActivityRepository {
  // Right now: loads recent_activity.json (now keyed per child) and
  // joins it against subjects.json client-side to resolve subject
  // title/color. Later: replace with a single
  // http.get('/progress/recent-activity') — the backend does the join
  // and the child-scoping, this method just deserializes the response.
  //
  // `childId` defaults to the active session child if not passed.
  Future<List<RecentActivityModel>> getRecentActivity({
    int limit = 10,
    int? childId,
  }) async {
    final resolvedChildId =
        childId ?? Get.find<SessionController>().activeChild.value?.id;

    final activityJson = jsonDecode(
      await rootBundle.loadString('assets/data/recent_activity.json'),
    );
    final Map<String, dynamic> activityByChild =
        activityJson['data']['activity'];
    final List activity = resolvedChildId == null
        ? []
        : (activityByChild['$resolvedChildId'] ?? []);

    final subjectsJson = jsonDecode(
      await rootBundle.loadString('assets/data/subjects.json'),
    );
    final List subjectList = subjectsJson['data']['subjects'];
    final subjectsById = {for (final s in subjectList) s['id']: s};

    final entries = activity.map((a) {
      final subject = subjectsById[a['subject_id']];

      return RecentActivityModel(
        id: a['id'],
        subjectId: a['subject_id'],
        subjectTitle: subject?['title'] ?? 'Unknown',
        subjectColor: hexToColor(subject?['button_color'] ?? '#6B7280'),
        type: a['type'] == 'quiz' ? ActivityType.quiz : ActivityType.lesson,
        title: a['title'],
        starsAwarded: a['stars_awarded'],
        timestamp: DateTime.parse(a['timestamp']),
      );
    }).toList();

    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries.take(limit).toList();
  }
}
