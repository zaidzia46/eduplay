import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../routes/app_routes.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import '../../../../../widgets/topics_banner_background.dart';
import '../../widgets/quiz_skeleton_loader.dart';
import 'quiz_list_controller.dart';
import 'quiz_model.dart';

class QuizListScreen extends StatelessWidget {
  QuizListScreen({super.key});

  final vm = Get.find<QuizListController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  children: [
                    _Header(vm: vm),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Obx(() {
                        if (vm.isLoading.value) {
                          return QuizListSkeleton(itemCount: 3);
                        }

                        if (vm.error.value.isNotEmpty) {
                          return Center(child: Text(vm.error.value));
                        }

                        if (vm.quizzes.isEmpty) {
                          return const Center(
                            child: Text('No quizzes here yet!'),
                          );
                        }

                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: vm.quizzes.length,
                          itemBuilder: (context, index) {
                            final quiz = vm.quizzes[index];
                            return _QuizCard(
                              quiz: quiz,
                              accentColor: vm.accentColor,
                              onTap: () async {
                                // Wait for the quiz route to pop, then re-pull
                                // just the scores so this card's percentage is
                                // fresh the moment we're back.
                                await Get.toNamed(
                                  AppRoutes.quiz,
                                  arguments: {
                                    'quizId': quiz.id,
                                    'passingScorePercent':
                                        quiz.passingScorePercent,
                                  },
                                );
                                vm.refreshProgress();
                              },
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              child: TopicBannerBackground(
                startColor: vm.accentColor.withOpacity(0.5),
                endColor: vm.accentColor.withOpacity(0.5),
                starColor: vm.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final QuizListController vm;
  const _Header({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: vm.accentColor,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            decoration: BoxDecoration(
              color: vm.accentColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.chapterTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h2.copyWith(color: AppColors.white),
                ),
                Text(
                  'Pick a quiz to play!',
                  style: AppTextStyles.caption.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.quiz_rounded, color: AppColors.white, size: 44),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final QuizModel quiz;
  final Color accentColor;
  final VoidCallback onTap;

  const _QuizCard({
    required this.quiz,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final passed = quiz.isPassed;
    final attempted = quiz.attempted;
    // Passed quizzes read as "done" (green); attempted-but-not-passed stay on
    // the subject accent; never-attempted show the plain play affordance.
    final progressColor = passed ? AppColors.success : accentColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: accentColor,
              width: 5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (passed ? AppColors.success : accentColor).withOpacity(
                  0.2,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                passed ? Icons.check_rounded : Icons.play_arrow_rounded,
                color: passed ? AppColors.success : accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  // Only show a progress bar once there's a real score to show.
                  if (attempted) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: quiz.bestPercent / 100,
                        minHeight: 6,
                        backgroundColor: progressColor.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (attempted) ...[
              Text(
                '${quiz.bestPercent}%',
                style: AppTextStyles.progressPercent.copyWith(
                  color: passed ? AppColors.success : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                passed ? Icons.chevron_right : Icons.refresh_rounded,
                color: passed ? AppColors.success : AppColors.textMuted,
              ),
            ] else
              Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
