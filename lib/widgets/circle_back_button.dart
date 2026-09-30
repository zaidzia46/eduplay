import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A circular, elevated back button pinned to the top-left of full-screen
/// surfaces (Parent Dashboard, standalone Progress). Purely presentational —
/// the caller supplies the tap behaviour (usually `Get.back()`).
class CircleBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const CircleBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withOpacity(0.6),
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.30),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 18,
          ),
        ),
      ),
    );
  }
}
