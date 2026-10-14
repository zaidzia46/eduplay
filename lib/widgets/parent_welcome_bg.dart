import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class WelcomeBackgroundContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;

  const WelcomeBackgroundContainer({
    super.key,
    required this.child,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          borderRadius ??
          BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary,
              AppColors.primaryDark,
              AppColors.primary,
            ],
            stops: [0.0, 0.4, 0.78, 1.0],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(top: -70, left: -60, child: _deco(200, 0.10)),
            Positioned(right: -20, bottom: -80, child: _deco(120, 0.10)),
            Positioned(right: -80, bottom: -10, child: _deco(141, 0.10)),
            child,
          ],
        ),
      ),
    );
  }

  Widget _deco(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(opacity),
    ),
  );

  static Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
