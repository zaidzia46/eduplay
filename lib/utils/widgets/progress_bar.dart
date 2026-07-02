import 'package:flutter/material.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import '../../theme/app_colors.dart';

class OnboardingProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return LinearProgressBar(
      maxSteps: totalSteps,
      currentStep: currentStep,
      progressType: ProgressType.dots,
      progressColor: currentStep == 0
          ? AppColors.primary
          : currentStep == 1
          ? AppColors.secondary
          : AppColors.tertiary,
      backgroundColor: Colors.white38, // unfilled dot color
      dotsActiveSize: 14, // active dot size
      dotsInactiveSize: 10, // inactive dot size
      dotsSpacing: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}
