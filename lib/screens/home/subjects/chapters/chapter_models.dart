enum ChapterStatus { notStarted, inProgress, completed }

class ChapterModel {
  final int id;
  final String title;
  final int sortOrder;

  // Derived — not available yet (needs lesson_progress/quiz_attempts,
  // neither exists). Defaults to notStarted/0 until that's built, same
  // role the old TopicModel's status/progressPercent played.
  final ChapterStatus status;
  final int progressPercent;

  ChapterModel({
    required this.id,
    required this.title,
    required this.sortOrder,
    this.status = ChapterStatus.notStarted,
    this.progressPercent = 0,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] as int,
      title: json['title'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  ChapterModel copyWithProgress({
    required ChapterStatus status,
    required int progressPercent,
  }) {
    return ChapterModel(
      id: id,
      title: title,
      sortOrder: sortOrder,
      status: status,
      progressPercent: progressPercent,
    );
  }
}
