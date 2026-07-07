import 'dart:ui';

import '../fns/hexToColor.dart';

class ContinueLearningModel {
  final int id;
  final String title;
  final String subtitle;
  final int progressPercent;
  final Color color;

  ContinueLearningModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.progressPercent,
    required this.color,
  });

  factory ContinueLearningModel.fromJson(Map<String, dynamic> json) {
    return ContinueLearningModel(
      id: json['id'],
      title: json['subject_title'],
      subtitle: json['lesson_title'],
      progressPercent: json['progress_percent'],
      color: hexToColor(json['accent_color']),
    );
  }
}
