import '../models/standards_model.dart';
import '../models/institution_model.dart';

class ChildProfileModel {
  final int id;
  final String name;
  final String username;
  final StandardModel standard;
  final InstitutionModel institution;
  final String? avatar;

  // Derived — NOT part of child_profiles.json. Populated by
  // ProfileSwitcherViewModel after calling
  // SubjectRepository.getOverallPercent(childId: id) for each child,
  // same pattern used for SubjectsModel/TopicModel. Defaults to 0 until
  // that fetch completes.
  final int overallPercent;

  ChildProfileModel({
    required this.id,
    required this.name,
    required this.username,
    required this.standard,
    required this.institution,
    this.avatar,
    this.overallPercent = 0,
  });

  factory ChildProfileModel.fromJson(Map<String, dynamic> json) {
    return ChildProfileModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      standard: StandardModel.fromJson(json['standard']),
      institution: InstitutionModel.fromJson(json['institution']),
      avatar: json['avatar_url'],
    );
  }

  // Used when a profile is edited locally (e.g. change standard) before
  // the update reaches the backend.
  ChildProfileModel copyWith({
    String? name,
    String? username,
    StandardModel? standard,
    InstitutionModel? institution,
    String? avatarUrl,
  }) {
    return ChildProfileModel(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      standard: standard ?? this.standard,
      institution: institution ?? this.institution,
      avatar: avatarUrl ?? this.avatar,
      overallPercent: overallPercent,
    );
  }

  // Returns a copy with derived progress merged in, used by
  // ProfileSwitcherViewModel once it has fetched this child's overall
  // percent.
  ChildProfileModel copyWithProgress({required int overallPercent}) {
    return ChildProfileModel(
      id: id,
      name: name,
      username: username,
      standard: standard,
      institution: institution,
      avatar: avatar,
      overallPercent: overallPercent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'avatar_url': avatar,
      'standard': {'id': standard.id, 'standard': standard.standard},
      'institution': {
        'id': institution.id,
        'name': institution.name,
        'city': institution.city,
      },
    };
  }
}
