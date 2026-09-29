import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/stat_chip.dart';
import '../../profile/profile_switcher/models/child_profile_model.dart';
import '../../profile/widgets/skeleton_avatar_loader.dart';

/// A child row on the Parent Dashboard. Unlike [ProfileCard] (whose single tap
/// runs a ~1.1s ring animation before selecting), this card exposes two
/// explicit actions — Continue Learning and View Progress — so the parent picks
/// what to do with the child rather than just "enter".
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
    const double avatarSize = 58;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(avatarSize),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      child.standard?.name ?? 'Not enrolled yet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StatChip.stars(value: '$stars'),
                        const SizedBox(width: 8),
                        StatChip.streak(value: '$streak'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildProgress(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _ActionButton(
                  label: 'Continue Learning',
                  icon: Icons.play_arrow_rounded,
                  filled: true,
                  onTap: onContinue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _ActionButton(
                  label: 'Progress',
                  icon: Icons.insights_rounded,
                  filled: false,
                  onTap: onViewProgress,
                ),
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
              minHeight: 8,
              backgroundColor: AppColors.primarySurface,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
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

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.white : AppColors.primary;

    return Material(
      color: filled ? AppColors.primary : AppColors.primarySurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.buttonMedium.copyWith(color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
