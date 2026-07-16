import 'package:flutter/material.dart';

import '../models/topics_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TopicCard extends StatelessWidget {
  final TopicModel topic;
  final Color accentColor;
  final VoidCallback? onTap;

  const TopicCard({
    super.key,
    required this.topic,
    required this.accentColor,
    this.onTap,
    required CardtColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.topic,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: topic.progressPercent / 100,
                      minHeight: 6,
                      backgroundColor: accentColor.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${topic.progressPercent}%',
              style: AppTextStyles.progressPercent.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
