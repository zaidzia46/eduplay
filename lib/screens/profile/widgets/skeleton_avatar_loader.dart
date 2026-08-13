import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../theme/app_colors.dart';

class SkeletonAvatarLoader extends StatelessWidget {
  final double avatarSize;
  const SkeletonAvatarLoader({super.key, required this.avatarSize});
  @override
  Widget build(BuildContext context) {
    return Shimmer(
      color: Colors.grey.shade700,
      child: Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
