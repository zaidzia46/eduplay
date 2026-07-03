import 'package:eduplay/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../theme/app_text_styles.dart';

class StreakCard extends StatelessWidget {
  final int num;
  final Image image;

  const StreakCard({super.key, required this.num, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 40,
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          image,
          SizedBox(height: 2),
          Text(
            num.toString(),
            style: AppTextStyles.bodySecondary.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
