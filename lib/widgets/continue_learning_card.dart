import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../models/continue_learning_model.dart';

class ContinueLearningCard extends StatelessWidget {
  final ContinueLearningModel item;

  const ContinueLearningCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject title + percentage row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.title,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${item.progressPercent}%',
                style: AppTextStyles.progressPercent.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Lesson title
          Text(
            item.subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: item.progressPercent / 100,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(item.color),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
