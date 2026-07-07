enum TopicStatus { notStarted, inProgress, completed }

class TopicModel {
  final int id;
  final String topic;
  final int order;

  // Progress fields, specific to the current student.
  // Populated by TopicRepository after merging in topic_progress data,
  // not read directly off the catalog JSON. Default to "not started"
  // when no progress row exists for this topic yet.
  final TopicStatus status;
  final int progressPercent;

  TopicModel({
    required this.id,
    required this.topic,
    required this.order,
    this.status = TopicStatus.notStarted,
    this.progressPercent = 0,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'],
      topic: json['topic'],
      order: json['order'],
    );
  }

  // Returns a copy with progress data merged in, used by the repository
  // once it has joined the catalog entry with this student's progress row
  // (or lack thereof).
  TopicModel copyWithProgress({
    required TopicStatus status,
    required int progressPercent,
  }) {
    return TopicModel(
      id: id,
      topic: topic,
      order: order,
      status: status,
      progressPercent: progressPercent,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'topic': topic, 'order': order};
  }
}
