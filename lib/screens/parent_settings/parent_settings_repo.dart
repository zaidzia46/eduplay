import 'dart:developer';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_client.dart';

class ParentRepository {
  Future<String> uploadAvatar(String localFilePath) async {
    final parentId = supabase.auth.currentUser!.id;
    final path = '$parentId/parent.png';

    await supabase.storage
        .from('avatars')
        .upload(
          path,
          File(localFilePath),
          fileOptions: const FileOptions(upsert: true),
        );

    await supabase
        .from('parents')
        .update({'avatar_path': path})
        .eq('id', parentId);

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

  static void clearCache() => _avatarUrlCache.clear();

  Future<String?> _refreshAvatarSignedUrl(String storagePath) async {
    final url = await supabase.storage
        .from('avatars')
        .createSignedUrl(
          storagePath,
          60 * 60, // 1 hour
        );

    _avatarUrlCache[storagePath] = _CachedSignedUrl(
      url: url,
      expiresAt: DateTime.now().add(const Duration(minutes: 50)),
    );

    return url;
  }
}

class _CachedSignedUrl {
  final String url;
  final DateTime expiresAt;
  _CachedSignedUrl({required this.url, required this.expiresAt});
}
