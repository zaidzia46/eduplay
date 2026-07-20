import 'package:eduplay/controller/session_controller.dart';
import 'package:eduplay/screens/parent_dashboard/parent_dashboard_main/parent_dashboard_controller.dart';
import 'package:eduplay/widgets/welcome_bg_parent_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/circular_loader.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<ParentDashboardController>();
    final session = Get.find<SessionController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parent Dashboard', style: AppTextStyles.h3),
            Text(
              'Track, encourage and celebrate learning!',
              style: AppTextStyles.caption.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Obx(() {
                return WelcomeBackground(
                  welcomeText: 'Welcome',
                  subtitleText:
                      "You're doing a wonderful job supporting your children's journey.",
                  childrenCount: vm.children.length,
                  starsCount: vm.totalStars.value,
                  userName: session.parentName.value ?? 'User',
                );
              }),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (vm.isLoading.value) {
                    return Center(child: CircularLoader());
                  }

                  if (vm.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        vm.errorMessage.value,
                        style: AppTextStyles.body,
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: vm.children.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final child = vm.children[index];
                      final stars = vm.starsByChild[child.id] ?? 0;
                      final streak = vm.streakByChild[child.id] ?? 0;

                      return GestureDetector(
                        onTap: () => vm.openChildDetail(child),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/profile_sec_bg.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xffFFD84E),
                                child: ClipOval(
                                  child: child.avatar != null
                                      ? Image.asset(
                                          child.avatar!,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.person,
                                                color: AppColors.primary,
                                              ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          color: AppColors.primary,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(child.name, style: AppTextStyles.h4),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryDark,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        child.standard.standard,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: child.overallPercent / 100,
                                              minHeight: 6,
                                              backgroundColor: AppColors.white,
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                    Color
                                                  >(AppColors.primary),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${child.overallPercent}%',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: AppColors.star,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$stars',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.local_fire_department,
                                          color: AppColors.error,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$streak day streak',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
