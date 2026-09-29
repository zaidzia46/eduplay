import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduplay/screens/parent_settings/parent_settings_controller.dart';
import 'package:eduplay/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../widgets/expanded_avatar.dart';
import 'skeleton_avatar_loader.dart';
import '../../../theme/app_colors.dart';

class WelcomeBackground extends StatelessWidget {
  final String welcomeText;
  final String userName;
  final String subtitleText;

  const WelcomeBackground({
    super.key,
    required this.welcomeText,
    required this.userName,
    required this.subtitleText,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4B1F8C),
              Color(0xFF7A35C9),
              Color(0xFFE7A23D),
              Color(0xFFF6C544),
            ],
            stops: [0.0, 0.4, 0.78, 1.0],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: -70,
              bottom: -80,
              child: _blurCircle(
                200,
                const Color(0xFF3B1770).withOpacity(0.45),
              ),
            ),
            Positioned(
              left: -10,
              bottom: -100,
              child: _blurCircle(
                170,
                const Color(0xFF3B1770).withOpacity(0.35),
              ),
            ),
            Positioned(
              right: -50,
              bottom: -90,
              child: _blurCircle(
                220,
                const Color(0xFFF8D77A).withOpacity(0.25),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          welcomeText,
                          style: AppTextStyles.bodySecondary.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          userName,
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 90,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6C544),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitleText,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildAvatar() {
    final vm = Get.find<ParentSettingsController>();
    double avatarSize = 65;

    return Obx(() {
      final localPath = vm.localPreviewPath.value;
      final url = vm.profileImagePath.value;
      final isLoading = vm.isLoadingAvatar.value;

      Widget avatarContent;

      if (localPath != null) {
        avatarContent = ExpandableAvatar(
          avatarSize: avatarSize,
          localPreviewPath: localPath,
          collapsedChild: CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: AppColors.primaryDark,
            backgroundImage: FileImage(File(localPath)),
          ),
        );
      } else if (isLoading) {
        avatarContent = SkeletonAvatarLoader(avatarSize: avatarSize);
      } else if (url != null) {
        avatarContent = ExpandableAvatar(
          imageUrl: url,
          avatarSize: avatarSize,
          collapsedChild: ClipOval(
            child: CachedNetworkImage(
              imageUrl: url,
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  SkeletonAvatarLoader(avatarSize: avatarSize),
              errorWidget: (context, url, error) => CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: AppColors.primaryDark,
                child: Icon(Icons.person, size: avatarSize * 0.5),
              ),
            ),
          ),
        );
      } else {
        avatarContent = CircleAvatar(
          radius: avatarSize / 2,
          backgroundColor: AppColors.primaryDark,
          child: Icon(Icons.person, size: avatarSize * 0.5),
        );
      }

      return Stack(
        clipBehavior: Clip.none,
        children: [
          avatarContent,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF6C544),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.crown,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
