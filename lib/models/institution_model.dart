class InstitutionModel {
  final int id;
  final String name;
  final String? city;

  InstitutionModel({required this.id, required this.name, this.city});

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      id: json['id'],
      name: json['name'],
      city: json['city'],
    );
  }
}
