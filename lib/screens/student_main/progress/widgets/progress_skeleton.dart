import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../../theme/app_colors.dart';

/// Skeletons for the Progress tab's *fetched* sections only — the overall
/// ring, the activity-breakdown card, the subjects list, and recent activity.
/// The page chrome and the Stars / Day Streak tiles render for real underneath
/// these while data loads, since those come straight from the cached active
/// child and have nothing to wait on.

const Color _fill = Color(0xFFE4E7EC);

Widget _bar({required double width, required double height, double radius = 6}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: _fill,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// Placeholder for the overall-progress ring + its centered label. Only the
/// ring is skeletonized; the Stars / Day Streak tiles below it render for real.
class ProgressRingSkeleton extends StatelessWidget {
  const ProgressRingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(color: _fill, shape: BoxShape.circle),
          ),
          const SizedBox(height: 12),
          _bar(width: 70, height: 12),
        ],
      ),
    );
  }
}

/// Placeholder mirroring the white [ActivityBreakdownCard] — three rings in a
/// row inside the same card chrome, so the swap-in is seamless.
class ActivityBreakdownSkeleton extends StatelessWidget {
  const ActivityBreakdownSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Shimmer(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (_) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: _fill,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 10),
                _bar(width: 50, height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder list for the Subjects section — white bordered tiles matching
/// [SubjectProgressTile], content greyed out.
class SubjectListSkeleton extends StatelessWidget {
  final int count;
  const SubjectListSkeleton({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      color: Colors.white,
      child: Column(
        children: List.generate(count, (_) => const _TileSkeleton(withBar: true)),
      ),
    );
  }
}

/// Placeholder list for Recent Activity — same tile chrome, trailing stars/time
/// stub instead of a progress bar.
class RecentActivityListSkeleton extends StatelessWidget {
  final int count;
  const RecentActivityListSkeleton({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      color: Colors.white,
      child: Column(
        children: List.generate(count, (_) => const _TileSkeleton(withBar: false)),
      ),
    );
  }
}

class _TileSkeleton extends StatelessWidget {
  final bool withBar;
  const _TileSkeleton({required this.withBar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _fill,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(width: 120, height: 14),
                const SizedBox(height: 8),
                if (withBar)
                  _bar(width: double.infinity, height: 6, radius: 10)
                else
                  _bar(width: 160, height: 10),
                const SizedBox(height: 6),
                _bar(width: 70, height: 10),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _bar(width: 34, height: 16),
        ],
      ),
    );
  }
}
