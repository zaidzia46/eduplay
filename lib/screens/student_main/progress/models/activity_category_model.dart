class ActivityCategoryModel {
  final String label;
  final int completed;
  final int total;

  ActivityCategoryModel({
    required this.label,
    required this.completed,
    required this.total,
  });

  factory ActivityCategoryModel.fromJson(Map<String, dynamic> json) {
    return ActivityCategoryModel(
      label: json['label'],
      completed: json['completed'],
      total: json['total'],
    );
  }

  double get ratio => total == 0 ? 0 : completed / total;
}
