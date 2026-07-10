import 'package:flutter/material.dart';

enum ActivityType { lesson, quiz }

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
