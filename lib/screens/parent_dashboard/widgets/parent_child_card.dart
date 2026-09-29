import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/stat_chip.dart';
import '../../profile/profile_switcher/models/child_profile_model.dart';
import '../../profile/widgets/skeleton_avatar_loader.dart';

class ParentChildCard extends StatelessWidget {
  final ChildProfileModel child;
  final int stars;
  final int streak;
  final String? avatarUrl;
  final VoidCallback onContinue;
  final VoidCallback onViewProgress;

  const ParentChildCard({
    super.key,
    required this.child,
    required this.stars,
    required this.streak,
    required this.avatarUrl,
    required this.onContinue,
    required this.onViewProgress,
  });

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 52;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatar(avatarSize),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  child.standard?.name ?? 'Not enrolled yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    StatChip.stars(value: '$stars'),
                    const SizedBox(width: 8),
                    StatChip.streak(value: '$streak'),
                  ],
                ),
                const SizedBox(height: 8),
                _buildProgress(),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Right side: icon actions
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconAction(
                icon: Icons.arrow_forward_rounded,
                tooltip: 'Continue Learning',
                filled: true,
                onTap: onContinue,
              ),
              const SizedBox(height: 8),
              _IconAction(
                icon: Icons.insights_rounded,
                tooltip: 'View Progress',
                filled: false,
                onTap: onViewProgress,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: child.overallPercent / 100,
              minHeight: 6,
              backgroundColor: AppColors.primarySurface,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${child.overallPercent}%',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(double avatarSize) {
    return ClipOval(
      child: avatarUrl != null
          ? CachedNetworkImage(
              imageUrl: avatarUrl!,
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  SkeletonAvatarLoader(avatarSize: avatarSize),
              errorWidget: (context, url, error) => _avatarFallback(avatarSize),
            )
          : _avatarFallback(avatarSize),
    );
  }

  Widget _avatarFallback(double avatarSize) {
    return Container(
      width: avatarSize,
      height: avatarSize,
      color: const Color(0xffFFD84E),
      child: Icon(Icons.person, size: avatarSize * 0.5),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool filled;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.white : AppColors.primary;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled ? AppColors.primary : AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 38,
            child: Icon(icon, size: 20, color: fg),
          ),
        ),
      ),
    );
  }
}
