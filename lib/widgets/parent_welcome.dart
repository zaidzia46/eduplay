import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ParentWelcomeCard extends StatelessWidget {
  final String? parent;

  const ParentWelcomeCard({super.key, required this.parent});

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 62;
    return Transform.translate(
      offset: const Offset(0, -25),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: AssetImage('assets/images/profile_sec_bg.png'),
            fit: BoxFit.cover,
          ),
          border: Border(
            bottom: BorderSide(color: AppColors.primary, width: 5),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: avatarSize / 2,
              backgroundColor: const Color(0xffFFD84E),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/pak_mom2.png',
                  fit: BoxFit.cover,
                  width: avatarSize,
                  height: avatarSize,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person,
                    size: 45,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Back!",
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    parent!.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Image.asset("assets/images/purple_planet.png", height: 70),
          ],
        ),
      ),
    );
  }
}
