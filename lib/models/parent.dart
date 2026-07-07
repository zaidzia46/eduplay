class ParentModel {
  final int id;
  final String name;
  final String email;

  ParentModel({required this.id, required this.name, required this.email});

  factory ParentModel.fromJson(Map<String, dynamic> json) {
    return ParentModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
