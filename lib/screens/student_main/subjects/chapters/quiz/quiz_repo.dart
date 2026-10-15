import '../../../../../core/supabase_client.dart';
import 'models/question_model.dart';

class QuizRepository {
  static const String _bucket = 'quiz-content';

  Future<List<QuestionModel>> getQuestionPool(int quizId) async {
    final rows = await supabase
        .from('questions')
        .select()
        .eq('quiz_id', quizId);
    return (rows as List)
        .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String getPublicImageUrl(String storagePath) {
    var path = storagePath.trim();
    if (path.startsWith('/')) path = path.substring(1);
    if (path.startsWith('$_bucket/')) {
      path = path.substring(_bucket.length + 1);
    }
    return supabase.storage.from(_bucket).getPublicUrl(path);
  }

  Future<int?> submitAttempt({
    required int childId,
    required int quizId,
    required int correctCount,
    required int totalQuestions,
    required int timeSpentSeconds,
  }) async {
    final inserted = await supabase
        .from('quiz_attempts')
        .insert({
          'child_id': childId,
          'quiz_id': quizId,
          'correct_count': correctCount,
          'total_questions': totalQuestions,
          'time_spent_seconds': timeSpentSeconds,
        })
        .select()
        .single();

    final row = await supabase
        .from('quiz_attempts')
        .select('stars_awarded')
        .eq('id', inserted['id'])
        .single();

    return row['stars_awarded'] as int?;
  }
}
