import '../../../../core/supabase_client.dart';
import '../models/city_model.dart';
import '../models/curriculam_option_model.dart';
import '../models/institution_model.dart';
import '../models/standard_model.dart';

class CatalogRepository {
  Future<List<CityModel>> getCities() async {
    final rows = await supabase.from('cities').select().order('name');
    return (rows as List)
        .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<InstitutionModel>> getInstitutesByCity(int cityId) async {
    final rows = await supabase
        .from('institutes')
        .select()
        .eq('city_id', cityId)
        .order('name');
    return (rows as List)
        .map((e) => InstitutionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CurriculumOptionModel>> getCurriculaByInstitute(
    int instituteId,
  ) async {
    // Embedded select: pulls the linked curriculum's name in the same query
    // via the foreign key institute_curricula.curriculum_id -> curricula.id.
    final rows = await supabase
        .from('institute_curricula')
        .select('id, curriculum_id, curricula(name)')
        .eq('institute_id', instituteId);
    return (rows as List)
        .map((e) => CurriculumOptionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<StandardModel>> getStandardsByInstituteCurricula(
    int instituteCurriculaId,
  ) async {
    final rows = await supabase
        .from('institute_curricula_standard')
        .select('standards(id, name, sort_order)')
        .eq('institute_curricula_id', instituteCurriculaId);

    final standards = (rows as List)
        .map(
          (e) => StandardModel.fromJson(
            (e as Map<String, dynamic>)['standards'] as Map<String, dynamic>,
          ),
        )
        .toList();

    standards.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return standards;
  }
}
