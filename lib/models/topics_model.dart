class TopicModel {
  final int id;
  final String topic;
  final int progressPercent;
  final String? imageUrl;

  TopicModel({
    required this.id,
    required this.topic,
    required this.progressPercent,
    this.imageUrl,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'],
      topic: json['topic'],
      progressPercent: json['progress_percent'],
      imageUrl: json['image_url'],
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
