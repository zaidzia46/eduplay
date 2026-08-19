import '../../../../core/supabase_client.dart';
import 'chapter_models.dart';

class ChapterRepository {
  Future<List<ChapterModel>> getTopics({required int standardSubjectId}) async {
    final rows = await supabase
        .from('chapters')
        .select()
        .eq('standard_subject_id', standardSubjectId)
        .order('sort_order');

    return (rows as List)
        .map((e) => ChapterModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
