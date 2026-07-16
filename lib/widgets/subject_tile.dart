import 'package:flutter/material.dart';

import '../models/subjects_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SubjectTile extends StatelessWidget {
  final SubjectsModel subject;
  final VoidCallback onTap;

  const SubjectTile({required this.subject, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final int progress = subject.progressPercent;
    final bool hasStarted = progress > 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: subject.buttonColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Subject image
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: subject.buttonColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.asset(
              'assets/images/${subject.imageUrl}',
              errorBuilder: (_, __, ___) => Icon(
                Icons.book_rounded,
                color: subject.buttonColor,
                size: 32,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject.subjectTitle, style: AppTextStyles.h4),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 13,
                      color: subject.buttonColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${subject.lessonCount} Lessons',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: subject.buttonColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subject.description,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Progress bar — only if at least one topic is completed
                if (hasStarted) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 5,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              subject.buttonColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$progress%',
                        style: AppTextStyles.caption.copyWith(
                          color: subject.buttonColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Start / Continue button
          Column(
            children: [
              SizedBox(
                width: 90,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: subject.buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    hasStarted ? 'Continue' : 'Start',
                    style: AppTextStyles.buttonMedium.copyWith(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
