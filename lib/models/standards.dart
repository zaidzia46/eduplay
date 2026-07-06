class StandardModel {
  final int id;
  final String standard;

  StandardModel({required this.id, required this.standard});

  factory StandardModel.fromJson(Map<String, dynamic> json) {
    return StandardModel(id: json['id'], standard: json['standard']);
  }
}
