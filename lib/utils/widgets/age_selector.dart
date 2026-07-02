import 'package:eduplay/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/onboarding_controller.dart';

class AgeSelector extends StatelessWidget {
  const AgeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<OnboardingViewModel>();
    final ages = ['4', '5', '6', '7', '8+'];

    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ages.map((age) {
          final isSelected = vm.selectedAge.value == age;

          return GestureDetector(
            onTap: () => vm.selectedAge.value = age,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.secondary
                      : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  age,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
