import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/home/dashboard/dashboard_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FilterSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Get.find<DashboardController>();

    final filters = [
      (SubjectFilter.all, 'All', Icons.apps_rounded, AppColors.primary),
      (
        SubjectFilter.notStarted,
        'Not Started',
        Icons.lock_outline,
        AppColors.textMuted,
      ),
      (
        SubjectFilter.inProgress,
        'In Progress',
        Icons.timelapse_rounded,
        AppColors.warning,
      ),
      (
        SubjectFilter.completed,
        'Completed',
        Icons.check_circle_outline,
        AppColors.success,
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text('Filter Subjects', style: AppTextStyles.h3),
          const SizedBox(height: 16),

          Obx(
            () => Column(
              children: filters.map((f) {
                final isSelected = vm.activeFilter.value == f.$1;
                return GestureDetector(
                  onTap: () {
                    vm.setFilter(f.$1);
                    Get.back();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? f.$4.withOpacity(0.1)
                          : AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? f.$4 : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          f.$3,
                          color: isSelected ? f.$4 : AppColors.textMuted,
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          f.$2,
                          style: AppTextStyles.body.copyWith(
                            color: isSelected ? f.$4 : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(Icons.check_circle, color: f.$4, size: 20),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
