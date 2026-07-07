import 'package:eduplay/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/onboarding/onboarding_controller.dart';

class GenderSelector extends StatelessWidget {
  const GenderSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<OnboardingController>();
    final gender = ['Male', 'Female'];

    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(gender.length, (index) {
          final isSelected = vm.selectedGender.value == gender[index];

          return Expanded(
            child: GestureDetector(
              onTap: () {
                vm.gender(gender[index]);
              },
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.secondary : Colors.white,
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondary
                          : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
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
                      gender[index],
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
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
