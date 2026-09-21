/// Per-chapter progress within a subject, from the
/// `get_child_subject_chapters` RPC. Feeds the ChapterScreen progress bars.
class ChapterProgressModel {
  final int chapterId;
  final String title;
  final int sortOrder;
  final int quizzesTotal;
  final int quizzesPassed;
  final int percent;
  final bool isCompleted;

  ChapterProgressModel({
    required this.chapterId,
    required this.title,
    required this.sortOrder,
    required this.quizzesTotal,
    required this.quizzesPassed,
    required this.percent,
    required this.isCompleted,
  });

  factory ChapterProgressModel.fromRpc(Map<String, dynamic> json) {
    return ChapterProgressModel(
      chapterId: (json['chapter_id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      quizzesTotal: (json['quizzes_total'] as num?)?.toInt() ?? 0,
      quizzesPassed: (json['quizzes_passed'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }
}
