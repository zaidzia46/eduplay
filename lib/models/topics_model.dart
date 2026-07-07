class TopicModel {
  final int id;
  final String topic;
  final int progressPercent;

  TopicModel({
    required this.id,
    required this.topic,
    required this.progressPercent,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'],
      topic: json['topic'],
      progressPercent: json['progress_percent'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['id'] = id;
    data['topic'] = topic;
    data['progress_percent'] = progressPercent;

    return data;
  }
}
