import '../../../../../core/supabase_client.dart';
import 'quiz_model.dart';

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
}
