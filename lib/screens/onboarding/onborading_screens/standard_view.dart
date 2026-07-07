import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/progress_bar.dart';
import '../onboarding_controller.dart';

class StandardView extends StatefulWidget {
  const StandardView({super.key});

  @override
  State<StandardView> createState() => _StandardViewState();
}

class _StandardViewState extends State<StandardView> {
  final vm = Get.find<OnboardingController>();
  late FixedExtentScrollController _wheelController;

  @override
  void initState() {
    super.initState();
    _wheelController = FixedExtentScrollController(
      initialItem: vm.selectedStandardIndex.value,
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/level_onboard.png', fit: BoxFit.cover),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  OnboardingProgressBar(
                    currentStep: vm.currentStep.value,
                    totalSteps: 3,
                  ),

                  const Spacer(),

                  const SizedBox(height: 16),

                  Text(
                    "Select your standard",
                    style: AppTextStyles.h1,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Your learning adventure is ready.\nLet\'s explore, play, and grow together!',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Standard picker wheel
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: SizedBox(
                      height: 200,
                      child: Obx(() {
                        if (vm.isStandardLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }

                        if (vm.errorMessage.value.isNotEmpty) {
                          return Center(
                            child: Text(
                              vm.errorMessage.value,
                              style: AppTextStyles.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        if (vm.standards.isEmpty) {
                          return Center(
                            child: Text(
                              'No standards available',
                              style: AppTextStyles.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.tertiary,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white38,
                                  width: 1,
                                ),
                              ),
                            ),
                            ListWheelScrollView.useDelegate(
                              controller: _wheelController,
                              itemExtent: 48,
                              diameterRatio: 1.8,
                              perspective: 0.003,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                vm.selectStandard(index);
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: vm.standards.length,
                                builder: (context, index) {
                                  return Obx(() {
                                    final isSelected =
                                        index == vm.selectedStandardIndex.value;

                                    return Center(
                                      child: Text(
                                        vm.standards[index].standard,
                                        style: isSelected
                                            ? AppTextStyles.bodyLarge.copyWith(
                                                color: AppColors.white,
                                              )
                                            : AppTextStyles.bodyLarge.copyWith(
                                                color: AppColors.tertiary,
                                              ),
                                      ),
                                    );
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),

                  const Spacer(),

                  // CTA button
                  ElevatedButton(
                    onPressed: vm.finishOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tertiary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Let's Go!",
                      style: AppTextStyles.buttonLarge,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
