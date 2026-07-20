import 'package:eduplay/screens/profile/profile_switcher/profile_switcher_controller.dart';
import 'package:flutter/material.dart';

import '../models/child_profile_model.dart';
import '../screens/parent_dashboard/parent_dashboard_main/parent_dashboard_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ProfileCard extends StatelessWidget {
  final ChildProfileModel child;
  final int stars;
  final int streak;
  final VoidCallback onTap;

  const ProfileCard({
    super.key,
    required this.child,
    required this.stars,
    required this.streak,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 62;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 2),
          image: const DecorationImage(
            image: AssetImage('assets/images/profile_sec_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(shape: BoxShape.rectangle),
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: const Color(0xffFFD84E),
                child: ClipOval(
                  child: child.avatar != null
                      ? Image.asset(
                          child.avatar!,
                          fit: BoxFit.cover,
                          width: avatarSize,
                          height: avatarSize,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,
                            size: 45,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 45,
                          color: AppColors.primary,
                        ),
                ),
              ),
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.star, size: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          child.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      child.standard.standard,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),

                  Row(
                    children: [
                      const Icon(
                        Icons.school,
                        size: 15,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          child.institution.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Overall progress — same number shown on the Progress screen.
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: child.overallPercent / 100,
                            minHeight: 6,
                            backgroundColor: Colors.white,
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
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.star,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$stars',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.local_fire_department,
                        color: AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak day streak',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
