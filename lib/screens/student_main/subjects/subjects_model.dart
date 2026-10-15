import 'package:flutter/material.dart';
import '../../../fns/hexToColor.dart';

class SubjectModel {
  final int id;

  // standard_subjects.id, not subjects.id — chapters/topics will reference
  // this once that table exists, not the subject's own id.
  final int standardSubjectId;

  final String name;
  final String? iconPath;
  final Color colorHex;

  // Derived — not fetchable yet (needs chapters + lesson_progress tables,
  // neither exists). Default to 0 until that's built; same role as before,
  // just no longer populated from topics.json/topic_progress.json.
  final int lessonCount;
  final int completedLessonCount;
  final int progressPercent;

  SubjectModel({
    required this.id,
    required this.standardSubjectId,
    required this.name,
    required this.colorHex,
    this.iconPath,
    this.lessonCount = 0,
    this.completedLessonCount = 0,
    this.progressPercent = 0,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subjects'] as Map<String, dynamic>;
    final colorHexString = subject['color_hex'] as String?;

    return SubjectModel(
      standardSubjectId: json['id'] as int,
      id: subject['id'] as int,
      name: subject['name'] as String,
      iconPath: subject['icon_path'] as String?,
      colorHex: colorHexString != null
          ? hexToColor(colorHexString)
          : Colors.grey,
    );
  }

  SubjectModel copyWithProgress({
    required int lessonCount,
    required int completedLessonCount,
    required int progressPercent,
  }) {
    return SubjectModel(
      id: id,
      standardSubjectId: standardSubjectId,
      name: name,
      iconPath: iconPath,
      colorHex: colorHex,
      lessonCount: lessonCount,
      completedLessonCount: completedLessonCount,
      progressPercent: progressPercent,
    );
  }
}
