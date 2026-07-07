import 'dart:ui';

import '../fns/hexToColor.dart';

import 'dart:ui';

class ContinueLearningModel {
  final int topicId;
  final int subjectId;
  final String subjectTitle;
  final String topicTitle;
  final int progressPercent;
  final Color color;

  ContinueLearningModel({
    required this.topicId,
    required this.subjectId,
    required this.subjectTitle,
    required this.topicTitle,
    required this.progressPercent,
    required this.color,
  });

  factory ContinueLearningModel.fromJson(Map<String, dynamic> json) {
    return ContinueLearningModel(
      topicId: json['id'],
      subjectId: json['subject_id'],
      subjectTitle: json['subject_title'],
      topicTitle: json['topic_title'],
      progressPercent: json['progress_percent'],
      color: hexToColor(json['color']),
    );
  }
}
