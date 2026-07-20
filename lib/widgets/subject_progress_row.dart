import 'package:flutter/material.dart';

import '../models/subjects_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SubjectProgressRow extends StatelessWidget {
  final SubjectsModel subject;
  final bool parentDashboard;
  final VoidCallback? onTap;

  const SubjectProgressRow({
    super.key,
    required this.subject,
    required this.parentDashboard,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: subject.buttonColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                "assets/images/${subject.imageUrl}",
                errorBuilder: (_, __, ___) => Icon(
                  Icons.book_rounded,
                  color: subject.buttonColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject.subjectTitle, style: AppTextStyles.h4),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 12,
                        color: subject.buttonColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${subject.completedLessonCount} / ${subject.lessonCount} Lessons',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: subject.buttonColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: subject.progressPercent / 100,
                      minHeight: 6,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        subject.buttonColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${subject.progressPercent}%',
              style: AppTextStyles.h4.copyWith(color: subject.buttonColor),
            ),
            const SizedBox(width: 4),
            parentDashboard
                ? SizedBox()
                : Icon(
                    Icons.chevron_right,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
          ],
        ),
      ),
    );
  }
}
