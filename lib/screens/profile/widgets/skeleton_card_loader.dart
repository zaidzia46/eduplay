import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ProfileCardSkeletonList extends StatelessWidget {
  const ProfileCardSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      color: Colors.grey.shade300,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: 4,
        itemBuilder: (context, index) => const ProfileCardSkeleton(),
      ),
    );
  }
}

class ProfileCardSkeleton extends StatelessWidget {
  const ProfileCardSkeleton();

  Widget _bone({double? width, required double height, double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 62;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bone(width: avatarSize, height: avatarSize, radius: avatarSize / 2),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stand-in for the star icon + child name row.
                _bone(width: 120, height: 16),
                const SizedBox(height: 8),
                // Stand-in for the standard/enrollment pill.
                _bone(width: 90, height: 20, radius: 30),
                const SizedBox(height: 8),
                // Stand-in for the institution row.
                _bone(width: 150, height: 14),
                const SizedBox(height: 8),
                // Stand-in for the progress bar.
                _bone(height: 6, radius: 10),
                const SizedBox(height: 8),
                // Stand-in for the stars/streak row.
                Row(
                  children: [
                    _bone(width: 24, height: 12),
                    const SizedBox(width: 12),
                    _bone(width: 70, height: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
