class StandardModel {
  final int id;
  final String name;
  final int sortOrder;

  StandardModel({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  factory StandardModel.fromJson(Map<String, dynamic> json) {
    return StandardModel(
      id: json['id'] as int,
      name: json['name'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) => other is StandardModel && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
