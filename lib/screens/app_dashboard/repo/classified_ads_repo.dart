import '../../../core/supabase_client.dart';
import '../models/classified_ad_model.dart';

class ClassifiedAdsRepository {
  static const String _bucket = 'classified-ads';

  /// Fetches the currently-visible ads. RLS already filters out inactive /
  /// out-of-window rows, so whatever comes back is safe to show — even for
  /// logged-out (anon) visitors. Ordered by `sort_order`, then newest first.
  Future<List<ClassifiedAdModel>> getActiveAds() async {
    final rows = await supabase
        .from('classified_ads')
        .select('id, title, description, image_path, ad_type, link_url')
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);

    return (rows as List).map((e) {
      final map = e as Map<String, dynamic>;
      return ClassifiedAdModel.fromJson(
        map,
        imageUrl: _resolveImageUrl(map['image_path'] as String?),
      );
    }).toList();
  }

  String? _resolveImageUrl(String? storagePath) {
    var path = storagePath?.trim() ?? '';
    if (path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('/')) path = path.substring(1);
    if (path.startsWith('$_bucket/')) {
      path = path.substring(_bucket.length + 1);
    }
    return supabase.storage.from(_bucket).getPublicUrl(path);
  }
}
