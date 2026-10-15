class InstitutionModel {
  final int id;
  final String name;

  InstitutionModel({required this.id, required this.name});

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  @override
  bool operator ==(Object other) => other is InstitutionModel && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
