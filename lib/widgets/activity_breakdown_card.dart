import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../models/activity_category_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Activity breakdown shown as rounded "track + fill" bars — one bar per
/// category, filled up to `completed` out of `total`.
///
/// Built as a plain Flutter widget (no fl_chart) so the number label always
/// sits exactly on top of the fill, taps never trigger any resize/zoom
/// animation, and the fill only animates in once this card is actually
/// visible on screen (important because IndexedStack builds every tab up
/// front, so a plain "animate on build" approach would finish off-screen
/// before the user ever switches to this tab).
class ActivityBreakdownCard extends StatelessWidget {
  final List<ActivityCategoryModel> categories;
  ActivityBreakdownCard({super.key, required this.categories});

  // Which bar is currently pressed, for a same-size color highlight.
  final RxInt touchedIndex = (-1).obs;

  // Becomes true the first time this card is actually visible on screen.
  // Fill animation is gated on this instead of on build.
  final RxBool hasBecomeVisible = false.obs;

  static const double _barHeight = 180;
  static const double _barWidth = 18;
  static const Color _trackColor = Color(0xFFEDEAF5);

  static const List<Color> _palette = [
    Color(0xFF9C6ADE), // purple - brand
    Color(0xFFFF6B6B), // coral
    Color(0xFFFFB84C), // orange
    Color(0xFF4ECDC4), // teal
    Color(0xFFFFD93D), // yellow
    Color(0xFF6BCB77), // green
    Color(0xFFFF8FB1), // pink
  ];

  Color _colorFor(int index) => _palette[index % _palette.length];

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('activity-breakdown-card'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0 && !hasBecomeVisible.value) {
          hasBecomeVisible.value = true;
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity Breakdown', style: AppTextStyles.sectionHeader),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(categories.length, (i) {
                return _CategoryBar(
                  index: i,
                  category: categories[i],
                  color: _colorFor(i),
                  trackColor: _trackColor,
                  barHeight: _barHeight,
                  barWidth: _barWidth,
                  touchedIndex: touchedIndex,
                  hasBecomeVisible: hasBecomeVisible,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.index,
    required this.category,
    required this.color,
    required this.trackColor,
    required this.barHeight,
    required this.barWidth,
    required this.touchedIndex,
    required this.hasBecomeVisible,
  });

  final int index;
  final ActivityCategoryModel category;
  final Color color;
  final Color trackColor;
  final double barHeight;
  final double barWidth;
  final RxInt touchedIndex;
  final RxBool hasBecomeVisible;

  @override
  Widget build(BuildContext context) {
    final total = category.total <= 0 ? 1 : category.total;
    final fillFraction = (category.completed / total).clamp(0.0, 1.0);
    final fillHeight = barHeight * fillFraction;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => touchedIndex.value = index,
      onTapUp: (_) => touchedIndex.value = -1,
      onTapCancel: () => touchedIndex.value = -1,
      child: Obx(() {
        final isTouched = touchedIndex.value == index;
        final barColor = isTouched ? color.withValues(alpha: 0.75) : color;
        final targetHeight = hasBecomeVisible.value ? fillHeight : 0.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Number pinned right above the fill top: "15 / 20"
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${category.completed}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: ' / ${category.total}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(barWidth),
              child: SizedBox(
                height: barHeight,
                width: barWidth,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: barHeight,
                      width: barWidth,
                      decoration: BoxDecoration(
                        color: trackColor,
                        borderRadius: BorderRadius.circular(barWidth),
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: targetHeight),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedHeight, child) {
                        return Container(
                          height: animatedHeight,
                          width: barWidth,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(barWidth),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(category.label, style: AppTextStyles.bodySmall),
          ],
        );
      }),
    );
  }
}
