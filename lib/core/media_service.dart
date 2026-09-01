import 'supabase_client.dart';

/// Central place for resolving catalog media (lesson images, etc.) to public
/// URLs served from Supabase Storage.
///
/// Lesson media lives in a **public** bucket, so URLs are stable and
/// CDN/disk-cacheable (via `cached_network_image`) — no per-image signing.
/// The object key is exactly the relative path stored in the DB
/// (e.g. `content_blocks.data.url` = "grade1/math/math4.png"), so moving from
/// bundled assets to Storage required no data changes.
class MediaService {
  MediaService._();

  /// Bucket holding shared, read-only lesson content images.
  static const String lessonMediaBucket = 'lesson-media';

  /// Public URL for a lesson media object at [path] within [lessonMediaBucket].
  static String lessonMediaUrl(String path) =>
      supabase.storage.from(lessonMediaBucket).getPublicUrl(path);
}
