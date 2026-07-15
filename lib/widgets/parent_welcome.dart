import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ParentWelcomeCard extends StatelessWidget {
  final String? parent;

  const ParentWelcomeCard({super.key, required this.parent});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -25),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/profile_sec_bg.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF9FAFB)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 30,
              offset: const Offset(0, 12),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: AppTextStyles.bodySecondary.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              parent!.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
