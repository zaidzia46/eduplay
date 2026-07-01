import 'package:eduplay/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/onboarding_controller.dart';
import '../theme/app_text_styles.dart';

class LevelSelector extends StatelessWidget {
  const LevelSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<OnboardingViewModel>();
    final levels = ['Beginner', 'Intermediate', 'Advanced'];
    final levelTrailing = ['Just starting', 'Some basics', 'Confident learner'];

    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(levels.length, (index) {
          final isSelected = vm.selectedLevel.value == levels[index];

          return GestureDetector(
            onTap: () => vm.selectedLevel.value = levels[index],
            child: Padding(
              padding: const EdgeInsets.all(7.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.tertiary : Colors.white,
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.tertiary
                        : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.tertiary.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: ListTile(
                    leading: Icon(
                      Icons.star,
                      size: 30,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    title: Text(
                      levels[index],
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      levelTrailing[index],
                      style: AppTextStyles.bodySecondary.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
