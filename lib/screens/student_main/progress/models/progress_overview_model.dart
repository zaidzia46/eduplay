import 'subject_progress_model.dart';

/// The full Progress-tab overview, computed server-side by the
/// `get_child_progress` RPC (see docs/progress-rpcs.sql).
///
/// Everything here is pass-based: a quiz counts once the child's best
/// attempt reaches the quiz's passing_score_percent. Chapter % rolls up from
/// passed quizzes, subject % from completed chapters, and overall % is the
/// average subject % over subjects that actually have content.
class ProgressOverviewModel {
  final int overallPercent;
  final int subjectsCompleted;
  final int subjectsTotal;
  final int chaptersCompleted;
  final int chaptersTotal;
  final int quizzesPassed;
  final int quizzesTotal;
  final List<SubjectProgressModel> subjects;

  ProgressOverviewModel({
    required this.overallPercent,
    required this.subjectsCompleted,
    required this.subjectsTotal,
    required this.chaptersCompleted,
    required this.chaptersTotal,
    required this.quizzesPassed,
    required this.quizzesTotal,
    required this.subjects,
  });

  factory ProgressOverviewModel.fromRpc(Map<String, dynamic> json) {
    final rawSubjects = (json['subjects'] as List?) ?? const [];
    return ProgressOverviewModel(
      overallPercent: (json['overall_percent'] as num?)?.toInt() ?? 0,
      subjectsCompleted: (json['subjects_completed'] as num?)?.toInt() ?? 0,
      subjectsTotal: (json['subjects_total'] as num?)?.toInt() ?? 0,
      chaptersCompleted: (json['chapters_completed'] as num?)?.toInt() ?? 0,
      chaptersTotal: (json['chapters_total'] as num?)?.toInt() ?? 0,
      quizzesPassed: (json['quizzes_passed'] as num?)?.toInt() ?? 0,
      quizzesTotal: (json['quizzes_total'] as num?)?.toInt() ?? 0,
      subjects: rawSubjects
          .map((e) =>
              SubjectProgressModel.fromRpc(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  factory ProgressOverviewModel.empty() => ProgressOverviewModel(
        overallPercent: 0,
        subjectsCompleted: 0,
        subjectsTotal: 0,
        chaptersCompleted: 0,
        chaptersTotal: 0,
        quizzesPassed: 0,
        quizzesTotal: 0,
        subjects: const [],
      );
}
