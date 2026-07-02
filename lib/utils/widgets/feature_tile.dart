import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class FeatureTile extends StatelessWidget {
  final Image image;
  final String title;
  final String subtitle;

  const FeatureTile({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 44, height: 44, child: Center(child: image)),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.label),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
