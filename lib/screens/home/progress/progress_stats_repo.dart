import 'dart:convert';
import 'package:flutter/services.dart';

import '../../../models/progress_stat_model.dart';
import '../../../models/subjects_model.dart';

class ProgressStatsRepository {
  // Right now: loads progress_stats.json for the genuinely-new fields
  // (stars/streak/badges), and derives overallPercent/lessonsCompleted
  // from the subjects list the controller already fetched via
  // SubjectRepository — not re-fetched or duplicated here.
  // Later: a single backend summary endpoint can return all five fields
  // directly, at which point this aggregation logic moves server-side.
  Future<ProgressStatsModel> getStats(List<SubjectsModel> subjects) async {
    final String response = await rootBundle.loadString(
      'assets/data/progress_stats.json',
    );
    final Map<String, dynamic> json = jsonDecode(response);
    final data = json['data'];

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
      starsEarned: data['stars_earned'],
      daysActive: data['days_active'],
      badgesEarned: data['badges_earned'],
    );
  }
}
