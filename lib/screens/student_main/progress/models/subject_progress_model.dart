import 'package:flutter/material.dart';

import '../../../../fns/hexToColor.dart';

/// Per-subject progress row inside [ProgressOverviewModel]. `percent` is the
/// share of the subject's chapters the child has completed (all quizzes in
/// the chapter passed).
class SubjectProgressModel {
  final int standardSubjectId;
  final int subjectId;
  final String name;
  final Color color;
  final String? iconPath;
  final int chaptersTotal;
  final int chaptersCompleted;
  final int percent;

  SubjectProgressModel({
    required this.standardSubjectId,
    required this.subjectId,
    required this.name,
    required this.color,
    required this.iconPath,
    required this.chaptersTotal,
    required this.chaptersCompleted,
    required this.percent,
  });

  factory SubjectProgressModel.fromRpc(Map<String, dynamic> json) {
    final hex = json['color_hex'] as String?;
    return SubjectProgressModel(
      standardSubjectId: (json['standard_subject_id'] as num).toInt(),
      subjectId: (json['subject_id'] as num).toInt(),
      name: json['name'] as String? ?? 'Unknown',
      color: hex != null ? hexToColor(hex) : Colors.grey,
      iconPath: json['icon_path'] as String?,
      chaptersTotal: (json['chapters_total'] as num?)?.toInt() ?? 0,
      chaptersCompleted: (json['chapters_completed'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
    );
  }
}
