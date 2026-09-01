class QuizModel {
  final int id;
  final String title;
  final int passingScorePercent;

  QuizModel({
    required this.id,
    required this.title,
    this.passingScorePercent = 60,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as int,
      title: json['title'] as String,
      passingScorePercent: json['passing_score_percent'] as int? ?? 60,
    );
  }
}
