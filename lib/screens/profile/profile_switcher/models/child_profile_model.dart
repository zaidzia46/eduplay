import '../../create_child_profile/models/institution_model.dart';
import '../../create_child_profile/models/standard_model.dart';

class ChildProfileModel {
  final int id;
  final String name;
  final String username;
  final String? avatar; // storage PATH, not a URL — see note in repo
  final int totalStars;
  final int currentStreak;
  final int longestStreak;

  // Nullable now: a child could theoretically have no current enrollment
  // row (e.g. it failed to insert after the child was created — see the
  // note in ChildProfileRepository.createChild). Handle null in the UI
  // rather than assuming it's always present.
  final StandardModel? standard;
  final InstitutionModel? institution;
  final int? curriculumId;

  final int overallPercent;

  ChildProfileModel({
    required this.id,
    required this.name,
    required this.username,
    this.avatar,
    this.totalStars = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.standard,
    this.institution,
    this.curriculumId,
    this.overallPercent = 0,
  });

  factory ChildProfileModel.fromJson(Map<String, dynamic> json) {
    final enrollments =
        (json['child_standard_enrollment'] as List<dynamic>?) ?? [];
    Map<String, dynamic>? current;
    for (final e in enrollments) {
      final row = e as Map<String, dynamic>;
      if (row['is_current'] == true) {
        current = row;
        break;
      }
    }

    return ChildProfileModel(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      avatar: json['avatar_path'] as String?,
      totalStars: json['total_stars'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      standard: current?['standards'] != null
          ? StandardModel.fromJson(
              current!['standards'] as Map<String, dynamic>,
            )
          : null,
      institution: current?['institutes'] != null
          ? InstitutionModel.fromJson(
              current!['institutes'] as Map<String, dynamic>,
            )
          : null,
      curriculumId: current?['curriculum_id'] as int?,
    );
  }

  ChildProfileModel copyWith({
    String? name,
    String? username,
    StandardModel? standard,
    InstitutionModel? institution,
    String? avatarPath,
    int? curriculumId,
  }) {
    return ChildProfileModel(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatar: avatarPath ?? avatar,
      totalStars: totalStars,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      standard: standard ?? this.standard,
      institution: institution ?? this.institution,
      curriculumId: curriculumId ?? this.curriculumId,
      overallPercent: overallPercent,
    );
  }

  // overallPercent still comes from the switcher controller until
  // child_progress_summary exists — same role as before.
  ChildProfileModel copyWithProgress({required int overallPercent}) {
    return ChildProfileModel(
      id: id,
      name: name,
      username: username,
      avatar: avatar,
      totalStars: totalStars,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      standard: standard,
      institution: institution,
      curriculumId: curriculumId,
      overallPercent: overallPercent,
    );
  }

  Map<String, dynamic> toCacheJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'avatar': avatar,
      'total_stars': totalStars,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'overall_percent': overallPercent,
      'standard': standard == null
          ? null
          : {
              'id': standard!.id,
              'name': standard!.name,
              'sort_order': standard!.sortOrder,
            },
      'institution': institution == null
          ? null
          : {'id': institution!.id, 'name': institution!.name},
      'curriculum_id': curriculumId,
    };
  }

  factory ChildProfileModel.fromCacheJson(Map<String, dynamic> json) {
    return ChildProfileModel(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String?,
      totalStars: json['total_stars'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      overallPercent: json['overall_percent'] as int? ?? 0,
      standard: json['standard'] != null
          ? StandardModel.fromJson(json['standard'] as Map<String, dynamic>)
          : null,
      institution: json['institution'] != null
          ? InstitutionModel.fromJson(
              json['institution'] as Map<String, dynamic>,
            )
          : null,
      curriculumId: json['curriculum_id'] as int?,
    );
  }
}
