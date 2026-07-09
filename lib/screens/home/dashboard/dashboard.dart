import 'package:eduplay/routes/app_routes.dart';
import 'package:eduplay/theme/app_colors.dart';
import 'package:eduplay/widgets/title_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../theme/app_text_styles.dart';
import '../../../widgets/circular_loader.dart';
import '../../../widgets/continue_learning_card.dart';
import '../../../widgets/streak_card.dart';
import '../../../widgets/subject_card.dart';
import 'dashboard_controller.dart';

class DashBoard extends StatelessWidget {
  DashBoard({super.key});
  final vm = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final bannerWidth = size.width - 24;
    final bannerHeight = bannerWidth * 841 / 1871;
    final topBackgroundHeight = (media.padding.top + 97 + bannerHeight).clamp(
      250.0,
      size.height * 0.45,
    );
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Container(
            height: topBackgroundHeight,
            decoration: BoxDecoration(
              color: AppColors.primary,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, Colors.white],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.yellow,
                          ),
                          child: Center(
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/girl1.png',
                                fit: BoxFit.cover,
                                height: 50,
                                width: 50,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // 'Hi, ${vm.nameController.value.text.capitalize}!',
                                'Hi, Laiba!',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Ready to learn something amazing today?',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 5),
                        StreakCard(
                          num: 123,
                          image: Image(
                            image: AssetImage('assets/images/star.png'),
                            fit: BoxFit.cover,
                            height: 24,
                          ),
                        ),
                        SizedBox(width: 8),
                        StreakCard(
                          num: 12,
                          image: Image(
                            image: AssetImage('assets/images/3d-fire.png'),
                            fit: BoxFit.cover,
                            height: 24,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AspectRatio(
                            aspectRatio: 1871 / 841,
                            child: Image.asset(
                              'assets/images/banner.png',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        Positioned(
                          left: (size.width * 0.05)
                              .clamp(20.0, 32.0)
                              .toDouble(),
                          bottom: (size.width * 0.055)
                              .clamp(18.0, 30.0)
                              .toDouble(),
                          width: (size.width * 0.35)
                              .clamp(125.0, 170.0)
                              .toDouble(),
                          height: (size.width * 0.065)
                              .clamp(32.0, 40.0)
                              .toDouble(),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                children: [
                                  Text(
                                    "Start Learning",
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: AppColors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TitleRow(title: 'Choose a Subject', onTap: () {}),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() {
                        if (vm.isSubjectsLoading.value) {
                          return CircularLoader();
                        }

                        if (vm.errorSubjectMessage.isNotEmpty) {
                          return Center(
                            child: Text(vm.errorSubjectMessage.value),
                          );
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.85,
                              ),
                          itemCount: vm.subjects.length,
                          itemBuilder: (context, index) {
                            final subject = vm.subjects[index];
                            return SubjectCard(
                              subject: subject,
                              onPressed: () {
                                Get.toNamed(
                                  AppRoutes.topics,
                                  arguments: {'subject': subject},
                                );
                              },
                            );
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 20),
                    TitleRow(title: 'Continue Learning', onTap: () {}),
                    SizedBox(
                      height: 124,
                      child: Obx(() {
                        if (vm.isLessonLoading.value) {
                          return CircularLoader();
                        }

                        if (vm.errorLessonMessage.isNotEmpty) {
                          return Center(
                            child: Text(vm.errorLessonMessage.value),
                          );
                        }

                        if (vm.continueLearning.isEmpty) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Lottie.asset(
                                  'assets/animations/sleep_cat.json',
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'No lessons in progress',
                                        style: AppTextStyles.h4,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Pick a subject above and start\nyour learning!',
                                        style: AppTextStyles.bodySecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: vm.continueLearning.length,
                          itemBuilder: (context, index) {
                            return ContinueLearningCard(
                              item: vm.continueLearning[index],
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
