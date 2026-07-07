import '../models/standards_model.dart';
import '../models/institution_model.dart';

class ChildProfileModel {
  final int id;
  final String name;
  final String username;
  final StandardModel standard;
  final InstitutionModel institution;
  final String? avatar;

  ChildProfileModel({
    required this.id,
    required this.name,
    required this.username,
    required this.standard,
    required this.institution,
    this.avatar,
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
    );
  }
}
