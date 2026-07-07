import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/subjects_model.dart';
import '../screens/home/dashboard/dashboard_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SubjectCard extends StatelessWidget {
  final SubjectsModel subject;
  final VoidCallback onPressed;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Subject image
          Expanded(child: Image.asset('assets/images/${subject.imageUrl}')),

          // Subject title
          Text(
            subject.subjectTitle,
            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          // Colored start button
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: subject.buttonColor,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Start',
                style: AppTextStyles.buttonMedium.copyWith(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
