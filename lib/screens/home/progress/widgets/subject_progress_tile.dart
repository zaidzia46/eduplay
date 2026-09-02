import 'package:flutter/material.dart';

import '../../../../models/subject_progress_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Compact per-subject progress row on the Progress tab. Deliberately separate
/// from the shared `SubjectProgressRow` (used by the Subjects tab, whose
/// progress UI is intentionally still commented out) so this stays driven by
/// the real per-subject percentages from the progress RPC.
class SubjectProgressTile extends StatelessWidget {
  final SubjectProgressModel subject;
  final VoidCallback? onTap;

  const SubjectProgressTile({super.key, required this.subject, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: subject.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: subject.iconPath != null
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/${subject.iconPath}',
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.menu_book_rounded,
                          color: subject.color,
                          size: 20,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.menu_book_rounded,
                      color: subject.color,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject.name, style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: subject.percent / 100,
                      minHeight: 6,
                      backgroundColor: subject.color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(subject.color),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${subject.chaptersCompleted}/${subject.chaptersTotal} chapters',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${subject.percent}%',
              style: AppTextStyles.h4.copyWith(color: subject.color),
            ),
          ],
        ),
      ),
    );
  }
}
