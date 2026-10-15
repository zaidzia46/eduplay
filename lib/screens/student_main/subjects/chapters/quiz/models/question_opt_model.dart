enum QuestionType { mcq, fillBlank, trueFalse }

QuestionType questionTypeFromString(String value) {
  switch (value) {
    case 'fill_blank':
      return QuestionType.fillBlank;
    case 'true_false':
      return QuestionType.trueFalse;
    case 'mcq':
    default:
      return QuestionType.mcq;
  }
}

class QuestionOptionModel {
  final String id;
  final String type; // 'text' or 'image'
  final String value; // text answer, or a storage path when type == 'image'
  final int? count; // only for image options — how many times to render it
  final bool isCorrect;

  QuestionOptionModel({
    required this.id,
    required this.type,
    required this.value,
    required this.isCorrect,
    this.count,
  });

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModel(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'text',
      value: json['value'] as String,
      count: json['count'] as int?,
      isCorrect: json['is_correct'] as bool? ?? false,
    );
  }
}
