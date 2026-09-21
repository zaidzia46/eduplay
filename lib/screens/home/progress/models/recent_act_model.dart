import 'package:flutter/material.dart';

enum ActivityType { lesson, quiz }

/// Recent-activity feed item. The app is quiz-first, so the progress feed only
/// ever produces [ActivityType.quiz] rows (title = quiz title, subjectTitle =
/// subject name); the `lesson` case is kept for the enum/label only.
class RecentActivityModel {
  final int id;
  final int subjectId;
  final String subjectTitle;
  final Color subjectColor;
  final ActivityType type;
  final String title;
  final int starsAwarded;
  final DateTime timestamp;

  RecentActivityModel({
    required this.id,
    required this.subjectId,
    required this.subjectTitle,
    required this.subjectColor,
    required this.type,
    required this.title,
    required this.starsAwarded,
    required this.timestamp,
  });

  String get typeLabel => type == ActivityType.quiz ? 'Quiz' : 'Lesson';
}
