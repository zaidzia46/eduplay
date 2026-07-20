import 'package:eduplay/screens/home/progress/progress_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/circular_loader.dart';
import '../../../widgets/recent_act_tile.dart';
import '../../../widgets/staggered_anime.dart';
import '../../../widgets/stat_tile.dart';
import '../../../widgets/subject_progress_row.dart';
import '../bottom_nav/bottomNavigation_controller.dart';

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    ever(Get.find<BottomNavController>().currentIndex, (index) {
      if (index == 2) {
        _controller.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<ProgressController>();
    final bool parentDashboard = false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (vm.isLoading.value) {
          return Center(child: CircularLoader());
        }

        if (vm.errorMessage.isNotEmpty) {
          return Center(
            child: Text(vm.errorMessage.value, style: AppTextStyles.body),
          );
        }

        final stats = vm.stats.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: Image.asset('assets/images/progress_bg.png'),
                ),
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Overall Progress',
                                style: AppTextStyles.sectionHeader,
                              ),
                              const SizedBox(height: 16),
                              Column(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: CircularProgressIndicator(
                                            value:
                                                (stats?.overallPercent ?? 0) /
                                                100,
                                            strokeWidth: 10,
                                            strokeCap: StrokeCap.round,
                                            backgroundColor:
                                                AppColors.primarySurface,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(AppColors.primary),
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${stats?.overallPercent ?? 0}%',
                                              style: AppTextStyles.h2,
                                            ),
                                            Text(
                                              'Overall',
                                              style: AppTextStyles.caption,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: StatTile(
                                              icon: FaIcon(
                                                FontAwesomeIcons.solidStar,
                                                size: 20,
                                                color: AppColors.star,
                                              ),
                                              color: AppColors.star,
                                              value:
                                                  '${stats?.starsEarned ?? 0}',
                                              label: 'Stars Earned',
                                            ),
                                          ),
                                          Expanded(
                                            child: StatTile(
                                              icon: FaIcon(
                                                FontAwesomeIcons.bookOpen,
                                                size: 20,
                                                color: AppColors.tertiary,
                                              ),
                                              color: AppColors.tertiary,
                                              value:
                                                  '${stats?.lessonsCompleted ?? 0}',
                                              label: 'Lessons Completed',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: StatTile(
                                              icon: FaIcon(
                                                FontAwesomeIcons.calendarCheck,
                                                size: 20,
                                                color: AppColors.success,
                                              ),
                                              color: AppColors.success,
                                              value:
                                                  '${stats?.daysActive ?? 0}',
                                              label: 'Days Active',
                                            ),
                                          ),
                                          Expanded(
                                            child: StatTile(
                                              icon: FaIcon(
                                                FontAwesomeIcons.award,
                                                size: 20,
                                                color: AppColors.error,
                                              ),
                                              color: AppColors.error,
                                              value:
                                                  '${stats?.badgesEarned ?? 0}',
                                              label: 'Badges Earned',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subject Progress',
                            style: AppTextStyles.sectionHeader,
                          ),
                          Text('View all', style: AppTextStyles.sectionLink),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        vm.subjects.length,
                        (index) => StaggeredAnimation(
                          controller: _controller,
                          index: index,
                          child: SubjectProgressRow(
                            subject: vm.subjects[index],
                            parentDashboard: parentDashboard,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Activity',
                            style: AppTextStyles.sectionHeader,
                          ),
                          Text('View all', style: AppTextStyles.sectionLink),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        vm.recentActivity.length,
                        (index) => StaggeredAnimation(
                          controller: _controller,
                          index: index,
                          child: RecentActivityTile(
                            activity: vm.recentActivity[index],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
