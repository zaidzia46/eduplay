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

  /// `quiz-content` is a public bucket — no signed URL needed, unlike
  /// avatars. Synchronous and never expires.
  ///
  /// Some seed rows store the value with the bucket name baked in
  /// (e.g. "quiz-content/math/dog.png"), while the app's convention elsewhere
  /// is a bucket-relative key ("math/dog.png"). `getPublicUrl` already
  /// prefixes the bucket, so a raw value would produce a doubled
  /// "quiz-content/quiz-content/..." key that 404s. Strip any leading slash
  /// and leading bucket segment so both forms resolve correctly.
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
    final row = await supabase
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
    return row['stars_awarded'] as int?;
  }
}
