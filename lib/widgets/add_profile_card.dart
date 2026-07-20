import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AddProfileCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddProfileCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17.0, horizontal: 15.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage('assets/images/profile_sec_null_bg.png'),
            fit: BoxFit.cover,
          ),
          border: Border.all(
            color: AppColors.white,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: const Icon(Icons.add, size: 32, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              'Add Child',
              style: AppTextStyles.h4.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
