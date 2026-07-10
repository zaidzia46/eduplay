import 'dart:convert';
import 'package:flutter/services.dart';

import '../../../fns/hexToColor.dart';
import '../../../models/recent_act_model.dart';

class RecentActivityRepository {
  // Right now: loads recent_activity.json and joins it against
  // subjects.json client-side to resolve subject title/color, mirroring
  // continue_learn_repo.dart's join pattern. Later: replace with a single
  // http.get('/progress/recent-activity') — the backend does the join,
  // this method just deserializes the response.
  Future<List<RecentActivityModel>> getRecentActivity({int limit = 10}) async {
    final activityJson = jsonDecode(
      await rootBundle.loadString('assets/data/recent_activity.json'),
    );
    final List activity = activityJson['data']['activity'];

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
