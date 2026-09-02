import '../../../../../core/supabase_client.dart';
import 'quiz_model.dart';

/// Per-quiz progress for one child, keyed by quiz id.
typedef QuizProgress = ({int bestPercent, bool isPassed, bool attempted});

class QuizListRepository {
  /// Every quiz that belongs to this chapter — one row per "topic" the
  /// child can play. Ordered by id since quizzes have no sort_order column.
  Future<List<QuizModel>> getQuizzes({required int chapterId}) async {
    final rows = await supabase
        .from('quizzes')
        .select()
        .eq('chapter_id', chapterId)
        .order('id');

    return (rows as List)
        .map((e) => QuizModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Best score / pass state per quiz for this child in this chapter, computed
  /// server-side (docs/progress-rpcs.sql → get_chapter_quiz_progress). Returned
  /// as a map so the controller can merge it onto the quiz list.
  Future<Map<int, QuizProgress>> getQuizProgress({
    required int childId,
    required int chapterId,
  }) async {
    final rows = await supabase.rpc(
      'get_chapter_quiz_progress',
      params: {'p_child_id': childId, 'p_chapter_id': chapterId},
    );

    final result = <int, QuizProgress>{};
    for (final e in (rows as List)) {
      final row = Map<String, dynamic>.from(e as Map);
      result[(row['quiz_id'] as num).toInt()] = (
        bestPercent: (row['best_percent'] as num?)?.toInt() ?? 0,
        isPassed: row['is_passed'] as bool? ?? false,
        attempted: row['attempted'] as bool? ?? false,
      );
    }
    return result;
  }
}
