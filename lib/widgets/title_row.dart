import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TitleRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const TitleRow({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 8),

                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View all',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
          ],
        ),
      ],
    );
  }
}
