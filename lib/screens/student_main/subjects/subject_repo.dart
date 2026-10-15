import '../../../core/supabase_client.dart';
import 'subjects_model.dart';

class SubjectRepository {
  Future<List<SubjectModel>> getSubjects({
    required int curriculumId,
    required int standardId,
  }) async {
    final rows = await supabase
        .from('standard_subjects')
        .select('id, subjects(id, name, icon_path, color_hex)')
        .eq('curriculum_id', curriculumId)
        .eq('standard_id', standardId);

    return (rows as List)
        .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
