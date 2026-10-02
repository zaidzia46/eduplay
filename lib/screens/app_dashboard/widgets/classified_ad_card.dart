import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../models/classified_ad_model.dart';

class ClassifiedAdCard extends StatelessWidget {
  final ClassifiedAdModel ad;

  const ClassifiedAdCard({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(ad.adType);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10, // same image area on every card
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImage(accent),
                Positioned(
                  top: 8,
                  left: 8,
                  child: _TypeBadge(
                    label: _prettyType(ad.adType),
                    dotColor: accent,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      ad.description ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(Color accent) {
    final url = ad.imageUrl;
    if (url == null) return _imageFallback(accent);

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: accent.withOpacity(0.10)),
      errorWidget: (_, __, ___) => _imageFallback(accent),
    );
  }

  Widget _imageFallback(Color accent) {
    return Container(
      color: accent.withOpacity(0.12),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        color: accent.withOpacity(0.6),
        size: 34,
      ),
    );
  }

  // Known ad types get a themed accent; unknown types fall back to the brand.
  Color _accentFor(String type) {
    switch (type.toLowerCase()) {
      case 'featured':
        return AppColors.star;
      case 'sponsored':
        return AppColors.primary;
      case 'promoted':
        return AppColors.science;
      case 'announcement':
        return AppColors.maths;
      default:
        return AppColors.primary;
    }
  }

  String _prettyType(String type) {
    if (type.isEmpty) return 'Ad';
    return type[0].toUpperCase() + type.substring(1).toLowerCase();
  }
}

/// A dark, always-legible pill carrying the ad type, with a small accent dot so
/// the type's color reads on top of any image.
class _TypeBadge extends StatelessWidget {
  final String label;
  final Color dotColor;

  const _TypeBadge({required this.label, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

/// Placeholder card shown in the grid while ads are loading.
class ClassifiedAdCardSkeleton extends StatelessWidget {
  const ClassifiedAdCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Container(color: AppColors.border.withOpacity(0.45)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(width: double.infinity, height: 12),
                  const SizedBox(height: 8),
                  _bar(width: 120, height: 10),
                  const SizedBox(height: 6),
                  _bar(width: 80, height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar({required double width, required double height}) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.border.withOpacity(0.55),
      borderRadius: BorderRadius.circular(6),
    ),
  );
}
