class QuizModel {
  final int id;
  final String title;
  final int passingScorePercent;

  // Per-child progress, layered on after the base fetch (see QuizListController).
  // Defaults describe a never-attempted quiz.
  final int bestPercent; // best score across attempts, 0 if never attempted
  final bool isPassed; // any attempt reached passingScorePercent
  final bool attempted; // has at least one attempt

  QuizModel({
    required this.id,
    required this.title,
    this.passingScorePercent = 60,
    this.bestPercent = 0,
    this.isPassed = false,
    this.attempted = false,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as int,
      title: json['title'] as String,
      passingScorePercent: json['passing_score_percent'] as int? ?? 60,
    );
  }

  QuizModel copyWithProgress({
    int? bestPercent,
    bool? isPassed,
    bool? attempted,
  }) {
    return QuizModel(
      id: id,
      title: title,
      passingScorePercent: passingScorePercent,
      bestPercent: bestPercent ?? this.bestPercent,
      isPassed: isPassed ?? this.isPassed,
      attempted: attempted ?? this.attempted,
    );
  }
}
