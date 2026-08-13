class CurriculumOptionModel {
  final int instituteCurriculaId;
  final int curriculumId;
  final String name;

  CurriculumOptionModel({
    required this.instituteCurriculaId,
    required this.curriculumId,
    required this.name,
  });

  factory CurriculumOptionModel.fromJson(Map<String, dynamic> json) {
    return CurriculumOptionModel(
      instituteCurriculaId: json['id'] as int,
      curriculumId: json['curriculum_id'] as int,
      name: (json['curricula'] as Map<String, dynamic>)['name'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CurriculumOptionModel &&
      other.instituteCurriculaId == instituteCurriculaId;
  @override
  int get hashCode => instituteCurriculaId.hashCode;
}
