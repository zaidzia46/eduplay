/// A single classified ad shown on the public App Dashboard.
///
/// Rows come from the `classified_ads` table (public, read-only). The image URL
/// is resolved by `ClassifiedAdsRepository` from [imagePath] — either an object
/// key in the `classified-ads` Storage bucket or a full external URL.
class ClassifiedAdModel {
  final int id;
  final String title;
  final String? description;

  /// Ad category used for the badge + accent, e.g. 'sponsored', 'featured'.
  final String adType;

  /// Reserved tap destination for when the ad's inside content is defined.
  final String? linkUrl;

  /// Raw value stored in the DB: a bucket object key or a full URL.
  final String? imagePath;

  /// Ready-to-load public image URL, filled in by the repository. Null when the
  /// ad has no image or the reference is blank.
  final String? imageUrl;

  const ClassifiedAdModel({
    required this.id,
    required this.title,
    this.description,
    required this.adType,
    this.linkUrl,
    this.imagePath,
    this.imageUrl,
  });

  factory ClassifiedAdModel.fromJson(
    Map<String, dynamic> json, {
    String? imageUrl,
  }) {
    final rawType = (json['ad_type'] as String?)?.trim();
    final rawDescription = (json['description'] as String?)?.trim();

    return ClassifiedAdModel(
      id: json['id'] as int,
      title: (json['title'] as String?)?.trim() ?? '',
      description: (rawDescription == null || rawDescription.isEmpty)
          ? null
          : rawDescription,
      adType: (rawType == null || rawType.isEmpty) ? 'sponsored' : rawType,
      linkUrl: json['link_url'] as String?,
      imagePath: json['image_path'] as String?,
      imageUrl: imageUrl,
    );
  }
}
