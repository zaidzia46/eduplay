import 'package:flutter/material.dart';

import '../fns/time_ago.dart';
import '../models/recent_act_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class RecentActivityTile extends StatelessWidget {
  final RecentActivityModel activity;

  const RecentActivityTile({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              color: activity.subjectColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              activity.type == ActivityType.quiz
                  ? Icons.quiz_outlined
                  : Icons.menu_book_outlined,
              color: activity.subjectColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.body,
                    children: [
                      const TextSpan(text: 'Completed '),
                      TextSpan(
                        text: activity.subjectTitle,
                        style: TextStyle(color: activity.subjectColor),
                      ),
                      TextSpan(text: ' ${activity.typeLabel}'),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(activity.title, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    '+${activity.starsAwarded}',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(Icons.star_rounded, color: AppColors.star, size: 15),
                ],
              ),
              const SizedBox(height: 2),
              Text(timeAgo(activity.timestamp), style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}
