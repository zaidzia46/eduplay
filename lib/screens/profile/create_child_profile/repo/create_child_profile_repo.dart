import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase_client.dart';
import '../../profile_switcher/models/child_profile_model.dart';

class ChildProfileRepository {
  Future<List<ChildProfileModel>> getChildren() async {
    final rows = await supabase
        .from('children')
        .select('''
          id, name, username, avatar_path,
          total_stars, current_streak, longest_streak,
          child_standard_enrollment(
            is_current,
            curriculum_id,
            institutes(id, name),
            standards(id, name, sort_order)
          )
        ''')
        .order('created_at');
    return (rows as List)
        .map((e) => ChildProfileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> createChild({
    required String name,
    required String username,
    required int instituteId,
    required int curriculumId,
    required int standardId,
  }) async {
    final parentId = supabase.auth.currentUser!.id;

    final childRow = await supabase
        .from('children')
        .insert({'parent_id': parentId, 'name': name, 'username': username})
        .select()
        .single();

    final childId = childRow['id'] as int;

    await supabase.from('child_standard_enrollment').insert({
      'child_id': childId,
      'institute_id': instituteId,
      'curriculum_id': curriculumId,
      'standard_id': standardId,
      'is_current': true,
    });

    return childId;
  }

  Future<String> uploadAvatar(int childId, String localFilePath) async {
    final parentId = supabase.auth.currentUser!.id;
    final path = '$parentId/children/$childId.png';

    await supabase.storage
        .from('avatars')
        .upload(
          path,
          File(localFilePath),
          fileOptions: const FileOptions(upsert: true),
        );

    await supabase
        .from('children')
        .update({'avatar_path': path})
        .eq('id', childId);

    await _refreshAvatarSignedUrl(path);

    return path;
  }

  static final Map<String, _CachedSignedUrl> _avatarUrlCache = {};

  Future<String?> getAvatarSignedUrl(String storagePath) async {
    final cached = _avatarUrlCache[storagePath];
    if (cached != null && DateTime.now().isBefore(cached.expiresAt)) {
      return cached.url;
    }

    return _refreshAvatarSignedUrl(storagePath);
  }

  Future<String?> _refreshAvatarSignedUrl(String storagePath) async {
    final url = await supabase.storage
        .from('avatars')
        .createSignedUrl(
          storagePath,
          60 * 60, // 1 hour
        );

    final versionedUrl = Uri.parse(url)
        .replace(fragment: 'v=${DateTime.now().millisecondsSinceEpoch}')
        .toString();

    _avatarUrlCache[storagePath] = _CachedSignedUrl(
      url: versionedUrl,
      expiresAt: DateTime.now().add(const Duration(minutes: 50)),
    );

    return versionedUrl;
  }
}

class _CachedSignedUrl {
  final String url;
  final DateTime expiresAt;
  _CachedSignedUrl({required this.url, required this.expiresAt});
}
