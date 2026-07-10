import 'package:flutter/material.dart';

import '../fns/hexToColor.dart';

class SubjectsModel {
  // Catalog fields — same for every student.
  final int id;
  final String subjectTitle;
  final String description;
  final String imageUrl;
  final Color buttonColor;

  // Derived fields — NOT part of the catalog JSON. Populated by
  // SubjectRepository after merging in topics.json (for lessonCount) and
  // topic_progress.json (for completedLessonCount/progressPercent), same
  // pattern used for TopicModel. Default to 0 until that merge happens.
  final int lessonCount;
  final int completedLessonCount;
  final int progressPercent;

  SubjectsModel({
    required this.id,
    required this.subjectTitle,
    required this.description,
    required this.imageUrl,
    required this.buttonColor,
    this.lessonCount = 0,
    this.completedLessonCount = 0,
    this.progressPercent = 0,
  });

  factory SubjectsModel.fromJson(Map<String, dynamic> json) {
    return SubjectsModel(
      id: json['id'],
      subjectTitle: json['title'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      buttonColor: hexToColor(json['button_color']),
    );
  }

  // Returns a copy with derived progress data merged in, used by the
  // repository once it has aggregated this subject's topics.
  SubjectsModel copyWithProgress({
    required int lessonCount,
    required int completedLessonCount,
    required int progressPercent,
  }) {
    return SubjectsModel(
      id: id,
      subjectTitle: subjectTitle,
      description: description,
      imageUrl: imageUrl,
      buttonColor: buttonColor,
      lessonCount: lessonCount,
      completedLessonCount: completedLessonCount,
      progressPercent: progressPercent,
    );
  }
}
