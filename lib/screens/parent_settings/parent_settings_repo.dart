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

    return path;
  }

  Future<String> getAvatarSignedUrl(String storagePath) async {
    return supabase.storage
        .from('avatars')
        .createSignedUrl(
          storagePath,
          60 * 60, // 1 hour
        );
  }
}
