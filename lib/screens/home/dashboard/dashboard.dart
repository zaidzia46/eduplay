import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduplay/routes/app_routes.dart';
import 'package:eduplay/theme/app_colors.dart';
import 'package:eduplay/widgets/title_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../theme/app_text_styles.dart';
import '../../profile/widgets/skeleton_avatar_loader.dart';
import '../../../widgets/circular_loader.dart';
import '../../../widgets/continue_learning_card.dart';
import '../../../widgets/streak_card.dart';
import '../../../widgets/subject_progress_row.dart';
import '../bottom_nav/bottomNavigation_controller.dart';
import '../progress/progress_controller.dart';
import 'dashboard_controller.dart';

class DashBoard extends StatefulWidget {
  DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final vm = Get.find<DashboardController>();
  final bottomNavConn = Get.find<BottomNavController>();
  late final AnimationController _controller;
  late final Worker _worker;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    if (bottomNavConn.currentIndex.value == 0) {
      _controller.forward(from: 0);
    }

    _worker = ever(bottomNavConn.currentIndex, (index) {
      if (index == 0) {
        _controller.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _worker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const double avatarSize = 64;
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
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: [0.0, 0.5, 0.85, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              'assets/images/dashboard_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      SizedBox(height: 15),
                      Obx(() {
                        final progress = Get.find<ProgressController>();
                        final stats = progress.stats.value;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() {
                              final url = vm.avatarUrl.value;
                              final isLoading = vm.isAvatarLoading.value;

                              if (isLoading) {
                                return const SkeletonAvatarLoader(
                                  avatarSize: avatarSize,
                                );
                              }

                              return CircleAvatar(
                                radius: avatarSize / 2,
                                backgroundColor: const Color(0xffFFD84E),
                                child: ClipOval(
                                  child: url != null
                                      ? CachedNetworkImage(
                                          imageUrl: url,
                                          fit: BoxFit.cover,
                                          width: avatarSize,
                                          height: avatarSize,
                                          placeholder: (_, __) =>
                                              const SkeletonAvatarLoader(
                                                avatarSize: avatarSize,
                                              ),
                                          errorWidget: (_, __, ___) =>
                                              const Icon(
                                                Icons.person,
                                                size: 45,
                                                color: AppColors.primary,
                                              ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 45,
                                          color: AppColors.primary,
                                        ),
                                ),
                              );
                            }),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hi, ${vm.child.value?.name ?? 'there'}!',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
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
                            const SizedBox(width: 5),
                            StreakCard(
                              num: stats?.starsEarned ?? 0,
                              image: const Image(
                                image: AssetImage('assets/images/star.png'),
                                fit: BoxFit.cover,
                                height: 24,
                              ),
                            ),
                            const SizedBox(width: 8),
                            StreakCard(
                              num: stats?.daysActive ?? 0,
                              image: const Image(
                                image: AssetImage('assets/images/3d-fire.png'),
                                fit: BoxFit.cover,
                                height: 24,
                              ),
                            ),
                          ],
                        );
                      }),
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
                              onPressed: () {
                                bottomNavConn.currentIndex.value = 1;
                                vm.activeFilter.value = SubjectFilter.all;
                              },
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
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TitleRow(
                            title: 'Choose a Subject',
                            onTap: () {
                              bottomNavConn.currentIndex.value = 1;
                              vm.activeFilter.value = SubjectFilter.all;
                            },
                          ),
                          SizedBox(
                            child: Obx(() {
                              if (vm.isSubjectsLoading.value) {
                                return CircularLoader();
                              }

                              if (vm.errorSubjectMessage.isNotEmpty) {
                                return Center(
                                  child: Text(vm.errorSubjectMessage.value),
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: vm.dashboardSubjects.length,
                                itemBuilder: (context, index) {
                                  final subject = vm.dashboardSubjects[index];
                                  return SubjectProgressRow(
                                    subject: subject,
                                    onTap: () {
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
                          TitleRow(
                            title: 'Continue Learning',
                            onTap: () {
                              bottomNavConn.currentIndex.value = 1;
                              vm.activeFilter.value = SubjectFilter.inProgress;
                            },
                          ),
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
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
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
                                              style:
                                                  AppTextStyles.bodySecondary,
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
          ),
        ],
      ),
    );
  }
}
