import 'package:eduplay/screens/home/subjects/chapters/quiz/models/question_opt_model.dart';

class QuestionModel {
  final int id;
  final QuestionType questionType;
  final String questionText;
  final String? questionImage;
  final List<QuestionOptionModel>? options;
  final List<String>? acceptedAnswers;
  final String? explanation;
  final int timeLimitSeconds;

  QuestionModel({
    required this.id,
    required this.questionType,
    required this.questionText,
    required this.timeLimitSeconds,
    this.questionImage,
    this.options,
    this.acceptedAnswers,
    this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['options'] as List<dynamic>?;
    final acceptedJson = json['accepted_answers'] as List<dynamic>?;

    return QuestionModel(
      id: json['id'] as int,
      questionType: questionTypeFromString(
        json['question_type'] as String? ?? 'mcq',
      ),
      questionText: json['question_text'] as String,
      questionImage: json['question_image'] as String?,
      options: optionsJson
          ?.map((e) => QuestionOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      acceptedAnswers: acceptedJson?.map((e) => e as String).toList(),
      explanation: json['explanation'] as String?,
      timeLimitSeconds: json['time_limit_seconds'] as int? ?? 20,
    );
  }
}
