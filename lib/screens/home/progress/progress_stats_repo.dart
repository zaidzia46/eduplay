import 'dart:convert';
import 'package:eduplay/controller/session_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../models/progress_stat_model.dart';
import '../../../models/subjects_model.dart';

class ProgressStatsRepository {
  // Right now: loads progress_stats.json for the genuinely-new fields
  // (stars/streak/badges), now keyed per child, and derives
  // overallPercent/lessonsCompleted from the subjects list the caller
  // already fetched via SubjectRepository — not re-fetched or duplicated
  // here.
  // Later: a single backend summary endpoint can return all five fields
  // directly, at which point this aggregation logic moves server-side.
  //
  // `childId` defaults to the active session child, same pattern as
  // SubjectRepository, so existing call sites don't need to change.
  Future<ProgressStatsModel> getStats(
    List<SubjectsModel> subjects, {
    int? childId,
  }) async {
    final resolvedChildId =
        childId ?? Get.find<SessionController>().activeChild.value?.id;

    final String response = await rootBundle.loadString(
      'assets/data/progress_stats.json',
    );
    final Map<String, dynamic> json = jsonDecode(response);
    final Map<String, dynamic> statsByChild = json['data']['stats'];
    final data = resolvedChildId == null
        ? null
        : statsByChild['$resolvedChildId'];

    final totalLessons = subjects.fold<int>(0, (sum, s) => sum + s.lessonCount);
    final completedLessons = subjects.fold<int>(
      0,
      (sum, s) => sum + s.completedLessonCount,
    );
    final overallPercent = totalLessons == 0
        ? 0
        : ((completedLessons / totalLessons) * 100).round();

    return ProgressStatsModel(
      overallPercent: overallPercent,
      lessonsCompleted: completedLessons,
      starsEarned: data?['stars_earned'] ?? 0,
      daysActive: data?['days_active'] ?? 0,
      badgesEarned: data?['badges_earned'] ?? 0,
    );
  }
}
