import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import 'clouds_layer.dart';
import 'stars_layer.dart';

class AnimatedBackground extends StatelessWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.textPrimary,
                AppColors.primary,
                AppColors.textPrimary,
              ],
            ),
          ),
        ),

        const StarsLayer(),

        const CloudsLayer(),
        child,
      ],
    );
  }
}
