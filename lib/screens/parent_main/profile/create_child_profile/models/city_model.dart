class CityModel {
  final int id;
  final String name;

  CityModel({required this.id, required this.name});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(id: json['id'] as int, name: json['name'] as String);
  }

  @override
  bool operator ==(Object other) => other is CityModel && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
