import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linear_progress_bar/ui/circular_percent_indicator.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../models/activity_category_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ActivityBreakdownCard extends StatelessWidget {
  final List<ActivityCategoryModel> categories;
  ActivityBreakdownCard({super.key, required this.categories});

  final RxInt touchedIndex = (-1).obs;

  final RxBool hasBecomeVisible = false.obs;
  static const Color _trackColor = Color(0xFFEDEAF5);

  static const List<Color> _palette = [
    Color(0xFF6BCB77),
    Color(0xFFFF6B6B),
    Color(0xFFFFB84C),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(categories.length, (i) {
                return _CategoryBar(
                  index: i,
                  category: categories[i],
                  color: _colorFor(i),
                  trackColor: _trackColor,
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
    required this.touchedIndex,
    required this.hasBecomeVisible,
  });

  final int index;
  final ActivityCategoryModel category;
  final Color color;
  final Color trackColor;
  final RxInt touchedIndex;
  final RxBool hasBecomeVisible;

  @override
  Widget build(BuildContext context) {
    final total = category.total <= 0 ? 1 : category.total;
    final double fillValue = category.completed / total;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => touchedIndex.value = index,
      onTapUp: (_) => touchedIndex.value = -1,
      onTapCancel: () => touchedIndex.value = -1,
      child: Obx(() {
        final isTouched = touchedIndex.value == index;
        final barColor = isTouched ? color.withValues(alpha: 0.75) : color;
        final targetHeight = hasBecomeVisible.value ? fillValue : 0.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            ClipRRect(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: targetHeight),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedHeight, child) {
                      return CircularPercentIndicator(
                        radius: 32.0,
                        lineWidth: 8.0,
                        animation: false,
                        percent: animatedHeight.clamp(0.0, 1.0),
                        center: Text(
                          '${category.completed} / ${category.total}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        footer: Text(
                          category.label,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: barColor,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
