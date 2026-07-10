class ProgressStatsModel {
  // Derived — computed by ProgressStatsRepository from the already-fetched
  // subjects list (sum of lessonCount / completedLessonCount), NOT stored
  // in progress_stats.json. Avoids duplicating data SubjectRepository
  // already owns.
  final int overallPercent;
  final int lessonsCompleted;

  // Genuinely new — no other part of the app tracks these yet. Read
  // directly from progress_stats.json for now.
  final int starsEarned;
  final int daysActive;
  final int badgesEarned;

  ProgressStatsModel({
    required this.overallPercent,
    required this.lessonsCompleted,
    required this.starsEarned,
    required this.daysActive,
    required this.badgesEarned,
  });
}
