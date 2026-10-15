import 'package:flutter/material.dart' show Color;

import '../../../core/supabase_client.dart';
import '../../../fns/hexToColor.dart';
import 'models/chapter_progress_model.dart';
import 'models/progress_overview_model.dart';
import 'models/recent_act_model.dart';

class ProgressRepository {
  Future<ProgressOverviewModel> getOverview(int childId) async {
    final data = await supabase.rpc(
      'get_child_progress',
      params: {'p_child_id': childId},
    );
    if (data == null) return ProgressOverviewModel.empty();
    return ProgressOverviewModel.fromRpc(
      Map<String, dynamic>.from(data as Map),
    );
  }

  Future<List<RecentActivityModel>> getRecentActivity(
    int childId, {
    int limit = 5,
  }) async {
    final rows = await supabase.rpc(
      'get_child_recent_activity',
      params: {'p_child_id': childId, 'p_limit': limit},
    );

    return (rows as List).map((e) {
      final row = Map<String, dynamic>.from(e as Map);
      final hex = row['color_hex'] as String?;
      return RecentActivityModel(
        id: (row['id'] as num).toInt(),
        // The overview doesn't need a subject id here; the tile only renders
        // the name + color, so 0 is a harmless placeholder.
        subjectId: 0,
        subjectTitle: row['subject_name'] as String? ?? 'Unknown',
        subjectColor: hex != null ? hexToColor(hex) : const Color(0xFF6B7280),
        type: ActivityType.quiz,
        title: row['quiz_title'] as String? ?? '',
        starsAwarded: (row['stars_awarded'] as num?)?.toInt() ?? 0,
        timestamp: DateTime.parse(row['attempted_at'] as String),
      );
    }).toList();
  }

  Future<List<ChapterProgressModel>> getSubjectChapters(
    int childId,
    int standardSubjectId,
  ) async {
    final rows = await supabase.rpc(
      'get_child_subject_chapters',
      params: {
        'p_child_id': childId,
        'p_standard_subject_id': standardSubjectId,
      },
    );

    return (rows as List)
        .map(
          (e) =>
              ChapterProgressModel.fromRpc(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }
}
